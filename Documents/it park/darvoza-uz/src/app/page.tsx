'use client'

import Link from 'next/link'
import { ChevronRight, MapPin } from 'lucide-react'
import { Navbar } from '@/components/navbar'
import { Footer } from '@/components/footer'
import { MobileBottomNav } from '@/components/mobile-bottom-nav'
import { HeroBanner } from '@/components/hero-banner'
import { CategoryStrip } from '@/components/category-strip'
import { ProductGrid } from '@/components/product-grid'
import { SellerCard } from '@/components/seller-card'
import { useI18n } from '@/lib/i18n'
import { useBanners, useCategories, useProducts, useSellers } from '@/lib/api-hooks'

export default function HomePage() {
  const { t } = useI18n()
  const { data: banners, loading: bannersLoading } = useBanners()
  const { data: categories, loading: categoriesLoading } = useCategories()
  const { products, loading: productsLoading } = useProducts()
  const { data: sellersData, loading: sellersLoading } = useSellers()

  const loading = bannersLoading || categoriesLoading || productsLoading || sellersLoading

  if (loading) {
    return (
      <div className="min-h-screen bg-white pb-16 lg:pb-0">
        <Navbar />
        <main className="mx-auto max-w-7xl px-4 py-8">
          <div className="animate-pulse space-y-6">
            <div className="h-48 md:h-64 bg-gray-200 rounded-xl" />
            <div className="flex gap-4">
              {[1,2,3,4,5,6].map(i => <div key={i} className="h-20 w-20 bg-gray-200 rounded-lg" />)}
            </div>
            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
              {[1,2,3,4,5,6].map(i => <div key={i} className="h-64 bg-gray-200 rounded-lg" />)}
            </div>
          </div>
        </main>
        <Footer />
        <MobileBottomNav />
      </div>
    )
  }

  const sellers = sellersData?.results || []

  return (
    <div className="min-h-screen bg-white pb-16 lg:pb-0">
      <Navbar />

      <main>
        <section className="mx-auto max-w-7xl px-4 pt-4 md:pt-6 pb-2">
          <HeroBanner banners={banners || []} />
        </section>

        <section className="mx-auto max-w-7xl px-4 py-4 md:py-6">
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-lg md:text-xl font-bold text-gray-900">{t('popular_categories')}</h2>
            <Link href="/categories" className="text-sm font-medium text-primary hover:underline flex items-center gap-1">
              {t('view_all')} <ChevronRight className="h-4 w-4" />
            </Link>
          </div>
          <CategoryStrip categories={categories || []} />
        </section>

        <section className="mx-auto max-w-7xl px-4 py-4 md:py-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg md:text-xl font-bold text-gray-900">{t('featured_products')}</h2>
            <Link href="/marketplace" className="text-sm font-medium text-primary hover:underline flex items-center gap-1">
              {t('view_all')} <ChevronRight className="h-4 w-4" />
            </Link>
          </div>
          <ProductGrid products={products} />
        </section>

        {sellers.length > 0 && (
          <section className="mx-auto max-w-7xl px-4 py-4 md:py-6 mb-8">
            <div className="flex items-center gap-2 mb-4">
              <MapPin className="h-5 w-5 text-primary" />
              <h2 className="text-lg md:text-xl font-bold text-gray-900">{t('nearby_sellers')}</h2>
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
              {sellers.slice(0, 3).map((seller: any) => (
                <SellerCard key={seller.id} seller={seller} />
              ))}
            </div>
          </section>
        )}
      </main>

      <Footer />
      <MobileBottomNav />
    </div>
  )
}
