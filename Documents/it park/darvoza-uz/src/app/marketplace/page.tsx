'use client'

import { useState, useEffect, Suspense } from 'react'
import { useSearchParams } from 'next/navigation'
import { Search, SlidersHorizontal, X, ChevronDown } from 'lucide-react'
import { Navbar } from '@/components/navbar'
import { Footer } from '@/components/footer'
import { MobileBottomNav } from '@/components/mobile-bottom-nav'
import { ProductGrid } from '@/components/product-grid'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Separator } from '@/components/ui/separator'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { useI18n } from '@/lib/i18n'
import { cn } from '@/lib/utils'
import { useProducts, useCategories } from '@/lib/api-hooks'

const gateTypes = ["Ikki qanotli", "Bir qanotli", "Panjara", "Avtomatik", "Blok"]
const materials = ["Metall", "Temir", "Beton", "Yog'och", "Plastik"]
const colors = ["Qora", "Oq", "Jigarrang", "Ko'k", "Kulrang", "Xrom", "Yashil"]

function MarketplaceContent() {
  const { t } = useI18n()
  const searchParams = useSearchParams()
  const categorySlug = searchParams.get('category')

  const [searchQuery, setSearchQuery] = useState('')
  const [selectedCategory, setSelectedCategory] = useState<string | null>(categorySlug || null)
  const [selectedGateType, setSelectedGateType] = useState<string | null>(null)
  const [selectedMaterial, setSelectedMaterial] = useState<string | null>(null)
  const [selectedColor, setSelectedColor] = useState<string | null>(null)
  const [priceRange, setPriceRange] = useState<[number, number]>([0, 6000000])
  const [sort, setSort] = useState('popular')
  const [filterDrawerOpen, setFilterDrawerOpen] = useState(false)
  const [page, setPage] = useState(1)

  const ordering = sort === 'newest' ? '-created_at' : sort === 'cheapest' ? 'final_price' : sort === 'expensive' ? '-final_price' : '-view_count'

  const params: Record<string, string | number | boolean | undefined> = {
    search: searchQuery || undefined,
    category: selectedCategory || undefined,
    ordering,
    material: selectedMaterial || undefined,
    color: selectedColor || undefined,
    gate_type: selectedGateType || undefined,
    price_min: priceRange[0] > 0 ? priceRange[0] : undefined,
    price_max: priceRange[1] < 6000000 ? priceRange[1] : undefined,
  }

  const { products, count, loading, loadMore } = useProducts(params)
  const { data: categories } = useCategories()

  useEffect(() => {
    setPage(1)
  }, [searchQuery, selectedCategory, selectedGateType, selectedMaterial, selectedColor, priceRange, sort])

  const hasMore = products.length < count

  const handleLoadMore = () => {
    const nextPage = page + 1
    loadMore(nextPage)
    setPage(nextPage)
  }

  const FilterContent = () => (
    <div className="space-y-5">
      {/* Category */}
      <div>
        <h4 className="text-sm font-semibold text-gray-900 mb-2">Kategoriya</h4>
        <div className="space-y-1">
          <button onClick={() => setSelectedCategory(null)} className={cn('w-full text-left px-3 py-2 rounded-lg text-sm transition-colors', !selectedCategory ? 'bg-primary/10 text-primary font-medium' : 'text-gray-600 hover:bg-gray-50')}>Barchasi</button>
          {(categories ?? []).map((cat) => (
            <button key={cat.id} onClick={() => setSelectedCategory(cat.slug)} className={cn('w-full text-left px-3 py-2 rounded-lg text-sm transition-colors', selectedCategory === cat.slug ? 'bg-primary/10 text-primary font-medium' : 'text-gray-600 hover:bg-gray-50')}>{cat.name}</button>
          ))}
        </div>
      </div>

      <Separator />

      {/* Gate type */}
      <div>
        <h4 className="text-sm font-semibold text-gray-900 mb-2">Darvoza turi</h4>
        <div className="space-y-1">
          <button onClick={() => setSelectedGateType(null)} className={cn('w-full text-left px-3 py-2 rounded-lg text-sm transition-colors', !selectedGateType ? 'bg-primary/10 text-primary font-medium' : 'text-gray-600 hover:bg-gray-50')}>Barchasi</button>
          {gateTypes.map((gt) => (
            <button key={gt} onClick={() => setSelectedGateType(gt)} className={cn('w-full text-left px-3 py-2 rounded-lg text-sm transition-colors', selectedGateType === gt ? 'bg-primary/10 text-primary font-medium' : 'text-gray-600 hover:bg-gray-50')}>{gt}</button>
          ))}
        </div>
      </div>

      <Separator />

      {/* Price range */}
      <div>
        <h4 className="text-sm font-semibold text-gray-900 mb-2">Narx oralig'i</h4>
        <div className="flex items-center gap-2 text-sm text-gray-600 mb-2">
          <span>{priceRange[0].toLocaleString()}</span>
          <span>-</span>
          <span>{priceRange[1].toLocaleString()}</span>
        </div>
        <input type="range" min={0} max={6000000} step={50000} value={priceRange[0]} onChange={(e) => setPriceRange([Math.min(Number(e.target.value), priceRange[1] - 50000), priceRange[1]])} className="w-full accent-primary" />
        <input type="range" min={0} max={6000000} step={50000} value={priceRange[1]} onChange={(e) => setPriceRange([priceRange[0], Math.max(Number(e.target.value), priceRange[0] + 50000)])} className="w-full accent-primary mt-1" />
      </div>

      <Separator />

      {/* Material */}
      <div>
        <h4 className="text-sm font-semibold text-gray-900 mb-2">Material</h4>
        <div className="space-y-1">
          <button onClick={() => setSelectedMaterial(null)} className={cn('w-full text-left px-3 py-2 rounded-lg text-sm transition-colors', !selectedMaterial ? 'bg-primary/10 text-primary font-medium' : 'text-gray-600 hover:bg-gray-50')}>Barchasi</button>
          {materials.map((m) => (
            <button key={m} onClick={() => setSelectedMaterial(m)} className={cn('w-full text-left px-3 py-2 rounded-lg text-sm transition-colors', selectedMaterial === m ? 'bg-primary/10 text-primary font-medium' : 'text-gray-600 hover:bg-gray-50')}>{m}</button>
          ))}
        </div>
      </div>

      <Separator />

      {/* Color */}
      <div>
        <h4 className="text-sm font-semibold text-gray-900 mb-2">Rang</h4>
        <div className="space-y-1">
          <button onClick={() => setSelectedColor(null)} className={cn('w-full text-left px-3 py-2 rounded-lg text-sm transition-colors', !selectedColor ? 'bg-primary/10 text-primary font-medium' : 'text-gray-600 hover:bg-gray-50')}>Barchasi</button>
          {colors.map((c) => (
            <button key={c} onClick={() => setSelectedColor(c)} className={cn('w-full text-left px-3 py-2 rounded-lg text-sm transition-colors', selectedColor === c ? 'bg-primary/10 text-primary font-medium' : 'text-gray-600 hover:bg-gray-50')}>{c}</button>
          ))}
        </div>
      </div>

      {/* Clear filters */}
      <Button variant="outline" className="w-full" onClick={() => { setSelectedCategory(null); setSelectedGateType(null); setSelectedMaterial(null); setSelectedColor(null); setPriceRange([0, 6000000]); setSort('popular') }}>
        Filtrlarni tozalash
      </Button>
    </div>
  )

  return (
    <div className="min-h-screen bg-white pb-16 lg:pb-0">
      <Navbar />

      <main className="mx-auto max-w-7xl px-4 py-4 md:py-6">
        {/* Search + actions bar */}
        <div className="flex items-center gap-3 mb-4">
          <div className="relative flex-1 max-w-md">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
            <input type="text" value={searchQuery} onChange={(e) => setSearchQuery(e.target.value)} placeholder={t('search')} className="w-full pl-10 pr-4 py-2 rounded-xl border border-gray-200 bg-gray-50 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all" />
          </div>

          <Select value={sort} onValueChange={setSort}>
            <SelectTrigger className="w-[160px]">
              <SelectValue placeholder="Saralash" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="popular">Ommabop</SelectItem>
              <SelectItem value="newest">Eng yangi</SelectItem>
              <SelectItem value="cheapest">Eng arzon</SelectItem>
              <SelectItem value="expensive">Eng qimmat</SelectItem>
            </SelectContent>
          </Select>

          <Button variant="outline" size="icon" className="lg:hidden" onClick={() => setFilterDrawerOpen(true)}>
            <SlidersHorizontal className="h-4 w-4" />
          </Button>
        </div>

        <div className="flex gap-6">
          {/* Desktop sidebar */}
          <aside className="hidden lg:block w-64 shrink-0">
            <div className="sticky top-20 bg-white rounded-2xl border border-gray-100 p-4 max-h-[calc(100vh-6rem)] overflow-y-auto">
              <FilterContent />
            </div>
          </aside>

          {/* Products */}
          <div className="flex-1 min-w-0">
            <div className="flex items-center justify-between mb-3">
              <p className="text-sm text-gray-500">{count} ta mahsulot topildi</p>
            </div>

            <ProductGrid products={products} />

            {hasMore && (
              <div className="mt-6 text-center">
                <Button variant="outline" onClick={handleLoadMore} disabled={loading}>
                  {t('load_more')} ({count - products.length} ta)
                </Button>
              </div>
            )}
          </div>
        </div>
      </main>

      {/* Mobile filter drawer */}
      {filterDrawerOpen && (
        <div className="fixed inset-0 z-50 bg-black/40 lg:hidden" onClick={() => setFilterDrawerOpen(false)}>
          <div className="absolute right-0 top-0 h-full w-80 max-w-[85vw] bg-white shadow-xl overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center justify-between p-4 border-b sticky top-0 bg-white z-10">
              <h3 className="font-semibold text-gray-900">Filtrlash</h3>
              <button onClick={() => setFilterDrawerOpen(false)} className="p-2 rounded-lg hover:bg-gray-100">
                <X className="h-5 w-5" />
              </button>
            </div>
            <div className="p-4">
              <FilterContent />
            </div>
          </div>
        </div>
      )}

      <Footer />
      <MobileBottomNav />
    </div>
  )
}

export default function MarketplacePage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin h-8 w-8 border-4 border-primary border-t-transparent rounded-full" />
      </div>
    }>
      <MarketplaceContent />
    </Suspense>
  )
}
