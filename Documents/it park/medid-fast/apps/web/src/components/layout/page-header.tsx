'use client'

import { useRouter } from 'next/navigation'
import { ChevronLeft } from 'lucide-react'

interface PageHeaderProps {
  title: string
  subtitle?: string
  icon?: React.ReactNode
  actions?: React.ReactNode
  backTo?: string
}

export function PageHeader({ title, subtitle, icon, actions, backTo }: PageHeaderProps) {
  const router = useRouter()

  return (
    <div className="shrink-0 px-4 sm:px-6 py-3 sm:py-4 border-b border-medid-border bg-white">
      <div className="flex items-center justify-between max-w-7xl mx-auto">
        <div className="flex items-center gap-3 min-w-0">
          {backTo && (
            <button
              onClick={() => backTo ? router.push(backTo) : router.back()}
              className="p-1.5 -ml-1.5 rounded-lg hover:bg-gray-100 text-medid-muted hover:text-medid-text transition-colors"
              aria-label="Orqaga"
            >
              <ChevronLeft className="h-5 w-5" />
            </button>
          )}
          {icon && <div className="shrink-0">{icon}</div>}
          <div className="min-w-0">
            <h1 className="text-base sm:text-lg font-bold text-medid-text truncate">{title}</h1>
            {subtitle && <p className="text-xs sm:text-sm text-medid-muted truncate">{subtitle}</p>}
          </div>
        </div>
        {actions && <div className="flex items-center gap-2 shrink-0">{actions}</div>}
      </div>
    </div>
  )
}
