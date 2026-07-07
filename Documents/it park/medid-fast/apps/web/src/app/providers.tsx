'use client'

import { useEffect, type ReactNode } from 'react'
import { ToastProvider } from '@/components/shared/toast'
import { AuthGuard } from '@/components/shared/auth-guard'
import { initTheme } from '@/store/themeStore'

export function Providers({ children }: { children: ReactNode }) {
  useEffect(() => { initTheme() }, [])

  return (
    <ToastProvider>
      <AuthGuard>{children}</AuthGuard>
    </ToastProvider>
  )
}
