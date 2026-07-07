'use client'

import { usePathname, useRouter } from 'next/navigation'
import Link from 'next/link'
import { useState, useEffect } from 'react'
import {
  LayoutDashboard, Map, AlertTriangle, Users, Shield, Activity,
  MessageSquare, Wifi, TrendingUp, Cpu, Play, User, LogOut,
  Sun, Moon, ChevronLeft, ChevronRight, Menu, X,
} from 'lucide-react'
import { navItems, getUserRole, type Role } from '@/lib/roles'
import { useThemeStore } from '@/store/themeStore'

const iconMap: Record<string, typeof Shield> = {
  LayoutDashboard, Map, AlertTriangle, Users, Shield, Activity,
  MessageSquare, Wifi, TrendingUp, Cpu, Play, User,
}

export function Sidebar() {
  const pathname = usePathname()
  const router = useRouter()
  const [mobileOpen, setMobileOpen] = useState(false)
  const [collapsed, setCollapsed] = useState(false)
  const [userName, setUserName] = useState('')
  const [role, setRole] = useState<Role | null>(null)
  const { dark, toggle: toggleTheme } = useThemeStore()

  useEffect(() => {
    const r = getUserRole()
    setRole(r)
    try {
      const raw = localStorage.getItem('fvv_user')
      if (raw) {
        const u = JSON.parse(raw)
        setUserName(u.firstName || u.email || 'Foydalanuvchi')
      }
    } catch {}
  }, [pathname])

  const handleLogout = () => {
    localStorage.removeItem('fvv_user')
    localStorage.removeItem('fvv_token')
    router.push('/auth/login')
  }

  if (pathname === '/auth/login') return null
  if (!role) return null

  const items = navItems[role]
  const isActive = (href: string) => pathname === href || pathname.startsWith(href + '/')

  const sidebarContent = (
    <div className={`flex flex-col h-full ${collapsed ? 'w-16' : 'w-64'} transition-all duration-200`}>
      {/* Logo */}
      <div className={`shrink-0 flex items-center border-b border-medid-sidebar-border ${collapsed ? 'justify-center px-2' : 'gap-2.5 px-4'} h-16`}>
        <div className="relative flex items-center justify-center w-9 h-9 rounded-xl bg-gradient-to-br from-medid-primary to-medid-primary-dark shadow-[0_4px_12px_-2px_rgba(37,99,235,0.6),inset_0_1px_0_rgba(255,255,255,0.25)] shrink-0">
          <Shield className="h-[18px] w-[18px] text-white" strokeWidth={2.25} />
        </div>
        {!collapsed && (
          <>
            <div className="min-w-0 flex-1">
              <p className="font-display text-[15px] font-bold text-medid-sidebar-text leading-tight tracking-tight">FVV Ekotizimi</p>
              <p className="text-[10px] text-medid-sidebar-muted tracking-wide">Uychi tumani</p>
            </div>
            <button onClick={() => setCollapsed(true)} className="p-1.5 rounded-lg hover:bg-medid-sidebar-hover text-medid-sidebar-muted hover:text-medid-sidebar-text transition-colors">
              <ChevronLeft className="h-4 w-4" />
            </button>
          </>
        )}
        {collapsed && (
          <button onClick={() => setCollapsed(false)} className="p-1.5 rounded-lg hover:bg-medid-sidebar-hover text-medid-sidebar-muted hover:text-medid-sidebar-text transition-colors">
            <ChevronRight className="h-4 w-4" />
          </button>
        )}
      </div>

      {/* Navigation */}
      <nav className={`flex-1 overflow-y-auto scrollbar-thin ${collapsed ? 'px-2 py-3 space-y-1' : 'px-3 py-3 space-y-0.5'}`}>
        {!collapsed && (
          <p className="px-3 pb-1.5 pt-1 text-[10px] font-medium uppercase tracking-[0.18em] text-medid-sidebar-muted">Menyu</p>
        )}
        {items.map((item) => {
          const Icon = iconMap[item.icon] || Shield
          const active = isActive(item.href)
          return (
            <Link
              key={item.href}
              href={item.href}
              onClick={() => setMobileOpen(false)}
              className={`group relative flex items-center rounded-xl transition-[background-color,color] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] ${
                collapsed ? 'justify-center p-2.5' : 'gap-3 px-3 py-2.5'
              } ${
                active
                  ? 'bg-medid-sidebar-active text-medid-sidebar-text font-semibold'
                  : 'text-medid-sidebar-muted hover:text-medid-sidebar-text hover:bg-medid-sidebar-hover'
              }`}
              title={collapsed ? item.label : undefined}
            >
              {active && !collapsed && (
                <span className="absolute left-0 top-1/2 -translate-y-1/2 h-5 w-[3px] rounded-full bg-medid-primary shadow-[0_0_10px_rgba(37,99,235,0.8)]" />
              )}
              <Icon
                className={`${collapsed ? 'h-5 w-5' : 'h-[18px] w-[18px]'} shrink-0 transition-colors ${active ? 'text-medid-primary' : 'text-current'}`}
                strokeWidth={active ? 2.25 : 1.75}
              />
              {!collapsed && <span className="text-sm truncate">{item.label}</span>}
            </Link>
          )
        })}
      </nav>

      {/* Bottom */}
      <div className={`shrink-0 border-t border-medid-sidebar-border ${collapsed ? 'px-2 py-3 space-y-1' : 'px-3 py-3 space-y-0.5'}`}>
        {!collapsed && (
          <div className="mb-1.5 px-2 py-2 flex items-center gap-2.5 rounded-xl bg-medid-sidebar-hover ring-1 ring-inset ring-medid-sidebar-border">
            <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-medid-primary/30 to-medid-primary/10 flex items-center justify-center ring-1 ring-inset ring-medid-sidebar-border">
              <User className="h-[18px] w-[18px] text-medid-primary" strokeWidth={2} />
            </div>
            <div className="min-w-0 flex-1">
              <p className="text-[13px] font-semibold text-medid-sidebar-text truncate">{userName}</p>
              <p className="text-[10px] text-medid-sidebar-muted capitalize tracking-wide">{role}</p>
            </div>
          </div>
        )}
        <button
          onClick={toggleTheme}
          className={`flex items-center rounded-xl transition-[background-color,color] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] w-full text-medid-sidebar-muted hover:text-medid-sidebar-text hover:bg-medid-sidebar-hover ${
            collapsed ? 'justify-center p-2.5' : 'gap-3 px-3 py-2.5'
          }`}
          title={dark ? 'Yorug\' rejim' : 'Qorong\'i rejim'}
        >
          {dark ? <Sun className={`${collapsed ? 'h-5 w-5' : 'h-[18px] w-[18px]'} shrink-0`} strokeWidth={1.75} /> : <Moon className={`${collapsed ? 'h-5 w-5' : 'h-[18px] w-[18px]'} shrink-0`} strokeWidth={1.75} />}
          {!collapsed && <span className="text-sm">{dark ? 'Yorug' : 'Qorong\'i'}</span>}
        </button>
        <button
          onClick={handleLogout}
          className={`flex items-center rounded-xl transition-[background-color,color] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] w-full text-white/50 hover:text-medid-emergency hover:bg-medid-emergency/10 ${
            collapsed ? 'justify-center p-2.5' : 'gap-3 px-3 py-2.5'
          }`}
          title="Chiqish"
        >
          <LogOut className={`${collapsed ? 'h-5 w-5' : 'h-[18px] w-[18px]'} shrink-0`} strokeWidth={1.75} />
          {!collapsed && <span className="text-sm">Chiqish</span>}
        </button>
      </div>
    </div>
  )

  return (
    <>
      {/* Mobile hamburger */}
      <button
        onClick={() => setMobileOpen(true)}
        className="md:hidden fixed top-3 left-3 z-30 p-2.5 rounded-xl bg-medid-sidebar/90 backdrop-blur-md text-medid-sidebar-text shadow-float ring-1 ring-medid-sidebar-border"
      >
        <Menu className="h-5 w-5" />
      </button>

      {/* Mobile overlay */}
      {mobileOpen && <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-40 md:hidden" onClick={() => setMobileOpen(false)} />}

      {/* Mobile drawer */}
      <aside className={`md:hidden fixed inset-y-0 left-0 z-50 bg-medid-sidebar shadow-lift ring-1 ring-medid-sidebar-border transform transition-transform duration-500 ease-[cubic-bezier(0.32,0.72,0,1)] ${
        mobileOpen ? 'translate-x-0' : '-translate-x-full'
      }`}>
        {sidebarContent}
      </aside>

      {/* Desktop sidebar */}
      <aside className={`hidden md:flex shrink-0 bg-medid-sidebar text-medid-sidebar-text ${collapsed ? 'w-16' : 'w-64'} transition-all duration-500 ease-[cubic-bezier(0.32,0.72,0,1)]`}>
        {sidebarContent}
      </aside>
    </>
  )
}
