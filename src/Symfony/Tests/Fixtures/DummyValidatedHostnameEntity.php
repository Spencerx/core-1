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

namespace ApiPlatform\Symfony\Tests\Fixtures;

use Symfony\Component\Validator\Constraints as Assert;

class DummyValidatedHostnameEntity
{
    /**
     * @var string
     */
    #[Assert\Hostname]
    public $dummyHostname;
}
