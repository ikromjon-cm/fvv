'use client'

import { useState } from 'react'
import Link from 'next/link'
import { Heart, Star } from 'lucide-react'
import { cn, formatPrice } from '@/lib/utils'
import type { Product } from '@/types'

interface ProductCardProps {
  product: Product
}

export function ProductCard({ product }: ProductCardProps) {
  const [favorited, setFavorited] = useState(product.is_favorited ?? false)

  const primaryImage = product.images.find((img) => img.is_primary) || product.images[0]
  const hasDiscount = product.discount_percent > 0

  return (
    <Link
      href={`/product/${product.id}`}
      className="group block bg-white rounded-2xl border border-gray-100 overflow-hidden transition-all duration-200 hover:scale-[1.02] hover:shadow-lg"
    >
      {/* Image container */}
      <div className="relative aspect-[4/3] bg-gray-50 overflow-hidden">
        {primaryImage ? (
          <img
            src={primaryImage.image}
            alt={product.title}
            className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
            loading="lazy"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center text-gray-300">
            <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
              <rect x="3" y="3" width="18" height="18" rx="2" />
              <circle cx="8.5" cy="8.5" r="1.5" />
              <path d="M21 15l-5-5L5 21" />
            </svg>
          </div>
        )}

        {/* Badges */}
        <div className="absolute top-2 left-2 flex flex-col gap-1">
          {hasDiscount && (
            <span className="px-2 py-0.5 rounded-lg bg-red-500 text-white text-[11px] font-semibold">
              -{product.discount_percent}%
            </span>
          )}
          {product.is_promoted && (
            <span className="px-2 py-0.5 rounded-lg bg-primary text-primary-foreground text-[11px] font-semibold">
              Reklama
            </span>
          )}
        </div>

        {/* Favorite button */}
        <button
          onClick={(e) => {
            e.preventDefault()
            e.stopPropagation()
            setFavorited(!favorited)
          }}
          className={cn(
            'absolute top-2 right-2 p-1.5 rounded-full bg-white/80 backdrop-blur-sm shadow-sm transition-colors',
            favorited ? 'text-red-500' : 'text-gray-400 hover:text-red-400',
          )}
        >
          <Heart className={cn('h-4 w-4', favorited && 'fill-current')} />
        </button>

        {/* Out of stock overlay */}
        {!product.in_stock && (
          <div className="absolute inset-0 bg-black/40 flex items-center justify-center">
            <span className="px-3 py-1 rounded-lg bg-white text-sm font-medium text-gray-900">
              Mavjud emas
            </span>
          </div>
        )}
      </div>

      {/* Content */}
      <div className="p-3 space-y-1.5">
        {/* Seller name */}
        <p className="text-[11px] text-gray-500 truncate">
          {product.seller.company_name}
        </p>

        {/* Title */}
        <h3 className="text-sm font-medium text-gray-900 line-clamp-2 leading-snug min-h-[2.5em]">
          {product.title}
        </h3>

        {/* Rating */}
        <div className="flex items-center gap-1">
          <Star className="h-3.5 w-3.5 fill-amber-400 text-amber-400" />
          <span className="text-xs font-medium text-gray-700">
            {product.average_rating.toFixed(1)}
          </span>
          <span className="text-xs text-gray-400">
            ({product.review_count})
          </span>
        </div>

        {/* Price */}
        <div className="space-y-0.5">
          {hasDiscount ? (
            <>
              <p className="text-base font-bold text-gray-900">
                {formatPrice(product.final_price)}
              </p>
              <p className="text-xs text-gray-400 line-through">
                {formatPrice(product.price)}
              </p>
            </>
          ) : (
            <p className="text-base font-bold text-gray-900">
              {formatPrice(product.price)}
            </p>
          )}
        </div>
      </div>
    </Link>
  )
}
