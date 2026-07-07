'use client'

import { useEffect, useState, type ReactNode } from 'react'
import { useRouter, usePathname } from 'next/navigation'
import { Shield } from 'lucide-react'
import { getUserRole, canAccess, getHomePage, type Role } from '@/lib/roles'

export function AuthGuard({ children }: { children: ReactNode }) {
  const router = useRouter()
  const pathname = usePathname()
  const [authorized, setAuthorized] = useState(false)

  useEffect(() => {
    if (pathname === '/auth/login') {
      setAuthorized(true)
      return
    }
    const role = getUserRole()
    if (!role) {
      router.replace('/auth/login')
      return
    }
    if (!canAccess(role, pathname)) {
      router.replace(getHomePage(role))
      return
    }
    setAuthorized(true)
  }, [pathname, router])

  if (!authorized) {
    return (
      <div className="min-h-screen bg-medid-navy flex items-center justify-center">
        <div className="flex flex-col items-center gap-3">
          <Shield className="h-8 w-8 text-[#0066FF] animate-pulse" />
          <p className="text-sm text-white/60">Tekshirilmoqda...</p>
        </div>
      </div>
    )
  }

  return <>{children}</>
}
