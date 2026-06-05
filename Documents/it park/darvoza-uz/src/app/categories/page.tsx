'use client'

import Link from 'next/link'
import { ChevronRight, DoorOpen } from 'lucide-react'
import { Navbar } from '@/components/navbar'
import { Footer } from '@/components/footer'
import { MobileBottomNav } from '@/components/mobile-bottom-nav'
import { useCategories } from '@/lib/api-hooks'
import { useI18n } from '@/lib/i18n'

const iconMap: Record<string, React.ReactNode> = {
  darvozalar: <DoorOpen className="h-8 w-8" />,
  eshiklar: <DoorOpen className="h-8 w-8" />,
}

export default function CategoriesPage() {
  const { t } = useI18n()
  const { data: categories, loading } = useCategories()

  return (
    <div className="min-h-screen bg-gray-50 pb-16 lg:pb-0">
      <Navbar />

      <main className="mx-auto max-w-7xl px-4 py-4 md:py-6">
        {/* Page header */}
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-gray-900">{t('categories')}</h1>
          <p className="text-sm text-gray-500 mt-1">Mahsulot kategoriyalarini tanlang</p>
        </div>

        {/* Category grid */}
        {loading ? (
          <div className="text-center py-16">
            <div className="animate-spin h-8 w-8 mx-auto border-4 border-primary border-t-transparent rounded-full" />
          </div>
        ) : (
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4">
            {(categories ?? []).map((category) => (
              <Link
                key={category.id}
                href={`/marketplace?category=${category.slug}`}
                className="group relative bg-white rounded-2xl border border-gray-100 overflow-hidden hover:shadow-lg hover:border-primary/20 transition-all duration-200"
              >
                {/* Image */}
                <div className="aspect-[4/3] bg-gray-100 relative overflow-hidden">
                  {category.image ? (
                    <img
                      src={category.image}
                      alt={category.name}
                      className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                      loading="lazy"
                    />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center text-gray-300">
                      {iconMap[category.slug] || <DoorOpen className="h-8 w-8" />}
                    </div>
                  )}
                  <div className="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent" />
                </div>

                {/* Content */}
                <div className="absolute bottom-0 left-0 right-0 p-3">
                  <div className="flex items-center gap-2">
                    <div className="flex items-center justify-center w-8 h-8 rounded-lg bg-white/20 backdrop-blur-sm text-white">
                      {iconMap[category.slug] || <DoorOpen className="h-4 w-4" />}
                    </div>
                    <span className="text-sm font-semibold text-white">{category.name}</span>
                  </div>
                </div>

                {/* Arrow on hover */}
                <div className="absolute top-3 right-3 opacity-0 group-hover:opacity-100 transition-opacity">
                  <div className="flex items-center justify-center w-8 h-8 rounded-full bg-white/90 backdrop-blur-sm text-primary shadow">
                    <ChevronRight className="h-4 w-4" />
                  </div>
                </div>
              </Link>
            ))}
          </div>
        )}
      </main>

      <Footer />
      <MobileBottomNav />
    </div>
  )
}
