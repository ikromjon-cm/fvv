'use client'

import { useState } from 'react'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import {
  Search,
  Heart,
  Package,
  MessageCircle,
  User,
  Menu,
  LogIn,
  X,
} from 'lucide-react'
import { cn } from '@/lib/utils'
import { useAuth } from '@/lib/auth'
import { useI18n } from '@/lib/i18n'

const navLinks = [
  { href: '/', label: 'home' },
  { href: '/categories', label: 'categories' },
  { href: '/nearby', label: 'nearby' },
]

export function Navbar() {
  const { user, isLoading } = useAuth()
  const { t } = useI18n()
  const pathname = usePathname()
  const [drawerOpen, setDrawerOpen] = useState(false)
  const [searchQuery, setSearchQuery] = useState('')

  return (
    <>
      <nav className="sticky top-0 z-50 bg-white shadow-sm border-b">
        <div className="mx-auto max-w-7xl px-4">
          <div className="flex h-16 items-center justify-between gap-4">
            {/* Mobile menu button */}
            <button
              className="lg:hidden p-2 -ml-2 rounded-lg hover:bg-gray-100 transition-colors"
              onClick={() => setDrawerOpen(true)}
              aria-label="Open menu"
            >
              <Menu className="h-6 w-6" />
            </button>

            {/* Logo */}
            <Link href="/" className="flex items-center gap-2 shrink-0">
              <div className="flex items-center justify-center w-9 h-9 rounded-lg bg-primary text-primary-foreground">
                <svg
                  width="20"
                  height="20"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                >
                  <path d="M3 21V7l9-5 9 5v14" />
                  <path d="M3 21h18" />
                  <path d="M9 21V9h6v12" />
                  <rect x="10" y="12" width="4" height="3" rx="0.5" />
                </svg>
              </div>
              <span className="hidden sm:inline text-xl font-bold text-gray-900">
                Darvoza.uz
              </span>
            </Link>

            {/* Desktop nav links */}
            <div className="hidden lg:flex items-center gap-1">
              {navLinks.map((link) => (
                <Link
                  key={link.href}
                  href={link.href}
                  className={cn(
                    'px-3 py-2 rounded-lg text-sm font-medium transition-colors',
                    pathname === link.href
                      ? 'bg-primary/10 text-primary'
                      : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100',
                  )}
                >
                  {t(link.label)}
                </Link>
              ))}
            </div>

            {/* Search bar */}
            <div className="hidden sm:flex flex-1 max-w-lg relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder={t('search')}
                className="w-full pl-10 pr-4 py-2 rounded-xl border border-gray-200 bg-gray-50 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
              />
            </div>

            {/* Right actions */}
            <div className="flex items-center gap-1 sm:gap-2">
              <Link
                href="/favorites"
                className={cn(
                  'p-2 rounded-lg transition-colors hidden sm:flex flex-col items-center gap-0.5',
                  pathname === '/favorites'
                    ? 'text-primary'
                    : 'text-gray-500 hover:text-gray-900 hover:bg-gray-100',
                )}
              >
                <Heart className="h-5 w-5" />
                <span className="text-[10px] font-medium">{t('favorites')}</span>
              </Link>

              <Link
                href="/orders"
                className={cn(
                  'p-2 rounded-lg transition-colors hidden sm:flex flex-col items-center gap-0.5',
                  pathname === '/orders'
                    ? 'text-primary'
                    : 'text-gray-500 hover:text-gray-900 hover:bg-gray-100',
                )}
              >
                <Package className="h-5 w-5" />
                <span className="text-[10px] font-medium">{t('orders')}</span>
              </Link>

              <Link
                href="/messages"
                className={cn(
                  'p-2 rounded-lg transition-colors hidden sm:flex flex-col items-center gap-0.5',
                  pathname === '/messages'
                    ? 'text-primary'
                    : 'text-gray-500 hover:text-gray-900 hover:bg-gray-100',
                )}
              >
                <MessageCircle className="h-5 w-5" />
                <span className="text-[10px] font-medium">{t('messages')}</span>
              </Link>

              {isLoading ? (
                <div className="h-8 w-8 rounded-full bg-gray-200 animate-pulse" />
              ) : user ? (
                <Link
                  href="/profile"
                  className={cn(
                    'p-1 rounded-lg transition-colors',
                    pathname === '/profile'
                      ? 'ring-2 ring-primary'
                      : 'hover:bg-gray-100',
                  )}
                >
                  {user.avatar ? (
                    <img
                      src={user.avatar}
                      alt={user.full_name}
                      className="h-8 w-8 rounded-full object-cover"
                    />
                  ) : (
                    <div className="h-8 w-8 rounded-full bg-primary/10 flex items-center justify-center">
                      <User className="h-4 w-4 text-primary" />
                    </div>
                  )}
                </Link>
              ) : (
                <Link
                  href="/login"
                  className="flex items-center gap-1.5 px-4 py-2 rounded-xl bg-primary text-primary-foreground text-sm font-medium hover:opacity-90 transition-opacity"
                >
                  <LogIn className="h-4 w-4" />
                  <span className="hidden sm:inline">{t('login')}</span>
                </Link>
              )}
            </div>
          </div>
        </div>
      </nav>

      {/* Mobile search bar (below nav on small screens) */}
      <div className="sm:hidden px-4 py-2 bg-white border-b">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder={t('search')}
            className="w-full pl-10 pr-4 py-2.5 rounded-xl border border-gray-200 bg-gray-50 text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all"
          />
        </div>
      </div>

      {/* Mobile drawer overlay */}
      {drawerOpen && (
        <div
          className="fixed inset-0 z-50 bg-black/40 lg:hidden"
          onClick={() => setDrawerOpen(false)}
        >
          <div
            className="absolute left-0 top-0 h-full w-72 max-w-[80vw] bg-white shadow-xl"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between p-4 border-b">
              <span className="text-lg font-bold text-gray-900">Darvoza.uz</span>
              <button
                onClick={() => setDrawerOpen(false)}
                className="p-2 rounded-lg hover:bg-gray-100 transition-colors"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            <div className="p-4 space-y-2">
              {navLinks.map((link) => (
                <Link
                  key={link.href}
                  href={link.href}
                  onClick={() => setDrawerOpen(false)}
                  className={cn(
                    'block px-4 py-3 rounded-xl text-sm font-medium transition-colors',
                    pathname === link.href
                      ? 'bg-primary/10 text-primary'
                      : 'text-gray-700 hover:bg-gray-50',
                  )}
                >
                  {t(link.label)}
                </Link>
              ))}
              <hr className="my-3" />
              {!user && (
                <Link
                  href="/login"
                  onClick={() => setDrawerOpen(false)}
                  className="block px-4 py-3 rounded-xl text-sm font-medium text-primary hover:bg-primary/5 transition-colors"
                >
                  {t('login')}
                </Link>
              )}
              <Link
                href="/favorites"
                onClick={() => setDrawerOpen(false)}
                className="block px-4 py-3 rounded-xl text-sm font-medium text-gray-700 hover:bg-gray-50 transition-colors"
              >
                {t('favorites')}
              </Link>
              <Link
                href="/orders"
                onClick={() => setDrawerOpen(false)}
                className="block px-4 py-3 rounded-xl text-sm font-medium text-gray-700 hover:bg-gray-50 transition-colors"
              >
                {t('orders')}
              </Link>
              <Link
                href="/messages"
                onClick={() => setDrawerOpen(false)}
                className="block px-4 py-3 rounded-xl text-sm font-medium text-gray-700 hover:bg-gray-50 transition-colors"
              >
                {t('messages')}
              </Link>
              {user && (
                <Link
                  href="/profile"
                  onClick={() => setDrawerOpen(false)}
                  className="block px-4 py-3 rounded-xl text-sm font-medium text-gray-700 hover:bg-gray-50 transition-colors"
                >
                  {t('profile')}
                </Link>
              )}
            </div>
          </div>
        </div>
      )}
    </>
  )
}
