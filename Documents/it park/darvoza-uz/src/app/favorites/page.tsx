'use client'

import Link from 'next/link'
import { Heart, LogIn, AlertCircle } from 'lucide-react'
import { Navbar } from '@/components/navbar'
import { Footer } from '@/components/footer'
import { MobileBottomNav } from '@/components/mobile-bottom-nav'
import { ProductGrid } from '@/components/product-grid'
import { Button } from '@/components/ui/button'
import { useAuth } from '@/lib/auth'
import { useI18n } from '@/lib/i18n'
import { useFavorites } from '@/lib/api-hooks'

export default function FavoritesPage() {
  const { user, isLoading: authLoading } = useAuth()
  const { favorites, loading, error } = useFavorites()
  const { t } = useI18n()

  if (authLoading) {
    return (
      <div className="min-h-screen bg-white pb-16 lg:pb-0">
        <Navbar />
        <main className="mx-auto max-w-7xl px-4 py-8">
          <div className="h-8 w-48 bg-gray-100 rounded animate-pulse mb-6" />
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
            {Array.from({ length: 4 }).map((_, i) => (
              <div key={i} className="bg-white rounded-2xl border border-gray-100 overflow-hidden animate-pulse">
                <div className="aspect-[4/3] bg-gray-100" />
                <div className="p-3 space-y-2">
                  <div className="h-3 w-20 bg-gray-100 rounded" />
                  <div className="h-4 w-full bg-gray-100 rounded" />
                  <div className="h-5 w-24 bg-gray-100 rounded" />
                </div>
              </div>
            ))}
          </div>
        </main>
        <Footer />
        <MobileBottomNav />
      </div>
    )
  }

  if (!user) {
    return (
      <div className="min-h-screen bg-white pb-16 lg:pb-0">
        <Navbar />
        <main className="mx-auto max-w-7xl px-4 py-8">
          <div className="flex flex-col items-center justify-center py-20 text-center">
            <div className="w-20 h-20 rounded-full bg-gray-100 flex items-center justify-center mb-4">
              <Heart className="h-8 w-8 text-gray-300" />
            </div>
            <h2 className="text-xl font-bold text-gray-900 mb-2">{t('favorites')}</h2>
            <p className="text-gray-500 mb-6">Saralanganlarni ko'rish uchun tizimga kiring</p>
            <Link href="/login">
              <Button className="gap-2">
                <LogIn className="h-4 w-4" />
                {t('login')}
              </Button>
            </Link>
          </div>
        </main>
        <Footer />
        <MobileBottomNav />
      </div>
    )
  }

  if (error) {
    return (
      <div className="min-h-screen bg-white pb-16 lg:pb-0">
        <Navbar />
        <main className="mx-auto max-w-7xl px-4 py-8">
          <div className="flex flex-col items-center justify-center py-20 text-center">
            <div className="w-20 h-20 rounded-full bg-red-50 flex items-center justify-center mb-4">
              <AlertCircle className="h-8 w-8 text-red-400" />
            </div>
            <h2 className="text-xl font-bold text-gray-900 mb-2">Xatolik yuz berdi</h2>
            <p className="text-gray-500 mb-6">{error}</p>
            <Button variant="outline" onClick={() => window.location.reload()}>Qayta urinish</Button>
          </div>
        </main>
        <Footer />
        <MobileBottomNav />
      </div>
    )
  }

  const isEmpty = favorites.length === 0

  return (
    <div className="min-h-screen bg-white pb-16 lg:pb-0">
      <Navbar />

      <main className="mx-auto max-w-7xl px-4 py-4 md:py-6">
        <div className="flex items-center justify-between mb-6">
          <h1 className="text-2xl font-bold text-gray-900">{t('favorites')}</h1>
          {!isEmpty && (
            <span className="text-sm text-gray-500">{favorites.length} ta mahsulot</span>
          )}
        </div>

        {loading ? (
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
            {Array.from({ length: 4 }).map((_, i) => (
              <div key={i} className="bg-white rounded-2xl border border-gray-100 overflow-hidden animate-pulse">
                <div className="aspect-[4/3] bg-gray-100" />
                <div className="p-3 space-y-2">
                  <div className="h-3 w-20 bg-gray-100 rounded" />
                  <div className="h-4 w-full bg-gray-100 rounded" />
                  <div className="h-5 w-24 bg-gray-100 rounded" />
                </div>
              </div>
            ))}
          </div>
        ) : isEmpty ? (
          <div className="flex flex-col items-center justify-center py-20 text-center">
            <div className="w-20 h-20 rounded-full bg-gray-100 flex items-center justify-center mb-4">
              <Heart className="h-8 w-8 text-gray-300" />
            </div>
            <h2 className="text-xl font-bold text-gray-900 mb-2">{t('no_favorites')}</h2>
            <p className="text-gray-500 mb-6">Mahsulotlarni saralash uchun yuragini bosing</p>
            <Link href="/marketplace">
              <Button variant="outline">{t('marketplace')}ga o'tish</Button>
            </Link>
          </div>
        ) : (
          <ProductGrid products={favorites} />
        )}
      </main>

      <Footer />
      <MobileBottomNav />
    </div>
  )
}
