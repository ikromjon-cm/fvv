'use client'

import { usePathname } from 'next/navigation'
import Link from 'next/link'
import { useState } from 'react'
import {
  Menu, X, Shield, LayoutDashboard, Map, MessageSquare, AlertTriangle,
  Wifi, TrendingUp, Cpu, Activity, User,
} from 'lucide-react'
import { navItems, getUserRole } from '@/lib/roles'

const iconMap: Record<string, typeof Shield> = {
  '/dashboard': LayoutDashboard,
  '/map': Map,
  '/mchs': Shield,
  '/sms': MessageSquare,
  '/sos': AlertTriangle,
  '/iot': Wifi,
  '/analytics': TrendingUp,
  '/integration': Cpu,
  '/admin': Activity,
  '/profile': User,
}

export function BottomNav() {
  const pathname = usePathname()
  const role = getUserRole()
  const items = role ? navItems[role].slice(0, 5) : []

  if (pathname === '/auth/login' || items.length === 0) return null

  const isActive = (href: string) => pathname === href || pathname.startsWith(href + '/')

  return (
    <nav className="shrink-0 md:hidden flex items-center justify-around bg-white border-t border-medid-border z-50">
      {items.map((item) => {
        const Icon = iconMap[item.href] || Shield
        const active = isActive(item.href)
        return (
          <Link
            key={item.href}
            href={item.href}
            className={`flex flex-col items-center gap-0.5 py-1.5 px-2 min-w-0 transition-colors ${
              active ? 'text-[#0066FF]' : 'text-medid-muted'
            }`}
          >
            <Icon className="h-5 w-5" />
            <span className="text-[9px] font-medium truncate w-full text-center">{item.label}</span>
          </Link>
        )
      })}
    </nav>
  )
}

export function SidebarDrawer() {
  const pathname = usePathname()
  const [open, setOpen] = useState(false)
  const role = getUserRole()
  const items = role ? navItems[role] : []

  if (pathname === '/auth/login') return null

  const isActive = (href: string) => pathname === href || pathname.startsWith(href + '/')

  return (
    <>
      <button
        onClick={() => setOpen(true)}
        className="md:hidden fixed top-3 left-3 z-30 p-2 rounded-lg bg-medid-sidebar text-medid-sidebar-text shadow-lg"
        aria-label="Menyu"
      >
        <Menu className="h-5 w-5" />
      </button>

      {open && <div className="fixed inset-0 bg-black/50 z-40" onClick={() => setOpen(false)} />}

      <aside className={`fixed inset-y-0 left-0 z-50 w-64 bg-medid-sidebar text-medid-sidebar-text transform transition-transform ${
        open ? 'translate-x-0' : '-translate-x-full'
      }`}>
        <div className="flex items-center justify-between px-4 h-14 border-b border-medid-sidebar-border">
          <div className="flex items-center gap-2">
            <div className="flex items-center justify-center w-8 h-8 rounded-lg bg-[#0066FF]">
              <Shield className="h-4 w-4 text-white" />
            </div>
            <p className="text-sm font-bold text-medid-sidebar-text">FVV Ekotizimi</p>
          </div>
          <button onClick={() => setOpen(false)} className="p-1 rounded hover:bg-medid-sidebar-hover">
            <X className="h-5 w-5" />
          </button>
        </div>
        <nav className="p-2 space-y-0.5">
          {items.map((item) => {
            const Icon = iconMap[item.href] || Shield
            const active = isActive(item.href)
            return (
              <Link
                key={item.href}
                href={item.href}
                onClick={() => setOpen(false)}
                className={`flex items-center gap-2.5 px-3 py-2.5 rounded-lg text-sm transition-colors ${
                  active
                    ? 'bg-medid-sidebar-active text-medid-sidebar-text font-medium'
                    : 'text-medid-sidebar-muted hover:text-medid-sidebar-text hover:bg-medid-sidebar-hover'
                }`}
              >
                <Icon className="h-4 w-4 shrink-0" />
                <span>{item.label}</span>
              </Link>
            )
          })}
        </nav>
      </aside>
    </>
  )
}
