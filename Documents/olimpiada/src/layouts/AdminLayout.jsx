import { Outlet, Navigate } from 'react-router-dom'
import Sidebar from '../components/layout/Sidebar'
import Toast from '../components/ui/Toast'
import { useAuth } from '../context/AuthContext'
import LoadingSpinner from '../components/ui/LoadingSpinner'

export default function AdminLayout() {
  const { user, loading } = useAuth()

  if (loading) return <LoadingSpinner />
  if (!user) return <Navigate to="/login" replace />

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-950">
      <Sidebar />
      <div className="lg:pl-60 transition-all duration-300">
        <div className="p-4 md:p-6 lg:p-8 pt-20 lg:pt-8">
          <Outlet />
        </div>
      </div>
      <Toast />
    </div>
  )
}
