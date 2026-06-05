'use client'

import { useState } from 'react'
import Link from 'next/link'
import { Package, ChevronRight } from 'lucide-react'
import { Navbar } from '@/components/navbar'
import { Footer } from '@/components/footer'
import { MobileBottomNav } from '@/components/mobile-bottom-nav'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { useAuth } from '@/lib/auth'
import { formatPrice } from '@/lib/utils'
import { useOrders } from '@/lib/api-hooks'
import type { OrderStatus } from '@/types'

const statusTabs: { label: string; value: OrderStatus | 'all' }[] = [
  { label: 'Barchasi', value: 'all' },
  { label: 'Yangi', value: 'new' },
  { label: 'Aloqaga chiqildi', value: 'contacted' },
  { label: "O'lchov olindi", value: 'measured' },
  { label: 'Taklif yuborildi', value: 'offered' },
  { label: 'Kelishildi', value: 'agreed' },
  { label: 'Ishlab chiqarishda', value: 'producing' },
  { label: 'O\'rnatilmoqda', value: 'installing' },
  { label: 'Yakunlandi', value: 'completed' },
  { label: 'Bekor qilindi', value: 'cancelled' },
]

const statusVariant: Record<OrderStatus, 'default' | 'secondary' | 'destructive' | 'outline'> = {
  new: 'secondary',
  contacted: 'secondary',
  measured: 'secondary',
  offered: 'default',
  agreed: 'default',
  producing: 'default',
  installing: 'default',
  cancelled: 'destructive',
  completed: 'outline',
}

export default function OrdersPage() {
  const { user, isLoading: authLoading } = useAuth()
  const { orders, loading: ordersLoading } = useOrders()
  const [activeTab, setActiveTab] = useState<OrderStatus | 'all'>('all')

  const filteredOrders = activeTab === 'all'
    ? orders
    : orders.filter((o) => o.status === activeTab)

  if (authLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin h-8 w-8 border-4 border-primary border-t-transparent rounded-full" />
      </div>
    )
  }

  if (!user) {
    return (
      <div className="min-h-screen flex flex-col">
        <Navbar />
        <div className="flex-1 flex items-center justify-center">
          <div className="text-center p-8">
            <Package className="h-16 w-16 mx-auto text-gray-300 mb-4" />
            <h2 className="text-xl font-semibold text-gray-900 mb-2">Buyurtmalarni ko'rish uchun kiring</h2>
            <p className="text-gray-500 mb-6">Buyurtmalaringizni kuzatish uchun akkauntingizga kiring</p>
            <Link href="/login">
              <Button>Kirish</Button>
            </Link>
          </div>
        </div>
        <Footer />
        <MobileBottomNav />
      </div>
    )
  }

  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Navbar />
      <main className="flex-1 pb-20 lg:pb-0">
        <div className="mx-auto max-w-4xl px-4 py-6">
          <h1 className="text-2xl font-bold text-gray-900 mb-6">Buyurtmalarim</h1>

          {/* Filter tabs */}
          <div className="flex gap-2 overflow-x-auto pb-2 mb-6 scrollbar-hide">
            {statusTabs.map((tab) => (
              <button
                key={tab.value}
                onClick={() => setActiveTab(tab.value)}
                className={`shrink-0 px-4 py-2 rounded-full text-sm font-medium transition-colors ${
                  activeTab === tab.value
                    ? 'bg-primary text-primary-foreground'
                    : 'bg-white text-gray-600 border border-gray-200 hover:bg-gray-50'
                }`}
              >
                {tab.label}
              </button>
            ))}
          </div>

          {/* Orders list */}
          {ordersLoading ? (
            <div className="text-center py-16">
              <div className="animate-spin h-8 w-8 mx-auto border-4 border-primary border-t-transparent rounded-full mb-4" />
              <p className="text-gray-500">Buyurtmalar yuklanmoqda...</p>
            </div>
          ) : filteredOrders.length === 0 ? (
            <div className="text-center py-16">
              <Package className="h-16 w-16 mx-auto text-gray-300 mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-1">Buyurtmalar mavjud emas</h3>
              <p className="text-gray-500">Hozircha hech qanday buyurtma yo'q</p>
            </div>
          ) : (
            <div className="space-y-4">
              {filteredOrders.map((order) => (
                <div
                  key={order.id}
                  className="bg-white rounded-2xl border border-gray-100 overflow-hidden hover:shadow-md transition-shadow"
                >
                  <div className="p-4 flex gap-4">
                    {/* Product image */}
                    <div className="shrink-0 w-20 h-20 sm:w-24 sm:h-24 rounded-xl bg-gray-100 overflow-hidden">
                      {order.product.images[0] && (
                        <img
                          src={order.product.images[0].image}
                          alt={order.product.title}
                          className="w-full h-full object-cover"
                        />
                      )}
                    </div>

                    {/* Info */}
                    <div className="flex-1 min-w-0">
                      <div className="flex items-start justify-between gap-2">
                        <div className="min-w-0">
                          <h3 className="text-sm font-semibold text-gray-900 truncate">
                            {order.product.title}
                          </h3>
                          <p className="text-xs text-gray-500 mt-0.5">
                            {order.seller.company_name}
                          </p>
                        </div>
                        <Badge variant={statusVariant[order.status]}>
                          {statusTabs.find((t) => t.value === order.status)?.label}
                        </Badge>
                      </div>

                      <div className="flex items-center gap-3 mt-2 text-sm text-gray-600">
                        <span>Miqdor: {order.quantity} ta</span>
                        <span className="text-gray-300">|</span>
                        <span className="font-semibold text-gray-900">
                          {formatPrice(order.total_price)}
                        </span>
                      </div>

                      <div className="flex items-center justify-between mt-2">
                        <span className="text-xs text-gray-400">
                          {new Date(order.created_at).toLocaleDateString('uz-UZ', {
                            day: 'numeric', month: 'long', year: 'numeric',
                          })}
                        </span>
                        <ChevronRight className="h-4 w-4 text-gray-300" />
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </main>
      <Footer />
      <MobileBottomNav />
    </div>
  )
}
