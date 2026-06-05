'use client'

import { useState, useEffect } from 'react'
import Link from 'next/link'
import { User, Edit3, Moon, Sun, LogOut, ChevronRight, Shield, Store, Wrench, Save } from 'lucide-react'
import { Navbar } from '@/components/navbar'
import { Footer } from '@/components/footer'
import { MobileBottomNav } from '@/components/mobile-bottom-nav'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Switch } from '@/components/ui/switch'
import { Separator } from '@/components/ui/separator'
import { useAuth } from '@/lib/auth'
import { useI18n } from '@/lib/i18n'

export default function ProfilePage() {
  const { user, isLoading, logout, updateProfile } = useAuth()
  const { t, locale, setLocale } = useI18n()
  const [isEditing, setIsEditing] = useState(false)
  const [name, setName] = useState('')
  const [phone, setPhone] = useState('')
  const [darkMode, setDarkMode] = useState(false)

  useEffect(() => {
    if (user) {
      setName(user.full_name)
      setPhone(user.phone)
    }
  }, [user])

  useEffect(() => {
    const isDark = document.documentElement.classList.contains('dark')
    setDarkMode(isDark)
  }, [])

  const toggleDark = () => {
    const newVal = !darkMode
    setDarkMode(newVal)
    document.documentElement.classList.toggle('dark', newVal)
    localStorage.setItem('theme', newVal ? 'dark' : 'light')
  }

  const handleSave = async () => {
    await updateProfile({ full_name: name, phone })
    setIsEditing(false)
  }

  const roleLinks: Record<string, { href: string; label: string; icon: typeof Shield }> = {
    seller: { href: '/seller', label: 'Sotuvchi paneli', icon: Store },
    master: { href: '/master', label: 'Usta paneli', icon: Wrench },
    admin: { href: '/admin', label: 'Admin panel', icon: Shield },
  }

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin h-8 w-8 border-4 border-primary border-t-transparent rounded-full" />
      </div>
    )
  }

  if (!user) {
    return (
      <div className="min-h-screen flex flex-col">
        <Navbar />
        <div className="flex-1 flex items-center justify-center">
          <div className="text-center p-8">
            <User className="h-16 w-16 mx-auto text-gray-300 mb-4" />
            <h2 className="text-xl font-semibold text-gray-900 mb-2">Profilingizni ko'rish uchun kiring</h2>
            <p className="text-gray-500 mb-6">Akkauntingizga kiring va shaxsiy ma'lumotlaringizni boshqaring</p>
            <Link href="/login">
              <Button>Kirish</Button>
            </Link>
          </div>
        </div>
        <Footer />
        <MobileBottomNav />
      </div>
    )
  }

  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Navbar />
      <main className="flex-1 pb-20 lg:pb-0">
        <div className="mx-auto max-w-2xl px-4 py-6 space-y-6">
          {/* Profile card */}
          <Card>
            <CardContent className="p-6">
              <div className="flex items-center gap-4">
                <Avatar className="h-16 w-16">
                  {user.avatar ? (
                    <AvatarImage src={user.avatar} />
                  ) : (
                    <AvatarFallback className="bg-primary/10 text-primary text-xl">
                      {user.full_name.charAt(0)}
                    </AvatarFallback>
                  )}
                </Avatar>
                <div className="flex-1">
                  <h1 className="text-xl font-bold text-gray-900">{user.full_name}</h1>
                  <p className="text-sm text-gray-500">{user.phone}</p>
                  <div className="flex items-center gap-2 mt-1">
                    <span className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-primary/10 text-primary capitalize">
                      {user.role === 'buyer' ? 'Xaridor' : user.role === 'seller' ? 'Sotuvchi' : user.role === 'master' ? 'Usta' : 'Admin'}
                    </span>
                    {user.is_verified && (
                      <span className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-green-50 text-green-700">
                        Tasdiqlangan
                      </span>
                    )}
                  </div>
                </div>
                <Button variant="outline" size="sm" onClick={() => setIsEditing(!isEditing)}>
                  <Edit3 className="h-4 w-4 mr-1" />
                  {t('edit')}
                </Button>
              </div>
            </CardContent>
          </Card>

          {/* Edit form */}
          {isEditing && (
            <Card>
              <CardHeader>
                <CardTitle className="text-base">Profilni tahrirlash</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">{t('full_name')}</label>
                  <Input value={name} onChange={(e) => setName(e.target.value)} />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">{t('phone')}</label>
                  <Input value={phone} onChange={(e) => setPhone(e.target.value)} />
                </div>
                <div className="flex gap-2 justify-end">
                  <Button variant="outline" onClick={() => setIsEditing(false)}>{t('cancel')}</Button>
                  <Button onClick={handleSave}>
                    <Save className="h-4 w-4 mr-1" />
                    {t('save')}
                  </Button>
                </div>
              </CardContent>
            </Card>
          )}

          {/* Role-based links */}
          {roleLinks[user.role] && (
            <Link href={roleLinks[user.role].href}>
              <Card className="hover:shadow-md transition-shadow cursor-pointer">
                <CardContent className="p-4 flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center">
                      {(() => {
                        const Icon = roleLinks[user.role].icon
                        return <Icon className="h-5 w-5 text-primary" />
                      })()}
                    </div>
                    <div>
                      <p className="text-sm font-semibold text-gray-900">{roleLinks[user.role].label}</p>
                      <p className="text-xs text-gray-500">Maxsus panelga o'tish</p>
                    </div>
                  </div>
                  <ChevronRight className="h-5 w-5 text-gray-400" />
                </CardContent>
              </Card>
            </Link>
          )}

          {/* Settings */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base">{t('settings')}</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  {darkMode ? <Moon className="h-5 w-5 text-gray-600" /> : <Sun className="h-5 w-5 text-gray-600" />}
                  <span className="text-sm font-medium text-gray-900">{t('dark_mode')}</span>
                </div>
                <Switch checked={darkMode} onCheckedChange={toggleDark} />
              </div>

              <Separator />

              <div className="flex items-center justify-between">
                <span className="text-sm font-medium text-gray-900">{t('language')}</span>
                <div className="flex gap-1">
                  {(['uz', 'ru', 'en'] as const).map((l) => (
                    <button
                      key={l}
                      onClick={() => setLocale(l)}
                      className={`px-3 py-1.5 rounded-lg text-xs font-medium transition-colors ${
                        locale === l
                          ? 'bg-primary text-primary-foreground'
                          : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                      }`}
                    >
                      {t(l)}
                    </button>
                  ))}
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Logout */}
          <Button
            variant="destructive"
            className="w-full"
            onClick={() => {
              logout()
              window.location.href = '/'
            }}
          >
            <LogOut className="h-4 w-4 mr-2" />
            {t('logout')}
          </Button>
        </div>
      </main>
      <Footer />
      <MobileBottomNav />
    </div>
  )
}
