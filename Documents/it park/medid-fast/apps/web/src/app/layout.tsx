import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import 'leaflet/dist/leaflet.css'
import { Providers } from './providers'
import { Sidebar } from '@/components/layout/sidebar'
import { AndroidEmulator } from '@/components/layout/android-emulator'
import { ErrorBoundary } from '@/components/shared/error-boundary'

const inter = Inter({ subsets: ['latin', 'cyrillic'] })

export const metadata: Metadata = {
  title: 'FVV — Favqulodda Vaziyatlar Ekotizimi',
  description: "FVV ko'p funksiyali integratsiyalashgan ekotizimi",
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="uz" suppressHydrationWarning>
      <body className={`${inter.className} overflow-x-hidden`}>
        <Providers>
          <ErrorBoundary>
            <div className="flex h-screen overflow-hidden bg-medid-surface">
              <Sidebar />
              <main className="flex-1 overflow-y-auto">
                {children}
              </main>
              <AndroidEmulator />
            </div>
          </ErrorBoundary>
        </Providers>
      </body>
    </html>
  )
}
