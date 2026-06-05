'use client'

import type { ReactNode } from 'react'
import { ThemeProvider } from './theme-provider'
import { AuthProvider } from '@/lib/auth'
import { I18nProvider } from '@/lib/i18n'

export function Providers({ children }: { children: ReactNode }) {
  return (
    <ThemeProvider>
      <AuthProvider>
        <I18nProvider>
          {children}
        </I18nProvider>
      </AuthProvider>
    </ThemeProvider>
  )
}
