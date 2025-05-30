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

namespace ApiPlatform\Doctrine\Odm\State;

use ApiPlatform\Doctrine\Common\State\LinksHandlerLocatorTrait;
use ApiPlatform\Doctrine\Odm\Extension\AggregationItemExtensionInterface;
use ApiPlatform\Doctrine\Odm\Extension\AggregationResultItemExtensionInterface;
use ApiPlatform\Metadata\Exception\RuntimeException;
use ApiPlatform\Metadata\Operation;
use ApiPlatform\Metadata\Resource\Factory\ResourceMetadataCollectionFactoryInterface;
use ApiPlatform\State\ProviderInterface;
use ApiPlatform\State\Util\StateOptionsTrait;
use Doctrine\ODM\MongoDB\DocumentManager;
use Doctrine\ODM\MongoDB\Repository\DocumentRepository;
use Doctrine\Persistence\ManagerRegistry;
use Psr\Container\ContainerInterface;

/**
 * Item state provider using the Doctrine ODM.
 *
 * @author Kévin Dunglas <kevin@dunglas.fr>
 * @author Samuel ROZE <samuel.roze@gmail.com>
 */
final class ItemProvider implements ProviderInterface
{
    use LinksHandlerLocatorTrait;
    use LinksHandlerTrait;
    use StateOptionsTrait;

    /**
     * @param AggregationItemExtensionInterface[] $itemExtensions
     */
    public function __construct(ResourceMetadataCollectionFactoryInterface $resourceMetadataCollectionFactory, ManagerRegistry $managerRegistry, private readonly iterable $itemExtensions = [], ?ContainerInterface $handleLinksLocator = null)
    {
        $this->resourceMetadataCollectionFactory = $resourceMetadataCollectionFactory;
        $this->handleLinksLocator = $handleLinksLocator;
        $this->managerRegistry = $managerRegistry;
    }

    public function provide(Operation $operation, array $uriVariables = [], array $context = []): ?object
    {
        $documentClass = $this->getStateOptionsClass($operation, $operation->getClass(), Options::class);

        /** @var DocumentManager $manager */
        $manager = $this->managerRegistry->getManagerForClass($documentClass);

        $fetchData = $context['fetch_data'] ?? true;
        if (!$fetchData) {
            return $manager->getReference($documentClass, reset($uriVariables));
        }

        $repository = $manager->getRepository($documentClass);
        if (!$repository instanceof DocumentRepository) {
            throw new RuntimeException(\sprintf('The repository for "%s" must be an instance of "%s".', $documentClass, DocumentRepository::class));
        }

        $aggregationBuilder = $repository->createAggregationBuilder();

        if ($handleLinks = $this->getLinksHandler($operation)) {
            $handleLinks($aggregationBuilder, $uriVariables, ['documentClass' => $documentClass, 'operation' => $operation] + $context);
        } else {
            $this->handleLinks($aggregationBuilder, $uriVariables, $context, $documentClass, $operation);
        }

        foreach ($this->itemExtensions as $extension) {
            $extension->applyToItem($aggregationBuilder, $documentClass, $uriVariables, $operation, $context);

            if ($extension instanceof AggregationResultItemExtensionInterface && $extension->supportsResult($documentClass, $operation, $context)) {
                return $extension->getResult($aggregationBuilder, $documentClass, $operation, $context);
            }
        }

        $executeOptions = $operation->getExtraProperties()['doctrine_mongodb']['execute_options'] ?? [];

        return $aggregationBuilder->hydrate($documentClass)->getAggregation($executeOptions)->getIterator()->current() ?: null;
    }
}
