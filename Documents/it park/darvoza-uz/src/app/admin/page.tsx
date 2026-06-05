'use client'

import Link from 'next/link'
import {
  Users, Package, ShoppingCart, TrendingUp, Shield,
} from 'lucide-react'
import { Navbar } from '@/components/navbar'
import { Footer } from '@/components/footer'
import { MobileBottomNav } from '@/components/mobile-bottom-nav'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { useAuth } from '@/lib/auth'
import { formatPrice } from '@/lib/utils'
import { useOrders, useUsers } from '@/lib/api-hooks'
import { api } from '@/lib/api'
import type { OrderStatus } from '@/types'
import { useState, useEffect } from 'react'

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

const roleLabels: Record<string, string> = {
  buyer: 'Xaridor',
  seller: 'Sotuvchi',
  master: 'Usta',
  admin: 'Admin',
}

export default function AdminPage() {
  const { user, isLoading: authLoading } = useAuth()
  const { orders, loading: ordersLoading } = useOrders()
  const { users, loading: usersLoading } = useUsers()
  const [totalProducts, setTotalProducts] = useState(0)
  const [loadingStats, setLoadingStats] = useState(true)

  useEffect(() => {
    api.get<any>('/products/')
      .then(res => setTotalProducts(res.count || 0))
      .catch(() => {})
      .finally(() => setLoadingStats(false))
  }, [])

  if (authLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin h-8 w-8 border-4 border-primary border-t-transparent rounded-full" />
      </div>
    )
  }

  if (!user || user.role !== 'admin') {
    return (
      <div className="min-h-screen flex flex-col">
        <Navbar />
        <div className="flex-1 flex items-center justify-center">
          <div className="text-center p-8">
            <Shield className="h-16 w-16 mx-auto text-gray-300 mb-4" />
            <h2 className="text-xl font-semibold text-gray-900 mb-2">Ruxsat berilmagan</h2>
            <p className="text-gray-500 mb-6">Sizda admin panelga kirish huquqi yo'q</p>
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

  const totalRevenue = orders.reduce((sum, o) => sum + (o.total_price || 0), 0)

  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Navbar />
      <main className="flex-1 pb-20 lg:pb-0">
        <div className="mx-auto max-w-7xl px-4 py-6 space-y-6">
          <div className="flex items-center justify-between">
            <h1 className="text-2xl font-bold text-gray-900">Admin panel</h1>
            <Badge variant="default" className="gap-1">
              <Shield className="h-3 w-3" />
              Admin
            </Badge>
          </div>

          {/* Stats grid */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <Card>
              <CardContent className="p-6">
                <div className="flex items-center justify-between">
                  <div className="space-y-1">
                    <p className="text-sm text-gray-500">Jami foydalanuvchilar</p>
                    <p className="text-2xl font-bold text-gray-900">
                      {usersLoading ? '...' : users.length}
                    </p>
                  </div>
                  <div className="w-12 h-12 rounded-xl bg-blue-500 flex items-center justify-center">
                    <Users className="h-6 w-6 text-white" />
                  </div>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-6">
                <div className="flex items-center justify-between">
                  <div className="space-y-1">
                    <p className="text-sm text-gray-500">Jami mahsulotlar</p>
                    <p className="text-2xl font-bold text-gray-900">
                      {loadingStats ? '...' : totalProducts}
                    </p>
                  </div>
                  <div className="w-12 h-12 rounded-xl bg-green-500 flex items-center justify-center">
                    <Package className="h-6 w-6 text-white" />
                  </div>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-6">
                <div className="flex items-center justify-between">
                  <div className="space-y-1">
                    <p className="text-sm text-gray-500">Jami buyurtmalar</p>
                    <p className="text-2xl font-bold text-gray-900">
                      {ordersLoading ? '...' : orders.length}
                    </p>
                  </div>
                  <div className="w-12 h-12 rounded-xl bg-primary flex items-center justify-center">
                    <ShoppingCart className="h-6 w-6 text-white" />
                  </div>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-6">
                <div className="flex items-center justify-between">
                  <div className="space-y-1">
                    <p className="text-sm text-gray-500">Jami daromad</p>
                    <p className="text-2xl font-bold text-gray-900">{formatPrice(totalRevenue)}</p>
                  </div>
                  <div className="w-12 h-12 rounded-xl bg-purple-500 flex items-center justify-center">
                    <TrendingUp className="h-6 w-6 text-white" />
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>

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
                      {orders.slice(0, 10).map((order) => (
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

          {/* Recent users */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base">Foydalanuvchilar</CardTitle>
            </CardHeader>
            <CardContent className="p-0">
              {usersLoading ? (
                <div className="text-center py-8 text-sm text-gray-400">Yuklanmoqda...</div>
              ) : users.length === 0 ? (
                <div className="text-center py-8 text-sm text-gray-400">Foydalanuvchilar mavjud emas</div>
              ) : (
                <div className="overflow-x-auto">
                  <table className="w-full text-sm">
                    <thead>
                      <tr className="border-b border-gray-100">
                        <th className="text-left p-4 font-medium text-gray-500">Foydalanuvchi</th>
                        <th className="text-left p-4 font-medium text-gray-500">Telefon</th>
                        <th className="text-left p-4 font-medium text-gray-500">Rol</th>
                      </tr>
                    </thead>
                    <tbody>
                      {users.map((u) => (
                        <tr key={u.id} className="border-b border-gray-50 hover:bg-gray-50">
                          <td className="p-4">
                            <div className="flex items-center gap-3">
                              <Avatar className="h-8 w-8">
                                <AvatarFallback className="bg-primary/10 text-primary text-xs">
                                  {u.full_name.charAt(0)}
                                </AvatarFallback>
                              </Avatar>
                              <span className="font-medium text-gray-900">{u.full_name}</span>
                            </div>
                          </td>
                          <td className="p-4 text-gray-700">{u.phone}</td>
                          <td className="p-4">
                            <Badge variant="outline">{roleLabels[u.role] || u.role}</Badge>
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
      <Footer />
      <MobileBottomNav />
    </div>
  )
}
