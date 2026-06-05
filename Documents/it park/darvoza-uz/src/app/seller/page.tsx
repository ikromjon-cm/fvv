'use client'

import { useState, useEffect } from 'react'
import Link from 'next/link'
import {
  Package, ShoppingCart, Star, TrendingUp, Plus, Edit3, Trash2, Store, X,
} from 'lucide-react'
import { Navbar } from '@/components/navbar'
import { Footer } from '@/components/footer'
import { MobileBottomNav } from '@/components/mobile-bottom-nav'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { useAuth } from '@/lib/auth'
import { formatPrice } from '@/lib/utils'
import { useSellerProfile, useOrders } from '@/lib/api-hooks'
import { api } from '@/lib/api'
import type { OrderStatus } from '@/types'

const statusLabels: Record<string, string> = {
  new: 'Yangi',
  contacted: "Aloqaga chiqildi",
  measured: "O'lchov olindi",
  offered: 'Taklif yuborildi',
  agreed: 'Kelishildi',
  producing: 'Ishlab chiqarishda',
  installing: "O'rnatilmoqda",
  completed: 'Yakunlangan',
  cancelled: 'Bekor qilingan',
}

export default function SellerPage() {
  const { user, isLoading: authLoading } = useAuth()
  const { data: sellerProfile, loading: profileLoading } = useSellerProfile()
  const { orders, loading: ordersLoading } = useOrders()

  const [showAddDialog, setShowAddDialog] = useState(false)
  const [newProduct, setNewProduct] = useState({
    title: '', price: '', description: '', material: '', color: '',
    width: '', height: '',
  })
  const [adding, setAdding] = useState(false)
  const [products, setProducts] = useState<any[]>([])
  const [productsLoading, setProductsLoading] = useState(true)

  useEffect(() => {
    if (sellerProfile) {
      api.get<any>(`/products/?seller=${sellerProfile.id}`)
        .then(res => setProducts(res.results || []))
        .catch(() => {})
        .finally(() => setProductsLoading(false))
    }
  }, [sellerProfile])

  if (authLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin h-8 w-8 border-4 border-primary border-t-transparent rounded-full" />
      </div>
    )
  }

  if (!user || user.role !== 'seller') {
    return (
      <div className="min-h-screen flex flex-col">
        <Navbar />
        <div className="flex-1 flex items-center justify-center">
          <div className="text-center p-8">
            <Store className="h-16 w-16 mx-auto text-gray-300 mb-4" />
            <h2 className="text-xl font-semibold text-gray-900 mb-2">Ruxsat berilmagan</h2>
            <p className="text-gray-500 mb-6">Sotuvchi paneliga faqat sotuvchilar kirishi mumkin</p>
            <Link href="/">
              <Button>Bosh sahifa</Button>
            </Link>
          </div>
        </div>
        <Footer />
        <MobileBottomNav />
      </div>
    )
  }

  const handleAddProduct = async () => {
    if (!newProduct.title || !newProduct.price) return
    setAdding(true)
    try {
      const product = await api.post<any>('/products/', {
        title: newProduct.title,
        price: Number(newProduct.price),
        description: newProduct.description,
        material: newProduct.material,
        color: newProduct.color,
        width: newProduct.width,
        height: newProduct.height,
      })
      setProducts(prev => [product, ...prev])
      setNewProduct({ title: '', price: '', description: '', material: '', color: '', width: '', height: '' })
      setShowAddDialog(false)
    } catch (e) {
      alert('Xatolik yuz berdi')
    } finally {
      setAdding(false)
    }
  }

  const handleDelete = async (id: number) => {
    try {
      await api.delete(`/products/${id}/`)
      setProducts(products.filter((p) => p.id !== id))
    } catch (e) {
      alert('O\'chirishda xatolik')
    }
  }

  const totalRevenue = orders.reduce((sum, o) => sum + (o.total_price || 0), 0)
  const totalSales = orders.length
  const avgRating = sellerProfile?.rating ?? 0
  const reviewCount = sellerProfile?.review_count ?? 0

  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Navbar />
      <main className="flex-1 pb-20 lg:pb-0">
        <div className="mx-auto max-w-7xl px-4 py-6 space-y-6">
          <div className="flex items-center justify-between">
            <h1 className="text-2xl font-bold text-gray-900">
              {sellerProfile?.company_name || 'Sotuvchi paneli'}
            </h1>
            <Badge variant="default" className="gap-1">
              <Store className="h-3 w-3" />
              Sotuvchi
            </Badge>
          </div>

          {/* Stats */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <Card>
              <CardContent className="p-6 flex items-center gap-4">
                <div className="w-12 h-12 rounded-xl bg-blue-500 flex items-center justify-center">
                  <Package className="h-6 w-6 text-white" />
                </div>
                <div>
                  <p className="text-sm text-gray-500">Jami mahsulotlar</p>
                  <p className="text-2xl font-bold text-gray-900">
                    {productsLoading ? '...' : products.length}
                  </p>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-6 flex items-center gap-4">
                <div className="w-12 h-12 rounded-xl bg-green-500 flex items-center justify-center">
                  <ShoppingCart className="h-6 w-6 text-white" />
                </div>
                <div>
                  <p className="text-sm text-gray-500">Buyurtmalar</p>
                  <p className="text-2xl font-bold text-gray-900">
                    {ordersLoading ? '...' : totalSales}
                  </p>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-6 flex items-center gap-4">
                <div className="w-12 h-12 rounded-xl bg-purple-500 flex items-center justify-center">
                  <Star className="h-6 w-6 text-white" />
                </div>
                <div>
                  <p className="text-sm text-gray-500">Reyting</p>
                  <p className="text-2xl font-bold text-gray-900">
                    {avgRating.toFixed(1)}
                    <span className="text-sm font-normal text-gray-500"> ({reviewCount})</span>
                  </p>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-6 flex items-center gap-4">
                <div className="w-12 h-12 rounded-xl bg-primary flex items-center justify-center">
                  <TrendingUp className="h-6 w-6 text-white" />
                </div>
                <div>
                  <p className="text-sm text-gray-500">Daromad</p>
                  <p className="text-2xl font-bold text-gray-900">{formatPrice(totalRevenue)}</p>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Products */}
          <Card>
            <CardHeader className="flex flex-row items-center justify-between">
              <CardTitle className="text-base">Mening mahsulotlarim</CardTitle>
              <Button size="sm" onClick={() => setShowAddDialog(true)}>
                <Plus className="h-4 w-4 mr-1" />
                Mahsulot qo'shish
              </Button>
            </CardHeader>
            <CardContent className="p-0">
              {productsLoading ? (
                <div className="text-center py-8 text-sm text-gray-400">Yuklanmoqda...</div>
              ) : products.length === 0 ? (
                <div className="text-center py-8 text-sm text-gray-400">Mahsulotlar mavjud emas</div>
              ) : (
                <div className="overflow-x-auto">
                  <table className="w-full text-sm">
                    <thead>
                      <tr className="border-b border-gray-100">
                        <th className="text-left p-4 font-medium text-gray-500">Mahsulot</th>
                        <th className="text-left p-4 font-medium text-gray-500">Narxi</th>
                        <th className="text-left p-4 font-medium text-gray-500">Holat</th>
                        <th className="text-right p-4 font-medium text-gray-500">Amallar</th>
                      </tr>
                    </thead>
                    <tbody>
                      {products.map((product: any) => (
                        <tr key={product.id} className="border-b border-gray-50 hover:bg-gray-50">
                          <td className="p-4 font-medium text-gray-900">{product.title}</td>
                          <td className="p-4 text-gray-700">{formatPrice(product.final_price || product.price)}</td>
                          <td className="p-4">
                            <Badge variant={product.is_active ? 'default' : 'secondary'}>
                              {product.is_active ? 'Faol' : 'Faol emas'}
                            </Badge>
                          </td>
                          <td className="p-4 text-right">
                            <div className="flex items-center justify-end gap-1">
                              <Button
                                variant="ghost"
                                size="icon"
                                className="h-8 w-8"
                                onClick={() => handleDelete(product.id)}
                              >
                                <Trash2 className="h-4 w-4 text-red-500" />
                              </Button>
                            </div>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </CardContent>
          </Card>

          {/* Recent orders */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base">Oxirgi buyurtmalar</CardTitle>
            </CardHeader>
            <CardContent className="p-0">
              {ordersLoading ? (
                <div className="text-center py-8 text-sm text-gray-400">Yuklanmoqda...</div>
              ) : orders.length === 0 ? (
                <div className="text-center py-8 text-sm text-gray-400">Buyurtmalar mavjud emas</div>
              ) : (
                <div className="overflow-x-auto">
                  <table className="w-full text-sm">
                    <thead>
                      <tr className="border-b border-gray-100">
                        <th className="text-left p-4 font-medium text-gray-500">ID</th>
                        <th className="text-left p-4 font-medium text-gray-500">Xaridor</th>
                        <th className="text-left p-4 font-medium text-gray-500">Mahsulot</th>
                        <th className="text-left p-4 font-medium text-gray-500">Summa</th>
                        <th className="text-left p-4 font-medium text-gray-500">Holat</th>
                        <th className="text-left p-4 font-medium text-gray-500">Sana</th>
                      </tr>
                    </thead>
                    <tbody>
                      {orders.map((order) => (
                        <tr key={order.id} className="border-b border-gray-50 hover:bg-gray-50">
                          <td className="p-4 font-medium text-gray-900">#{order.id}</td>
                          <td className="p-4 text-gray-700">{order.buyer?.full_name || 'Noma\'lum'}</td>
                          <td className="p-4 text-gray-700">{order.product?.title || 'Noma\'lum'}</td>
                          <td className="p-4 font-medium text-gray-900">{formatPrice(order.total_price)}</td>
                          <td className="p-4">
                            <Badge variant={order.status === 'cancelled' ? 'destructive' : 'default'}>
                              {statusLabels[order.status] || order.status}
                            </Badge>
                          </td>
                          <td className="p-4 text-gray-500">
                            {new Date(order.created_at).toLocaleDateString('uz-UZ')}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </CardContent>
          </Card>
        </div>
      </main>

      {/* Add product dialog */}
      {showAddDialog && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
          <div className="bg-white rounded-2xl w-full max-w-md mx-4 p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-bold text-gray-900">Yangi mahsulot qo'shish</h3>
              <button onClick={() => setShowAddDialog(false)} className="p-1 rounded-lg hover:bg-gray-100">
                <X className="h-5 w-5 text-gray-500" />
              </button>
            </div>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Mahsulot nomi *</label>
                <Input
                  value={newProduct.title}
                  onChange={(e) => setNewProduct({ ...newProduct, title: e.target.value })}
                  placeholder="Mas: Surma darvoza 3x2.5"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Narxi (so'm) *</label>
                <Input
                  type="number"
                  value={newProduct.price}
                  onChange={(e) => setNewProduct({ ...newProduct, price: e.target.value })}
                  placeholder="5000000"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Tavsif</label>
                <Input
                  value={newProduct.description}
                  onChange={(e) => setNewProduct({ ...newProduct, description: e.target.value })}
                  placeholder="Mahsulot haqida qisqacha"
                />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Material</label>
                  <Input
                    value={newProduct.material}
                    onChange={(e) => setNewProduct({ ...newProduct, material: e.target.value })}
                    placeholder="Metall"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Rang</label>
                  <Input
                    value={newProduct.color}
                    onChange={(e) => setNewProduct({ ...newProduct, color: e.target.value })}
                    placeholder="Qora"
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Eni (sm)</label>
                  <Input
                    value={newProduct.width}
                    onChange={(e) => setNewProduct({ ...newProduct, width: e.target.value })}
                    placeholder="300"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Bo'yi (sm)</label>
                  <Input
                    value={newProduct.height}
                    onChange={(e) => setNewProduct({ ...newProduct, height: e.target.value })}
                    placeholder="250"
                  />
                </div>
              </div>
              <Button className="w-full" onClick={handleAddProduct} disabled={adding || !newProduct.title || !newProduct.price}>
                {adding ? 'Yuklanmoqda...' : <><Plus className="h-4 w-4 mr-1" /> Qo'shish</>}
              </Button>
            </div>
          </div>
        </div>
      )}

      <Footer />
      <MobileBottomNav />
    </div>
  )
}
