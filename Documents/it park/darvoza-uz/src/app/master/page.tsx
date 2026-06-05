'use client'

import Link from 'next/link'
import {
  Wrench, CheckCircle2, Clock, Star, PackageOpen,
} from 'lucide-react'
import { Navbar } from '@/components/navbar'
import { Footer } from '@/components/footer'
import { MobileBottomNav } from '@/components/mobile-bottom-nav'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { useAuth } from '@/lib/auth'
import type { OrderStatus } from '@/types'

interface ServiceRequest {
  id: string
  client: string
  clientPhone: string
  service: string
  status: OrderStatus
  date: string
  amount: number
}

const mockRequests: ServiceRequest[] = [
  { id: '#SRV-001', client: 'Ali Valiyev', clientPhone: '+998901234567', service: 'Surma darvoza o\'rnatish', status: 'new', date: '2025-06-04', amount: 300000 },
  { id: '#SRV-002', client: 'Botir Eshonov', clientPhone: '+998901112233', service: 'Avtomatik darvoza sozlash', status: 'producing', date: '2025-06-03', amount: 500000 },
  { id: '#SRV-003', client: 'Jasur Rahimov', clientPhone: '+998902223344', service: 'Panjara ta\'mirlash', status: 'completed', date: '2025-06-02', amount: 200000 },
  { id: '#SRV-004', client: 'Sardor Ismoilov', clientPhone: '+998903334455', service: 'Darvoza bo\'yash', status: 'installing', date: '2025-06-01', amount: 150000 },
  { id: '#SRV-005', client: 'Shoxruh Mirzayev', clientPhone: '+998904445566', service: 'Eshik qulfini almashtirish', status: 'cancelled', date: '2025-05-30', amount: 80000 },
]

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

export default function MasterPage() {
  const { user, isLoading } = useAuth()

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin h-8 w-8 border-4 border-primary border-t-transparent rounded-full" />
      </div>
    )
  }

  if (!user || user.role !== 'master') {
    return (
      <div className="min-h-screen flex flex-col">
        <Navbar />
        <div className="flex-1 flex items-center justify-center">
          <div className="text-center p-8">
            <Wrench className="h-16 w-16 mx-auto text-gray-300 mb-4" />
            <h2 className="text-xl font-semibold text-gray-900 mb-2">Ruxsat berilmagan</h2>
            <p className="text-gray-500 mb-6">Usta paneliga faqat ustalar kirishi mumkin</p>
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

  const completedOrders = mockRequests.filter((r) => r.status === 'completed').length
  const pendingRequests = mockRequests.filter((r) => r.status === 'new' || r.status === 'producing').length
  const avgRating = 4.6
  const totalEarned = mockRequests.reduce((sum, r) => sum + (r.status !== 'cancelled' ? r.amount : 0), 0)

  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Navbar />
      <main className="flex-1 pb-20 lg:pb-0">
        <div className="mx-auto max-w-7xl px-4 py-6 space-y-6">
          <div className="flex items-center justify-between">
            <h1 className="text-2xl font-bold text-gray-900">Usta paneli</h1>
            <Badge variant="default" className="gap-1">
              <Wrench className="h-3 w-3" />
              Usta
            </Badge>
          </div>

          {/* Stats */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <Card>
              <CardContent className="p-6 flex items-center gap-4">
                <div className="w-12 h-12 rounded-xl bg-green-500 flex items-center justify-center">
                  <CheckCircle2 className="h-6 w-6 text-white" />
                </div>
                <div>
                  <p className="text-sm text-gray-500">Yakunlangan ishlar</p>
                  <p className="text-2xl font-bold text-gray-900">{completedOrders}</p>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-6 flex items-center gap-4">
                <div className="w-12 h-12 rounded-xl bg-primary flex items-center justify-center">
                  <Clock className="h-6 w-6 text-white" />
                </div>
                <div>
                  <p className="text-sm text-gray-500">Kutilayotgan so'rovlar</p>
                  <p className="text-2xl font-bold text-gray-900">{pendingRequests}</p>
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
                  <p className="text-2xl font-bold text-gray-900">{avgRating.toFixed(1)}</p>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-6 flex items-center gap-4">
                <div className="w-12 h-12 rounded-xl bg-blue-500 flex items-center justify-center">
                  <PackageOpen className="h-6 w-6 text-white" />
                </div>
                <div>
                  <p className="text-sm text-gray-500">Jami buyurtmalar</p>
                  <p className="text-2xl font-bold text-gray-900">{mockRequests.length}</p>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Service requests */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base">Xizmat ko'rsatish so'rovlari</CardTitle>
            </CardHeader>
            <CardContent className="p-0">
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="border-b border-gray-100">
                      <th className="text-left p-4 font-medium text-gray-500">ID</th>
                      <th className="text-left p-4 font-medium text-gray-500">Mijoz</th>
                      <th className="text-left p-4 font-medium text-gray-500">Xizmat</th>
                      <th className="text-left p-4 font-medium text-gray-500">Summa</th>
                      <th className="text-left p-4 font-medium text-gray-500">Holat</th>
                      <th className="text-left p-4 font-medium text-gray-500">Sana</th>
                    </tr>
                  </thead>
                  <tbody>
                    {mockRequests.map((req) => (
                      <tr key={req.id} className="border-b border-gray-50 hover:bg-gray-50">
                        <td className="p-4 font-medium text-gray-900">{req.id}</td>
                        <td className="p-4">
                          <div className="flex items-center gap-2">
                            <Avatar className="h-7 w-7">
                              <AvatarFallback className="bg-primary/10 text-primary text-xs">
                                {req.client.charAt(0)}
                              </AvatarFallback>
                            </Avatar>
                            <div>
                              <p className="font-medium text-gray-900">{req.client}</p>
                              <p className="text-xs text-gray-400">{req.clientPhone}</p>
                            </div>
                          </div>
                        </td>
                        <td className="p-4 text-gray-700">{req.service}</td>
                        <td className="p-4 font-medium text-gray-900">
                          {new Intl.NumberFormat('uz-UZ').format(req.amount)} so'm
                        </td>
                        <td className="p-4">
                          <Badge
                            variant={
                              req.status === 'cancelled'
                                ? 'destructive'
                                : req.status === 'completed'
                                  ? 'default'
                                  : 'secondary'
                            }
                          >
                            {statusLabels[req.status]}
                          </Badge>
                        </td>
                        <td className="p-4 text-gray-500">{req.date}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </CardContent>
          </Card>
        </div>
      </main>
      <Footer />
      <MobileBottomNav />
    </div>
  )
}
