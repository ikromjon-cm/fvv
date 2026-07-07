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
      <div className={`shrink-0 flex items-center border-b border-white/10 ${collapsed ? 'justify-center px-2' : 'gap-2.5 px-4'} h-14`}>
        <div className="flex items-center justify-center w-8 h-8 rounded-lg bg-[#0066FF] shrink-0">
          <Shield className="h-4 w-4 text-white" />
        </div>
        {!collapsed && (
          <>
            <div className="min-w-0 flex-1">
              <p className="text-sm font-bold text-white leading-tight">FVV Ekotizimi</p>
              <p className="text-[9px] text-white/40">Uychi tumani</p>
            </div>
            <button onClick={() => setCollapsed(true)} className="p-1 rounded hover:bg-white/10 text-white/40">
              <ChevronLeft className="h-4 w-4" />
            </button>
          </>
        )}
        {collapsed && (
          <button onClick={() => setCollapsed(false)} className="p-1 rounded hover:bg-white/10 text-white/40">
            <ChevronRight className="h-4 w-4" />
          </button>
        )}
      </div>

      {/* Navigation */}
      <nav className={`flex-1 overflow-y-auto ${collapsed ? 'px-1 py-2 space-y-1' : 'p-2 space-y-0.5'}`}>
        {items.map((item) => {
          const Icon = iconMap[item.icon] || Shield
          const active = isActive(item.href)
          return (
            <Link
              key={item.href}
              href={item.href}
              onClick={() => setMobileOpen(false)}
              className={`flex items-center rounded-lg transition-colors ${
                collapsed ? 'justify-center p-2' : 'gap-2.5 px-3 py-2.5'
              } ${
                active
                  ? 'bg-[#0066FF]/20 text-white font-medium'
                  : 'text-white/50 hover:text-white hover:bg-white/5'
              }`}
              title={collapsed ? item.label : undefined}
            >
              <Icon className={`${collapsed ? 'h-5 w-5' : 'h-4 w-4'} shrink-0`} />
              {!collapsed && <span className="text-sm truncate">{item.label}</span>}
            </Link>
          )
        })}
      </nav>

      {/* Bottom */}
      <div className={`shrink-0 border-t border-white/10 ${collapsed ? 'px-1 py-2 space-y-1' : 'p-2 space-y-0.5'}`}>
        {!collapsed && (
          <div className="px-3 py-2 flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-lg bg-[#3B82F6]/20 flex items-center justify-center">
              <User className="h-4 w-4 text-[#3B82F6]" />
            </div>
            <div className="min-w-0 flex-1">
              <p className="text-xs font-medium text-white truncate">{userName}</p>
              <p className="text-[10px] text-white/40 capitalize">{role}</p>
            </div>
          </div>
        )}
        <button
          onClick={toggleTheme}
          className={`flex items-center rounded-lg transition-colors w-full text-white/50 hover:text-white hover:bg-white/5 ${
            collapsed ? 'justify-center p-2' : 'gap-2.5 px-3 py-2.5'
          }`}
          title={dark ? 'Yorug\' rejim' : 'Qorong\'i rejim'}
        >
          {dark ? <Sun className={`${collapsed ? 'h-5 w-5' : 'h-4 w-4'} shrink-0`} /> : <Moon className={`${collapsed ? 'h-5 w-5' : 'h-4 w-4'} shrink-0`} />}
          {!collapsed && <span className="text-sm">{dark ? 'Yorug' : 'Qorong\'i'}</span>}
        </button>
        <button
          onClick={handleLogout}
          className={`flex items-center rounded-lg transition-colors w-full text-white/50 hover:text-[#DC2626] hover:bg-[#DC2626]/10 ${
            collapsed ? 'justify-center p-2' : 'gap-2.5 px-3 py-2.5'
          }`}
          title="Chiqish"
        >
          <LogOut className={`${collapsed ? 'h-5 w-5' : 'h-4 w-4'} shrink-0`} />
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
        className="md:hidden fixed top-3 left-3 z-30 p-2 rounded-lg bg-medid-navy text-white shadow-lg"
      >
        <Menu className="h-5 w-5" />
      </button>

      {/* Mobile overlay */}
      {mobileOpen && <div className="fixed inset-0 bg-black/50 z-40 md:hidden" onClick={() => setMobileOpen(false)} />}

      {/* Mobile drawer */}
      <aside className={`md:hidden fixed inset-y-0 left-0 z-50 bg-medid-navy transform transition-transform ${
        mobileOpen ? 'translate-x-0' : '-translate-x-full'
      }`}>
        {sidebarContent}
      </aside>

      {/* Desktop sidebar */}
      <aside className={`hidden md:flex shrink-0 bg-medid-navy text-white ${collapsed ? 'w-16' : 'w-64'} transition-all duration-200`}>
        {sidebarContent}
      </aside>
    </>
  )
}
