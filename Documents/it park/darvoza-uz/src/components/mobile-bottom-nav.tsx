'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { Home, Grid, Heart, Package, User } from 'lucide-react'
import { cn } from '@/lib/utils'
import { useI18n } from '@/lib/i18n'

const tabs = [
  { href: '/', label: 'home', icon: Home },
  { href: '/categories', label: 'categories', icon: Grid },
  { href: '/favorites', label: 'favorites', icon: Heart },
  { href: '/orders', label: 'orders', icon: Package },
  { href: '/profile', label: 'profile', icon: User },
]

export function MobileBottomNav() {
  const pathname = usePathname()
  const { t } = useI18n()

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-50 bg-white border-t lg:hidden safe-area-bottom">
      <div className="flex items-center justify-around h-14">
        {tabs.map((tab) => {
          const Icon = tab.icon
          const isActive = pathname === tab.href

          return (
            <Link
              key={tab.href}
              href={tab.href}
              className={cn(
                'flex flex-col items-center justify-center gap-0.5 px-3 py-1 rounded-lg transition-colors min-w-[60px]',
                isActive
                  ? 'text-primary'
                  : 'text-gray-400 hover:text-gray-600',
              )}
            >
              <Icon className={cn('h-5 w-5', isActive && 'fill-current')} />
              <span className="text-[10px] font-medium">{t(tab.label)}</span>
            </Link>
          )
        })}
      </div>
    </nav>
  )
}
