'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { motion } from 'framer-motion'
import { Shield, User, Settings } from 'lucide-react'
import { getHomePage } from '@/lib/roles'

const roles = [
  { id: 'admin', label: 'Admin', icon: Settings, color: '#F472B6', desc: "To'liq boshqaruv, xodimlar nazorati, tizim sozlamalari" },
  { id: 'employee', label: 'Xodim', icon: User, color: '#3B82F6', desc: 'MCHS inspeksiya, hodisalar, xarita, profil' },
]

export default function LoginPage() {
  const router = useRouter()
  const [loading, setLoading] = useState(false)

  const handleRoleSelect = async (roleId: string) => {
    setLoading(true)
    if (typeof window !== 'undefined') {
      const user = {
        id: `user-${roleId}`,
        email: `${roleId}@fvv.uz`,
        firstName: roleId === 'admin' ? 'Admin' : 'Xodim',
        lastName: '',
        role: roleId,
      }
      localStorage.setItem('fvv_user', JSON.stringify(user))
      localStorage.setItem('fvv_token', 'mock-token-' + roleId)
    }
    await new Promise((r) => setTimeout(r, 500))
    setLoading(false)
    router.push(getHomePage(roleId as any))
  }

  return (
    <div className="h-screen flex overflow-hidden bg-medid-surface">
      <div className="hidden lg:flex lg:w-1/2 relative bg-medid-navy overflow-hidden items-center justify-center">
        <div className="absolute inset-0">
          <svg className="absolute top-0 right-0 w-96 h-96 text-[#0066FF]/5" viewBox="0 0 400 400">
            <circle cx="300" cy="100" r="180" fill="currentColor" />
            <circle cx="100" cy="300" r="120" fill="currentColor" opacity="0.6" />
          </svg>
          <div className="absolute top-1/4 right-1/4 w-64 h-64 rounded-full bg-[#0066FF]/10 blur-3xl" />
          <div className="absolute bottom-1/3 left-1/3 w-48 h-48 rounded-full bg-[#DC2626]/10 blur-3xl" />
          <div className="absolute inset-0 bg-gradient-to-br from-medid-navy via-medid-navy/95 to-medid-navy" />
        </div>
        <div className="relative z-10 text-center px-12">
          <div className="inline-flex items-center justify-center w-20 h-20 rounded-2xl bg-gradient-to-br from-[#0066FF] to-[#0052CC] shadow-lg mb-8">
            <Shield className="h-10 w-10 text-white" />
          </div>
          <h1 className="text-4xl font-bold text-white mb-3">FVV Ekotizimi</h1>
          <p className="text-lg text-gray-400 mb-6 max-w-md leading-relaxed">
            Favqulodda Vaziyatlar Vazirligi — Ko'p funksiyali integratsiyalashgan platforma
          </p>
          <div className="grid grid-cols-3 gap-3 max-w-sm mx-auto">
            {['Hududiy monitoring', 'MCHS inspeksiya', 'Jonli xarita', 'SMS xabarnoma', 'IoT telemetriya', 'Analitika'].map((f) => (
              <div key={f} className="p-3 rounded-xl bg-white/5 border border-white/10">
                <p className="text-xs text-gray-400">{f}</p>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="flex-1 flex items-center justify-center p-6 lg:p-12 overflow-y-auto">
        <div className="w-full max-w-md">
          <div className="flex lg:hidden items-center gap-3 mb-8 justify-center">
            <div className="flex items-center justify-center w-10 h-10 rounded-xl bg-[#0066FF]">
              <Shield className="h-5 w-5 text-white" />
            </div>
            <div>
              <h1 className="text-lg font-bold text-medid-text">FVV Ekotizimi</h1>
              <p className="text-xs text-medid-muted">Favqulodda Vaziyatlar Vazirligi</p>
            </div>
          </div>

          <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}>
            <h2 className="text-2xl font-bold text-medid-text mb-1">Xush kelibsiz</h2>
            <p className="text-medid-muted text-sm mb-6">Tizimga kirish uchun ro'lingizni tanlang</p>
          </motion.div>

          <div className="space-y-3">
            {roles.map((role, idx) => {
              const Icon = role.icon
              return (
                <motion.button
                  key={role.id}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: idx * 0.1 }}
                  onClick={() => handleRoleSelect(role.id)}
                  disabled={loading}
                  className="group relative flex items-center gap-4 w-full rounded-xl border px-5 py-4 text-left transition-all duration-200 border-medid-border bg-medid-card hover:border-[#0066FF]/50 hover:shadow-md disabled:opacity-50"
                >
                  <div
                    className="flex items-center justify-center w-12 h-12 rounded-xl shrink-0"
                    style={{ backgroundColor: `${role.color}15`, color: role.color }}
                  >
                    <Icon className="h-6 w-6" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-base font-semibold text-medid-text">{role.label}</p>
                    <p className="text-xs text-medid-muted">{role.desc}</p>
                  </div>
                  <div className="text-medid-muted group-hover:text-[#0066FF] transition-colors">
                    <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" /></svg>
                  </div>
                </motion.button>
              )
            })}
          </div>
        </div>
      </div>
    </div>
  )
}
