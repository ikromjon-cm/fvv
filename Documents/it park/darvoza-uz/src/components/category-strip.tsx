'use client'

import Link from 'next/link'
import { cn } from '@/lib/utils'
import type { Category } from '@/types'

interface CategoryStripProps {
  categories: Category[]
  activeId?: number
}

export function CategoryStrip({ categories, activeId }: CategoryStripProps) {
  return (
    <div className="relative">
      {/* Fade edges */}
      <div className="pointer-events-none absolute left-0 top-0 bottom-0 w-6 bg-gradient-to-r from-white to-transparent z-10" />
      <div className="pointer-events-none absolute right-0 top-0 bottom-0 w-6 bg-gradient-to-l from-white to-transparent z-10" />

      <div className="overflow-x-auto scrollbar-hide">
        <div className="flex gap-3 py-2 px-1 min-w-max">
          {categories.map((category) => {
            const isActive = category.id === activeId
            return (
              <Link
                key={category.id}
                href={`/categories/${category.slug}`}
                className={cn(
                  'flex flex-col items-center gap-2 px-4 py-3 rounded-2xl transition-all duration-150 min-w-[80px]',
                  isActive
                    ? 'bg-primary text-primary-foreground shadow-md'
                    : 'bg-gray-50 text-gray-700 hover:bg-gray-100 hover:text-gray-900',
                )}
              >
                {category.icon ? (
                  <img
                    src={category.icon}
                    alt={category.name}
                    className="w-8 h-8 object-contain"
                    loading="lazy"
                  />
                ) : category.image ? (
                  <img
                    src={category.image}
                    alt={category.name}
                    className="w-8 h-8 rounded-lg object-cover"
                    loading="lazy"
                  />
                ) : (
                  <div className="w-8 h-8 rounded-lg bg-white/20 flex items-center justify-center text-base">
                    {category.name.charAt(0)}
                  </div>
                )}
                <span className="text-xs font-medium whitespace-nowrap">
                  {category.name}
                </span>
              </Link>
            )
          })}
        </div>
      </div>
    </div>
  )
}
