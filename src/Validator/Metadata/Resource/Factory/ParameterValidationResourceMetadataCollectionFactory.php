<?php

/*
 * This file is part of the API Platform project.
 *
 * (c) Kévin Dunglas <dunglas@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

declare(strict_types=1);

namespace ApiPlatform\Validator\Metadata\Resource\Factory;

use ApiPlatform\Metadata\HttpOperation;
use ApiPlatform\Metadata\Parameter;
use ApiPlatform\Metadata\Parameters;
use ApiPlatform\Metadata\QueryParameter;
use ApiPlatform\Metadata\Resource\Factory\ResourceMetadataCollectionFactoryInterface;
use ApiPlatform\Metadata\Resource\ResourceMetadataCollection;
use ApiPlatform\OpenApi\Model\Parameter as OpenApiParameter;
use Psr\Container\ContainerInterface;
use Symfony\Component\TypeInfo\Type\CollectionType;
use Symfony\Component\TypeInfo\Type\UnionType;
use Symfony\Component\Validator\Constraints\All;
use Symfony\Component\Validator\Constraints\Choice;
use Symfony\Component\Validator\Constraints\Collection;
use Symfony\Component\Validator\Constraints\Count;
use Symfony\Component\Validator\Constraints\DivisibleBy;
use Symfony\Component\Validator\Constraints\GreaterThan;
use Symfony\Component\Validator\Constraints\GreaterThanOrEqual;
use Symfony\Component\Validator\Constraints\Length;
use Symfony\Component\Validator\Constraints\LessThan;
use Symfony\Component\Validator\Constraints\LessThanOrEqual;
use Symfony\Component\Validator\Constraints\NotBlank;
use Symfony\Component\Validator\Constraints\NotNull;
use Symfony\Component\Validator\Constraints\Range;
use Symfony\Component\Validator\Constraints\Regex;
use Symfony\Component\Validator\Constraints\Type;
use Symfony\Component\Validator\Constraints\Unique;

final class ParameterValidationResourceMetadataCollectionFactory implements ResourceMetadataCollectionFactoryInterface
{
    public function __construct(
        private readonly ?ResourceMetadataCollectionFactoryInterface $decorated = null,
        private readonly ?ContainerInterface $filterLocator = null,
    ) {
    }

    public function create(string $resourceClass): ResourceMetadataCollection
    {
        $resourceMetadataCollection = $this->decorated?->create($resourceClass) ?? new ResourceMetadataCollection($resourceClass);

        foreach ($resourceMetadataCollection as $i => $resource) {
            $operations = $resource->getOperations();

            foreach ($operations as $operationName => $operation) {
                $parameters = $operation->getParameters() ?? new Parameters();
                foreach ($parameters as $key => $parameter) {
                    $parameters->add($key, $this->addSchemaValidation($parameter));
                }

                // As we deprecate the parameter validator, we declare a parameter for each filter transfering validation to the new system
                if ($operation->getFilters() && 0 === $parameters->count()) {
                    $parameters = $this->addFilterValidation($operation);
                }

                if (\count($parameters) > 0) {
                    $operations->add($operationName, $operation->withParameters($parameters));
                }
            }

            $resourceMetadataCollection[$i] = $resource->withOperations($operations->sort());

            if (!$graphQlOperations = $resource->getGraphQlOperations()) {
                continue;
            }

            foreach ($graphQlOperations as $operationName => $operation) {
                $parameters = $operation->getParameters() ?? new Parameters();
                foreach ($operation->getParameters() ?? [] as $key => $parameter) {
                    $parameters->add($key, $this->addSchemaValidation($parameter));
                }

                if (\count($parameters) > 0) {
                    $graphQlOperations[$operationName] = $operation->withParameters($parameters);
                }
            }

            $resourceMetadataCollection[$i] = $resource->withGraphQlOperations($graphQlOperations);
        }

        return $resourceMetadataCollection;
    }

    private function addSchemaValidation(Parameter $parameter, ?array $schema = null, ?bool $required = null, ?OpenApiParameter $openApi = null): Parameter
    {
        if (null !== $parameter->getConstraints()) {
            return $parameter;
        }

        $schema ??= $parameter->getSchema();
        $required ??= $parameter->getRequired() ?? false;
        $openApi ??= $parameter->getOpenApi();

        // When it's an array of openapi parameters take the first one as it's probably just a variant of the query parameter,
        // only getAllowEmptyValue is used here anyways
        if (\is_array($openApi)) {
            $openApi = $openApi[0];
        } elseif (false === $openApi) {
            $openApi = null;
        }

        $assertions = [];
        $allowEmptyValue = $openApi?->getAllowEmptyValue();
        if (false === ($allowEmptyValue ?? $openApi?->getAllowEmptyValue())) {
            $assertions[] = new NotBlank(allowNull: !$required);
        }

        $minimum = $schema['exclusiveMinimum'] ?? $schema['minimum'] ?? null;
        $exclusiveMinimum = isset($schema['exclusiveMinimum']);
        $maximum = $schema['exclusiveMaximum'] ?? $schema['maximum'] ?? null;
        $exclusiveMaximum = isset($schema['exclusiveMaximum']);

        if ($minimum && $maximum) {
            if (!$exclusiveMinimum && !$exclusiveMaximum) {
                $assertions[] = new Range(min: $minimum, max: $maximum);
            } else {
                $assertions[] = $exclusiveMinimum ? new GreaterThan(value: $minimum) : new GreaterThanOrEqual(value: $minimum);
                $assertions[] = $exclusiveMaximum ? new LessThan(value: $maximum) : new LessThanOrEqual(value: $maximum);
            }
        } elseif ($minimum) {
            $assertions[] = $exclusiveMinimum ? new GreaterThan(value: $minimum) : new GreaterThanOrEqual(value: $minimum);
        } elseif ($maximum) {
            $assertions[] = $exclusiveMaximum ? new LessThan(value: $maximum) : new LessThanOrEqual(value: $maximum);
        }

        if (isset($schema['pattern'])) {
            $assertions[] = new Regex('#'.$schema['pattern'].'#');
        }

        if (isset($schema['maxLength']) || isset($schema['minLength'])) {
            $assertions[] = new Length(min: $schema['minLength'] ?? null, max: $schema['maxLength'] ?? null);
        }

        if (isset($schema['multipleOf'])) {
            $assertions[] = new DivisibleBy(value: $schema['multipleOf']);
        }

        if (isset($schema['enum'])) {
            $assertions[] = new Choice(choices: $schema['enum']);
        }

        if ($properties = $parameter->getExtraProperties()['_properties'] ?? []) {
            $fields = [];
            foreach ($properties as $propertyName) {
                $fields[$propertyName] = $assertions;
            }

            return $parameter->withConstraints(new Collection(fields: $fields, allowMissingFields: true));
        }

        $isCollectionType = fn ($t) => $t instanceof CollectionType;
        $isCollection = $parameter->getNativeType()?->isSatisfiedBy($isCollectionType) ?? false;

        // type-info 7.2
        if (!$isCollection && $parameter->getNativeType() instanceof UnionType) {
            foreach ($parameter->getNativeType()->getTypes() as $t) {
                if ($isCollection = $t->isSatisfiedBy($isCollectionType)) {
                    break;
                }
            }
        }

        if ($isCollection) {
            $assertions = $assertions ? [new All($assertions)] : [];
        }

        if ($required && false !== $allowEmptyValue) {
            $assertions[] = new NotNull(message: \sprintf('The parameter "%s" is required.', $parameter->getKey()));
        }

        if (isset($schema['minItems']) || isset($schema['maxItems'])) {
            $assertions[] = new Count(min: $schema['minItems'] ?? null, max: $schema['maxItems'] ?? null);
        }

        if ($schema['uniqueItems'] ?? false) {
            $assertions[] = new Unique();
        }

        if (isset($schema['type']) && 'array' === $schema['type']) {
            $assertions[] = new Type(type: 'array');
        }

        if (!$assertions) {
            return $parameter;
        }

        if (1 === \count($assertions)) {
            return $parameter->withConstraints($assertions[0]);
        }

        return $parameter->withConstraints($assertions);
    }

    private function addFilterValidation(HttpOperation $operation): Parameters
    {
        $parameters = new Parameters();
        $internalPriority = -1;

        foreach ($operation->getFilters() as $filter) {
            if (!$this->filterLocator->has($filter)) {
                continue;
            }

            $filter = $this->filterLocator->get($filter);
            foreach ($filter->getDescription($operation->getClass()) as $parameterName => $definition) {
                $key = $parameterName;
                $required = $definition['required'] ?? false;
                $schema = $definition['schema'] ?? null;

                $openApi = null;
                if (isset($definition['openapi']) && $definition['openapi'] instanceof OpenApiParameter) {
                    $openApi = $definition['openapi'];
                }

                // The query parameter validator forced this, lets maintain BC on filters
                if (true === $required && !$openApi) {
                    $openApi = new OpenApiParameter(name: $key, in: 'query', allowEmptyValue: false);
                }

                $parameters->add($key, $this->addSchemaValidation(
                    // we disable openapi and hydra on purpose as their docs comes from filters see the condition for addFilterValidation above
                    new QueryParameter(key: $key, property: $definition['property'] ?? null, priority: $internalPriority--, schema: $schema, openApi: false, hydra: false),
                    $schema,
                    $required,
                    $openApi
                ));
            }
        }

        return $parameters;
    }
}
