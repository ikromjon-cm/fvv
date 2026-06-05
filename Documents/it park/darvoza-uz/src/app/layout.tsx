import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { Providers } from '@/components/providers'

const inter = Inter({ subsets: ['latin', 'cyrillic'], variable: '--font-inter' })

import type { Viewport } from 'next'

export const metadata: Metadata = {
  title: 'Darvoza.uz — Darvozalar, eshiklar va panjaralar',
  description: "Eng sifatli darvozalar, eshiklar va panjaralar. O'zbekiston bo'ylab yetkazib berish.",
  manifest: '/manifest.json',
  appleWebApp: { capable: true, statusBarStyle: 'default', title: 'Darvoza.uz' },
  openGraph: {
    title: 'Darvoza.uz',
    description: "Eng sifatli darvozalar, eshiklar va panjaralar",
    type: 'website',
    locale: 'uz_UZ',
  },
}

export const viewport: Viewport = {
  themeColor: '#f59e0b',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="uz" suppressHydrationWarning>
      <head>
        <link rel="apple-touch-icon" href="/icons/icon-192.png" />
      </head>
      <body className={`${inter.variable} font-sans`}>
        <Providers>{children}</Providers>
      </body>
    </html>
  )
}
