import { createContext, useContext, useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'

const AuthContext = createContext()

const MOCK_USER = {
  id: 1,
  firstName: 'Ali',
  lastName: 'Karimov',
  phone: '+998901234567',
  region: 'Toshkent shahri',
  district: 'Yashnobod',
  school: '215-IDUM',
  grade: 11,
  subjects: ['Matematika', 'Fizika'],
  uniqueId: 'OLY-2024-0001',
  avatar: null,
  role: 'student',
}

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const saved = localStorage.getItem('user')
    if (saved) setUser(JSON.parse(saved))
    setLoading(false)
  }, [])

  const login = (phone, password) => {
    return new Promise((resolve) => {
      setTimeout(() => {
        const u = { ...MOCK_USER, phone }
        setUser(u)
        localStorage.setItem('user', JSON.stringify(u))
        resolve({ success: true })
      }, 1000)
    })
  }

  const register = (data) => {
    return new Promise((resolve) => {
      setTimeout(() => {
        const u = {
          ...MOCK_USER,
          ...data,
          uniqueId: `OLY-${new Date().getFullYear()}-${String(Math.floor(Math.random() * 9999)).padStart(4, '0')}`,
        }
        setUser(u)
        localStorage.setItem('user', JSON.stringify(u))
        resolve({ success: true, user: u })
      }, 1000)
    })
  }

  const logout = () => {
    setUser(null)
    localStorage.removeItem('user')
  }

  const updateProfile = (data) => {
    return new Promise((resolve) => {
      setTimeout(() => {
        const updated = { ...user, ...data }
        setUser(updated)
        localStorage.setItem('user', JSON.stringify(updated))
        resolve({ success: true, user: updated })
      }, 500)
    })
  }

  return (
    <AuthContext.Provider value={{ user, loading, login, register, logout, updateProfile }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => useContext(AuthContext)
