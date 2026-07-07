'use client'

import { useState } from 'react'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import {
  LayoutDashboard, Map, Shield, MessageSquare, Cpu, Activity,
  Wifi, AlertTriangle, TrendingUp, User, ChevronLeft, Menu, X,
} from 'lucide-react'

const navItems = [
  { href: '/dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { href: '/map', label: 'Xarita', icon: Map },
  { href: '/mchs', label: 'MCHS', icon: Shield },
  { href: '/sms', label: 'SMS', icon: MessageSquare },
  { href: '/sos', label: 'SOS', icon: AlertTriangle },
  { href: '/iot', label: 'IoT', icon: Wifi },
  { href: '/analytics', label: 'Analitika', icon: TrendingUp },
  { href: '/integration', label: 'API', icon: Cpu },
  { href: '/admin', label: 'Admin', icon: Activity },
  { href: '/profile', label: 'Profil', icon: User },
]

export default function AppShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname()
  const [sidebarOpen, setSidebarOpen] = useState(false)

  const isActive = (href: string) => pathname === href || pathname.startsWith(href + '/')

  return (
    <div className="h-screen flex overflow-hidden bg-medid-surface">
      {/* Desktop Sidebar */}
      <aside className="hidden md:flex md:w-56 lg:w-64 shrink-0 flex-col bg-medid-sidebar text-medid-sidebar-text">
        <div className="shrink-0 px-4 h-14 flex items-center gap-2 border-b border-medid-sidebar-border">
          <div className="flex items-center justify-center w-8 h-8 rounded-lg bg-[#0066FF]">
            <Shield className="h-4 w-4 text-white" />
          </div>
          <div>
            <p className="text-sm font-bold leading-tight text-medid-sidebar-text">FVV Ekotizimi</p>
            <p className="text-[10px] text-medid-sidebar-muted">Uychi tumani</p>
          </div>
        </div>
        <nav className="flex-1 overflow-y-auto p-2 space-y-0.5">
          {navItems.map((item) => {
            const Icon = item.icon
            const active = isActive(item.href)
            return (
              <Link
                key={item.href}
                href={item.href}
                onClick={() => setSidebarOpen(false)}
                className={`flex items-center gap-2.5 px-3 py-2 rounded-lg text-sm transition-colors ${
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
        <div className="shrink-0 px-4 py-3 border-t border-medid-sidebar-border text-[10px] text-medid-sidebar-muted">
          UZINC Engineering v2.1
        </div>
      </aside>

      {/* Mobile sidebar overlay */}
      {sidebarOpen && (
        <div className="fixed inset-0 bg-black/50 z-40 md:hidden" onClick={() => setSidebarOpen(false)} />
      )}

      {/* Mobile sidebar drawer */}
      <aside className={`fixed inset-y-0 left-0 z-50 w-64 bg-medid-sidebar text-medid-sidebar-text transform transition-transform md:hidden ${
        sidebarOpen ? 'translate-x-0' : '-translate-x-full'
      }`}>
        <div className="flex items-center justify-between px-4 h-14 border-b border-medid-sidebar-border">
          <div className="flex items-center gap-2">
            <div className="flex items-center justify-center w-8 h-8 rounded-lg bg-[#0066FF]">
              <Shield className="h-4 w-4 text-white" />
            </div>
            <p className="text-sm font-bold text-medid-sidebar-text">FVV Ekotizimi</p>
          </div>
          <button onClick={() => setSidebarOpen(false)} className="p-1 rounded hover:bg-medid-sidebar-hover">
            <X className="h-5 w-5" />
          </button>
        </div>
        <nav className="p-2 space-y-0.5">
          {navItems.map((item) => {
            const Icon = item.icon
            const active = isActive(item.href)
            return (
              <Link
                key={item.href}
                href={item.href}
                onClick={() => setSidebarOpen(false)}
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

      {/* Main content */}
      <div className="flex-1 flex flex-col min-w-0">
        {/* Mobile top bar */}
        <div className="shrink-0 md:hidden flex items-center justify-between px-3 h-12 bg-medid-sidebar text-medid-sidebar-text">
          <button onClick={() => setSidebarOpen(true)} className="p-1.5 rounded-lg hover:bg-medid-sidebar-hover">
            <Menu className="h-5 w-5" />
          </button>
          <div className="flex items-center gap-2">
            <div className="flex items-center justify-center w-6 h-6 rounded-md bg-[#0066FF]">
              <Shield className="h-3 w-3 text-white" />
            </div>
            <span className="text-sm font-bold text-medid-sidebar-text">FVV</span>
          </div>
          <div className="w-8" />
        </div>

        {/* Page content */}
        <main className="flex-1 overflow-y-auto">
          {children}
        </main>

        {/* Mobile bottom nav */}
        <nav className="shrink-0 md:hidden flex items-center justify-around bg-white border-t border-medid-border safe-area-pb">
          {navItems.slice(0, 5).map((item) => {
            const Icon = item.icon
            const active = isActive(item.href)
            return (
              <Link
                key={item.href}
                href={item.href}
                className={`flex flex-col items-center gap-0.5 py-1.5 px-2 min-w-0 ${
                  active ? 'text-[#0066FF]' : 'text-medid-muted'
                }`}
              >
                <Icon className="h-5 w-5" />
                <span className="text-[9px] font-medium truncate w-full text-center">{item.label}</span>
              </Link>
            )
          })}
        </nav>
      </div>
    </div>
  )
}
