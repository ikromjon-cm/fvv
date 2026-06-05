'use client'

import { useState } from 'react'
import { useParams } from 'next/navigation'
import Link from 'next/link'
import {
  Star,
  Heart,
  ShoppingCart,
  MessageCircle,
  Phone,
  BadgeCheck,
  MapPin,
  ChevronRight,
  Truck,
  Shield,
  RotateCcw,
} from 'lucide-react'
import { Navbar } from '@/components/navbar'
import { Footer } from '@/components/footer'
import { MobileBottomNav } from '@/components/mobile-bottom-nav'
import { ProductGrid } from '@/components/product-grid'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { useAuth } from '@/lib/auth'
import { useI18n } from '@/lib/i18n'
import { useProduct, useProducts, useProductReviews } from '@/lib/api-hooks'
import { cn, formatPrice } from '@/lib/utils'

function StarRating({ rating, size = 'sm' }: { rating: number; size?: 'sm' | 'md' }) {
  return (
    <div className="flex items-center gap-0.5">
      {[1, 2, 3, 4, 5].map((star) => (
        <Star
          key={star}
          className={cn(
            size === 'sm' ? 'h-3.5 w-3.5' : 'h-5 w-5',
            star <= Math.round(rating) ? 'fill-amber-400 text-amber-400' : 'text-gray-200',
          )}
        />
      ))}
    </div>
  )
}

function ProductDetailSkeleton() {
  return (
    <div className="min-h-screen bg-gray-50 pb-16 lg:pb-0 animate-pulse">
      <Navbar />
      <main className="mx-auto max-w-7xl px-4 py-4 md:py-6">
        <div className="h-4 w-64 bg-gray-200 rounded mb-4" />
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="lg:col-span-2">
            <div className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
              <div className="aspect-[4/3] bg-gray-100" />
            </div>
          </div>
          <div className="space-y-4">
            <div className="h-16 bg-gray-200 rounded-xl" />
            <div className="h-6 w-3/4 bg-gray-200 rounded" />
            <div className="h-4 w-1/3 bg-gray-200 rounded" />
            <div className="h-8 w-1/2 bg-gray-200 rounded" />
            <div className="h-4 w-1/4 bg-gray-200 rounded" />
            <div className="h-10 bg-gray-200 rounded-xl" />
            <div className="h-10 bg-gray-200 rounded-xl" />
            <div className="h-32 bg-gray-200 rounded-xl" />
          </div>
        </div>
      </main>
      <Footer />
    </div>
  )
}

function ErrorState({ message }: { message: string }) {
  return (
    <div className="min-h-screen bg-gray-50 pb-16 lg:pb-0">
      <Navbar />
      <main className="mx-auto max-w-7xl px-4 py-16">
        <div className="flex flex-col items-center justify-center text-center">
          <div className="w-16 h-16 rounded-full bg-red-100 flex items-center justify-center mb-4">
            <svg className="w-8 h-8 text-red-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <h2 className="text-xl font-bold text-gray-900 mb-2">Mahsulot topilmadi</h2>
          <p className="text-sm text-gray-500 mb-6">{message}</p>
          <Link href="/marketplace">
            <Button>Bozorga qaytish</Button>
          </Link>
        </div>
      </main>
      <Footer />
      <MobileBottomNav />
    </div>
  )
}

export default function ProductDetailPage() {
  const { id } = useParams<{ id: string }>()
  const { user } = useAuth()
  const { t } = useI18n()
  const [favorited, setFavorited] = useState(false)
  const [selectedImage, setSelectedImage] = useState(0)
  const [addedToCart, setAddedToCart] = useState(false)

  const { data: product, loading, error } = useProduct(id)
  const { data: reviews } = useProductReviews(id)
  const { products: rawRelated, loading: relatedLoading } = useProducts(
    product ? { category: product.category.id } : undefined
  )

  const hasDiscount = product ? product.discount_percent > 0 : false
  const relatedProducts = product ? rawRelated.filter(p => p.id !== product.id) : []

  const handleAddToCart = () => {
    setAddedToCart(true)
    setTimeout(() => setAddedToCart(false), 2000)
  }

  if (loading) return <ProductDetailSkeleton />
  if (error) return <ErrorState message={error} />
  if (!product) return null

  return (
    <div className="min-h-screen bg-gray-50 pb-16 lg:pb-0">
      <Navbar />

      <main className="mx-auto max-w-7xl px-4 py-4 md:py-6">
        {/* Breadcrumb */}
        <nav className="flex items-center gap-2 text-sm text-gray-500 mb-4">
          <Link href="/" className="hover:text-primary">{t('home')}</Link>
          <span>/</span>
          <Link href="/marketplace" className="hover:text-primary">{t('marketplace')}</Link>
          <span>/</span>
          <Link href={`/marketplace?category=${product.category.slug}`} className="hover:text-primary">{product.category.name}</Link>
          <span className="text-gray-400 truncate">/ {product.title}</span>
        </nav>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Left: Images */}
          <div className="lg:col-span-2">
            <div className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
              {/* Main image */}
              <div className="relative aspect-[4/3] bg-gray-50">
                <img
                  src={product.images[selectedImage]?.image || product.images[0]?.image}
                  alt={product.title}
                  className="w-full h-full object-contain"
                />
                {hasDiscount && (
                  <Badge className="absolute top-3 left-3 bg-red-500 text-white text-sm px-3 py-1">
                    -{product.discount_percent}%
                  </Badge>
                )}
                {product.is_promoted && (
                  <Badge variant="secondary" className="absolute top-3 right-3">
                    Reklama
                  </Badge>
                )}
              </div>

              {/* Thumbnails */}
              {product.images.length > 1 && (
                <div className="flex gap-2 p-3 border-t overflow-x-auto">
                  {product.images.map((img, i) => (
                    <button
                      key={img.id}
                      onClick={() => setSelectedImage(i)}
                      className={cn(
                        'shrink-0 w-16 h-16 rounded-lg border-2 overflow-hidden transition-all',
                        i === selectedImage ? 'border-primary' : 'border-gray-200 hover:border-gray-300',
                      )}
                    >
                      <img src={img.image} alt="" className="w-full h-full object-cover" />
                    </button>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Right: Product info */}
          <div className="space-y-4">
            {/* Seller */}
            <Link href={`/seller/${product.seller.id}`} className="flex items-center gap-3 p-3 bg-white rounded-xl border border-gray-100 hover:shadow-sm transition-shadow">
              {product.seller.logo ? (
                <img src={product.seller.logo} alt="" className="w-10 h-10 rounded-lg object-cover" />
              ) : (
                <div className="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center text-lg font-bold text-primary">
                  {product.seller.company_name.charAt(0)}
                </div>
              )}
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-1">
                  <span className="text-sm font-semibold text-gray-900 truncate">{product.seller.company_name}</span>
                  {product.seller.is_official && <BadgeCheck className="h-4 w-4 text-primary shrink-0" />}
                </div>
                <div className="flex items-center gap-1 text-xs text-gray-500">
                  <Star className="h-3 w-3 fill-amber-400 text-amber-400" />
                  <span>{product.seller.rating}</span>
                  <span>({product.seller.review_count} {t('reviews')})</span>
                </div>
              </div>
              <ChevronRight className="h-4 w-4 text-gray-400" />
            </Link>

            {/* Title */}
            <h1 className="text-xl md:text-2xl font-bold text-gray-900 leading-tight">{product.title}</h1>

            {/* Rating */}
            <div className="flex items-center gap-2">
              <StarRating rating={product.average_rating} size="md" />
              <span className="text-sm font-medium text-gray-700">{product.average_rating.toFixed(1)}</span>
              <span className="text-sm text-gray-400">({product.review_count} {t('reviews')})</span>
            </div>

            {/* Price */}
            <div className="flex items-baseline gap-3">
              <span className="text-2xl font-bold text-gray-900">{formatPrice(product.final_price)}</span>
              {hasDiscount && (
                <>
                  <span className="text-lg text-gray-400 line-through">{formatPrice(product.price)}</span>
                  <Badge className="bg-red-500 text-white">-{product.discount_percent}%</Badge>
                </>
              )}
            </div>

            {/* Stock */}
            <div className="flex items-center gap-2 text-sm">
              {product.in_stock ? (
                <span className="text-green-600 font-medium flex items-center gap-1">
                  <span className="w-2 h-2 rounded-full bg-green-500" />
                  {t('in_stock')}
                </span>
              ) : (
                <span className="text-red-500 font-medium">{t('out_of_stock')}</span>
              )}
            </div>

            {/* Actions */}
            <div className="flex gap-2">
              <Button size="lg" className="flex-1 gap-2" onClick={handleAddToCart}>
                <ShoppingCart className="h-4 w-4" />
                {addedToCart ? "Qo'shildi!" : t('add_to_cart')}
              </Button>
              <Button variant="outline" size="icon" className="h-10 w-10" onClick={() => setFavorited(!favorited)}>
                <Heart className={cn('h-4 w-4', favorited && 'fill-red-500 text-red-500')} />
              </Button>
            </div>

            <div className="flex gap-2">
              <Button variant="outline" size="lg" className="flex-1 gap-2">
                <MessageCircle className="h-4 w-4" />
                {t('send_message')}
              </Button>
              <Button variant="outline" size="lg" className="flex-1 gap-2">
                <Phone className="h-4 w-4" />
                {t('call')}
              </Button>
            </div>

            {/* Delivery info */}
            <div className="bg-white rounded-xl border border-gray-100 p-4 space-y-3">
              <div className="flex items-start gap-3">
                <Truck className="h-5 w-5 text-primary shrink-0 mt-0.5" />
                <div>
                  <p className="text-sm font-medium text-gray-900">Yetkazib berish</p>
                  <p className="text-xs text-gray-500">Toshkent bo'ylab 1-3 kun ichida yetkaziladi</p>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <Shield className="h-5 w-5 text-primary shrink-0 mt-0.5" />
                <div>
                  <p className="text-sm font-medium text-gray-900">Kafolat</p>
                  <p className="text-xs text-gray-500">12 oy kafolat, sifatsiz mahsulotni qaytarish</p>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <RotateCcw className="h-5 w-5 text-primary shrink-0 mt-0.5" />
                <div>
                  <p className="text-sm font-medium text-gray-900">Qaytarish</p>
                  <p className="text-xs text-gray-500">14 kun ichida tovarni qaytarish imkoniyati</p>
                </div>
              </div>
            </div>

            {/* Seller address */}
            {product.seller.address && (
              <div className="flex items-start gap-2 text-sm text-gray-500">
                <MapPin className="h-4 w-4 text-gray-400 shrink-0 mt-0.5" />
                <span>{product.seller.address}</span>
              </div>
            )}
          </div>
        </div>

        {/* Description + specs */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mt-6">
          <div className="lg:col-span-2 space-y-6">
            {/* Description */}
            <section className="bg-white rounded-2xl border border-gray-100 p-5">
              <h2 className="text-lg font-bold text-gray-900 mb-3">Mahsulot haqida</h2>
              <p className="text-sm text-gray-600 leading-relaxed">{product.description}</p>
            </section>

            {/* Specifications */}
            <section className="bg-white rounded-2xl border border-gray-100 p-5">
              <h2 className="text-lg font-bold text-gray-900 mb-3">Texnik xususiyatlar</h2>
              <div className="divide-y">
                <div className="flex justify-between py-2.5 text-sm">
                  <span className="text-gray-500">Kenglik</span>
                  <span className="font-medium text-gray-900">{product.width} sm</span>
                </div>
                <div className="flex justify-between py-2.5 text-sm">
                  <span className="text-gray-500">Balandlik</span>
                  <span className="font-medium text-gray-900">{product.height} sm</span>
                </div>
                <div className="flex justify-between py-2.5 text-sm">
                  <span className="text-gray-500">Material</span>
                  <span className="font-medium text-gray-900">{product.material}</span>
                </div>
                <div className="flex justify-between py-2.5 text-sm">
                  <span className="text-gray-500">Rang</span>
                  <span className="font-medium text-gray-900">{product.color}</span>
                </div>
                <div className="flex justify-between py-2.5 text-sm">
                  <span className="text-gray-500">Darvoza turi</span>
                  <span className="font-medium text-gray-900">{product.gate_type.name}</span>
                </div>
                <div className="flex justify-between py-2.5 text-sm">
                  <span className="text-gray-500">Kategoriya</span>
                  <span className="font-medium text-gray-900">{product.category.name}</span>
                </div>
              </div>
            </section>

            {/* Reviews */}
            <section className="bg-white rounded-2xl border border-gray-100 p-5">
              <div className="flex items-center justify-between mb-4">
                <h2 className="text-lg font-bold text-gray-900">Sharhlar ({reviews ? reviews.length : 0})</h2>
                <Button variant="outline" size="sm">Sharh qoldirish</Button>
              </div>
              {!reviews || reviews.length === 0 ? (
                <p className="text-sm text-gray-500">{t('no_reviews')}</p>
              ) : (
                <div className="space-y-4 divide-y">
                  {reviews.map((review) => (
                    <div key={review.id} className="pt-4 first:pt-0">
                      <div className="flex items-start gap-3">
                        <div className="w-9 h-9 rounded-full bg-primary/10 flex items-center justify-center text-sm font-bold text-primary shrink-0">
                          {review.user.full_name.charAt(0)}
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-2 mb-1">
                            <span className="text-sm font-semibold text-gray-900">{review.user.full_name}</span>
                            {review.user.is_verified && <BadgeCheck className="h-3.5 w-3.5 text-primary" />}
                            <span className="text-xs text-gray-400">{new Date(review.created_at).toLocaleDateString('uz-UZ')}</span>
                          </div>
                          <StarRating rating={review.rating} />
                          <p className="text-sm text-gray-600 mt-1.5 leading-relaxed">{review.comment}</p>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </section>
          </div>
        </div>

        {/* Related products */}
        <section className="mt-8 mb-8">
          <h2 className="text-lg md:text-xl font-bold text-gray-900 mb-4">O'xshash mahsulotlar</h2>
          <ProductGrid products={relatedProducts} loading={relatedLoading} />
        </section>
      </main>

      {/* Mobile sticky bottom bar */}
      <div className="fixed bottom-14 left-0 right-0 bg-white border-t p-3 flex gap-2 lg:hidden z-40">
        <Button size="lg" className="flex-1 gap-2" onClick={handleAddToCart}>
          <ShoppingCart className="h-4 w-4" />
          {addedToCart ? "Qo'shildi!" : t('add_to_cart')}
        </Button>
        <Button variant="outline" size="icon" className="h-10 w-10 shrink-0" onClick={() => setFavorited(!favorited)}>
          <Heart className={cn('h-4 w-4', favorited && 'fill-red-500 text-red-500')} />
        </Button>
      </div>

      <Footer />
      <MobileBottomNav />
    </div>
  )
}
