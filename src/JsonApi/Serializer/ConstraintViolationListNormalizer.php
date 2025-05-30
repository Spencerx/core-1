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

namespace ApiPlatform\JsonApi\Serializer;

use ApiPlatform\Metadata\Property\Factory\PropertyMetadataFactoryInterface;
use Symfony\Component\PropertyInfo\PropertyInfoExtractor;
use Symfony\Component\Serializer\NameConverter\NameConverterInterface;
use Symfony\Component\Serializer\Normalizer\NormalizerInterface;
use Symfony\Component\TypeInfo\Type\ObjectType;
use Symfony\Component\Validator\ConstraintViolationInterface;
use Symfony\Component\Validator\ConstraintViolationListInterface;

/**
 * Converts {@see ConstraintViolationListInterface} to a JSON API error representation.
 *
 * @author Héctor Hurtarte <hectorh30@gmail.com>
 */
final class ConstraintViolationListNormalizer implements NormalizerInterface
{
    public const FORMAT = 'jsonapi';

    public function __construct(private readonly PropertyMetadataFactoryInterface $propertyMetadataFactory, private readonly ?NameConverterInterface $nameConverter = null)
    {
    }

    /**
     * {@inheritdoc}
     */
    public function normalize(mixed $object, ?string $format = null, array $context = []): array
    {
        $violations = [];
        foreach ($object as $violation) {
            $violations[] = [
                'detail' => $violation->getMessage(),
                'source' => [
                    'pointer' => $this->getSourcePointerFromViolation($violation),
                ],
            ];
        }

        return ['errors' => $violations];
    }

    /**
     * {@inheritdoc}
     */
    public function supportsNormalization(mixed $data, ?string $format = null, array $context = []): bool
    {
        return self::FORMAT === $format && $data instanceof ConstraintViolationListInterface;
    }

    public function getSupportedTypes($format): array
    {
        return self::FORMAT === $format ? [ConstraintViolationListInterface::class => true] : [];
    }

    private function getSourcePointerFromViolation(ConstraintViolationInterface $violation): string
    {
        $fieldName = $violation->getPropertyPath();

        if (!$fieldName) {
            return 'data';
        }

        $class = $violation->getRoot()::class;
        $propertyMetadata = $this->propertyMetadataFactory
            ->create(
                // Im quite sure this requires some thought in case of validations over relationships
                $class,
                $fieldName
            );

        if (null !== $this->nameConverter) {
            $fieldName = $this->nameConverter->normalize($fieldName, $class, self::FORMAT);
        }

        if (!method_exists(PropertyInfoExtractor::class, 'getType')) {
            $type = $propertyMetadata->getBuiltinTypes()[0] ?? null;
            if ($type && null !== $type->getClassName()) {
                return "data/relationships/$fieldName";
            }
        } else {
            if ($propertyMetadata->getNativeType()?->isSatisfiedBy(fn ($t) => $t instanceof ObjectType)) {
                return "data/relationships/$fieldName";
            }
        }

        return "data/attributes/$fieldName";
    }
}
