'use client'

import { useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { Shield } from 'lucide-react'
import { getUserRole, getHomePage } from '@/lib/roles'

export default function Home() {
  const router = useRouter()
  useEffect(() => {
    const role = getUserRole()
    router.replace(role ? getHomePage(role) : '/auth/login')
  }, [router])
  return (
    <div className="min-h-screen bg-medid-navy flex items-center justify-center">
      <div className="flex flex-col items-center gap-3">
        <Shield className="h-10 w-10 text-[#0066FF] animate-pulse" />
        <p className="text-white/60 text-sm">Yuklanmoqda...</p>
      </div>
    </div>
  )
}
