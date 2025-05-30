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

namespace Workbench\App\Models;

use ApiPlatform\Metadata\ApiProperty;
use ApiPlatform\Metadata\ApiResource;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Symfony\Component\Serializer\Attribute\Groups;

#[ApiResource(
    denormalizationContext: ['groups' => ['cart_item.write']],
    normalizationContext: ['groups' => ['cart_item.write']],
    rules: [
        'product_sku' => 'required',
        'quantity' => 'required',
        'price_at_addition' => 'required',
    ]
)]
#[Groups('cart_item.write')]
#[ApiProperty(serialize: new Groups(['shopping_cart.write']), property: 'product_sku')]
#[ApiProperty(serialize: new Groups(['shopping_cart.write']), property: 'price_at_addition')]
#[ApiProperty(serialize: new Groups(['shopping_cart.write']), property: 'quantity')]
class CartItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'product_sku',
        'quantity',
        'price_at_addition',
    ];

    public function shoppingCart(): BelongsTo
    {
        return $this->belongsTo(ShoppingCart::class);
    }
}
