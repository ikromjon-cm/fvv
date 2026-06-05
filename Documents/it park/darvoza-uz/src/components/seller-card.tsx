'use client'

import Link from 'next/link'
import { MapPin, Clock, Star, BadgeCheck } from 'lucide-react'
import type { Seller } from '@/types'

interface SellerCardProps {
  seller: Seller
}

export function SellerCard({ seller }: SellerCardProps) {
  return (
    <Link
      href={`/seller/${seller.id}`}
      className="block bg-white rounded-2xl border border-gray-100 p-4 hover:shadow-md hover:border-gray-200 transition-all duration-200"
    >
      <div className="flex items-start gap-3">
        {/* Logo */}
        <div className="shrink-0">
          {seller.logo ? (
            <img
              src={seller.logo}
              alt={seller.company_name}
              className="w-14 h-14 rounded-xl object-cover"
              loading="lazy"
            />
          ) : (
            <div className="w-14 h-14 rounded-xl bg-primary/10 flex items-center justify-center">
              <span className="text-xl font-bold text-primary">
                {seller.company_name.charAt(0)}
              </span>
            </div>
          )}
        </div>

        {/* Info */}
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-1.5 mb-1">
            <h3 className="text-sm font-semibold text-gray-900 truncate">
              {seller.company_name}
            </h3>
            {seller.is_official && (
              <BadgeCheck className="h-4 w-4 text-primary shrink-0" />
            )}
          </div>

          <div className="flex items-center gap-2 text-xs text-gray-500 mb-2">
            <div className="flex items-center gap-0.5">
              <Star className="h-3.5 w-3.5 fill-amber-400 text-amber-400" />
              <span className="font-medium text-gray-700">{seller.rating.toFixed(1)}</span>
            </div>
            <span className="text-gray-300">|</span>
            <span>{seller.review_count} ta sharh</span>
          </div>

          {/* Address */}
          {seller.address && (
            <div className="flex items-start gap-1.5 mb-1">
              <MapPin className="h-3.5 w-3.5 text-gray-400 mt-0.5 shrink-0" />
              <p className="text-xs text-gray-500 line-clamp-1">{seller.address}</p>
            </div>
          )}

          {/* Working hours */}
          {seller.working_hours && (
            <div className="flex items-center gap-1.5">
              <Clock className="h-3.5 w-3.5 text-gray-400 shrink-0" />
              <p className="text-xs text-gray-500">{seller.working_hours}</p>
            </div>
          )}
        </div>
      </div>
    </Link>
  )
}
