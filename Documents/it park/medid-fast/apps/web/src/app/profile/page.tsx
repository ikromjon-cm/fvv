'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { motion } from 'framer-motion'
import { User, Shield, LogOut, ChevronRight } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'

export default function ProfilePage() {
  const router = useRouter()
  const [user, setUser] = useState<{ firstName: string; lastName: string; email: string; role: string } | null>(null)
  const [stats, setStats] = useState({ total: 0, resolved: 0, approved: 0 })

  useEffect(() => {
    try {
      const stored = localStorage.getItem('fvv_user')
      if (stored) {
        setUser(JSON.parse(stored))
      } else {
        router.push('/auth/login')
        return
      }
      const raw = localStorage.getItem('fvv_incidents')
      const incidents = raw ? JSON.parse(raw) : []
      setStats({
        total: incidents.length,
        resolved: incidents.filter((i: any) => i.status === 'RESOLVED').length,
        approved: incidents.filter((i: any) => i.validation_status === 'APPROVED').length,
      })
    } catch (e) { console.error(e) }
  }, [router])

  const handleLogout = () => {
    localStorage.removeItem('fvv_user')
    localStorage.removeItem('fvv_token')
    router.push('/auth/login')
  }

  if (!user) {
    return (
      <div className="min-h-screen bg-medid-surface flex items-center justify-center">
        <div className="flex flex-col items-center gap-3">
          <User className="h-8 w-8 text-[#0066FF] animate-pulse" />
          <p className="text-sm text-medid-muted">Yuklanmoqda...</p>
        </div>
      </div>
    )
  }

  const roleLabel = user.role === 'admin' ? 'Admin' : 'Xodim'

  return (
    <div className="p-6">
      <div className="max-w-2xl mx-auto">
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}>
          <div className="rounded-xl border border-medid-border bg-medid-card p-6 text-center">
            <div className="w-20 h-20 rounded-full bg-[#0066FF]/10 flex items-center justify-center mx-auto mb-4">
              <User className="h-10 w-10 text-[#0066FF]" />
            </div>
            <h2 className="text-xl font-bold text-medid-text">{user.firstName} {user.lastName}</h2>
            <p className="text-sm text-medid-muted">{user.email}</p>
            <div className="mt-3">
              <Badge variant={user.role === 'admin' ? 'danger' : 'info'}>{roleLabel}</Badge>
            </div>
          </div>
        </motion.div>

        <div className="grid grid-cols-3 gap-3 mt-6">
          <div className="rounded-xl border border-medid-border bg-medid-card p-4 text-center">
            <p className="text-2xl font-bold text-medid-text tabular-nums">{stats.total}</p>
            <p className="text-xs text-medid-muted mt-1">Jami hodisalar</p>
          </div>
          <div className="rounded-xl border border-medid-border bg-medid-card p-4 text-center">
            <p className="text-2xl font-bold text-medid-text tabular-nums">{stats.resolved}</p>
            <p className="text-xs text-medid-muted mt-1">Hal qilingan</p>
          </div>
          <div className="rounded-xl border border-medid-border bg-medid-card p-4 text-center">
            <p className="text-2xl font-bold text-medid-text tabular-nums">{stats.approved}</p>
            <p className="text-xs text-medid-muted mt-1">Tasdiqlangan</p>
          </div>
        </div>

        <div className="mt-6 space-y-2">
          <Button variant="outline" className="w-full justify-between" onClick={() => router.push('/dashboard')}>
            <span className="flex items-center gap-2"><Shield className="h-4 w-4" /> Dashboard</span>
            <ChevronRight className="h-4 w-4" />
          </Button>
          <Button
            variant="outline"
            className="w-full justify-between text-[#DC2626] border-[#DC2626]/20 hover:bg-[#DC2626]/5"
            onClick={handleLogout}
          >
            <span className="flex items-center gap-2"><LogOut className="h-4 w-4" /> Chiqish</span>
            <ChevronRight className="h-4 w-4" />
          </Button>
        </div>
      </div>
    </div>
  )
}
