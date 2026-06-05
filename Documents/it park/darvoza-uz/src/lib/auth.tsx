'use client'

import { createContext, useContext, useState, useEffect, useCallback, type ReactNode } from 'react'
import { api } from './api'
import type { User } from '@/types'

interface AuthContextType {
  user: User | null
  token: string | null
  isLoading: boolean
  login: (phone: string, password: string) => Promise<void>
  register: (data: { phone: string; password: string; full_name: string; role: string }) => Promise<void>
  logout: () => void
  updateProfile: (data: Partial<User>) => Promise<void>
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [token, setToken] = useState<string | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    const t = localStorage.getItem('access_token')
    if (t) {
      setToken(t)
      api.get<User>('/auth/profile/')
        .then(setUser)
        .catch(() => {
          localStorage.removeItem('access_token')
          localStorage.removeItem('refresh_token')
        })
        .finally(() => setIsLoading(false))
    } else {
      setIsLoading(false)
    }
  }, [])

  const login = useCallback(async (phone: string, password: string) => {
    const res = await api.post<{ user: User; access: string; refresh: string }>('/auth/login/', { phone, password })
    localStorage.setItem('access_token', res.access)
    localStorage.setItem('refresh_token', res.refresh)
    setToken(res.access)
    setUser(res.user)
  }, [])

  const register = useCallback(async (data: { phone: string; password: string; full_name: string; role: string }) => {
    const res = await api.post<{ user: User; access: string; refresh: string }>('/auth/register/', data)
    localStorage.setItem('access_token', res.access)
    localStorage.setItem('refresh_token', res.refresh)
    setToken(res.access)
    setUser(res.user)
  }, [])

  const logout = useCallback(() => {
    localStorage.removeItem('access_token')
    localStorage.removeItem('refresh_token')
    setUser(null)
    setToken(null)
  }, [])

  const updateProfile = useCallback(async (data: Partial<User>) => {
    const updated = await api.patch<User>('/accounts/profile/', data)
    setUser(updated)
  }, [])

  return (
    <AuthContext.Provider value={{ user, token, isLoading, login, register, logout, updateProfile }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth must be used within AuthProvider')
  return ctx
}
