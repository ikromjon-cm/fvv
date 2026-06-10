import { Routes, Route, Navigate } from 'react-router-dom'
import PublicLayout from '../layouts/PublicLayout'
import StudentLayout from '../layouts/StudentLayout'
import AdminLayout from '../layouts/AdminLayout'
import Landing from '../pages/public/Landing'
import Login from '../pages/auth/Login'
import Register from '../pages/auth/Register'
import StudentDashboard from '../pages/student/Dashboard'
import Profile from '../pages/student/Profile'
import Olympiads from '../pages/student/Olympiads'
import Results from '../pages/student/Results'
import Certificates from '../pages/student/Certificates'
import AdminDashboard from '../pages/admin/Dashboard'
import AdminStudents from '../pages/admin/Students'
import AdminOlympiads from '../pages/admin/Olympiads'
import AdminResults from '../pages/admin/Results'
import AdminCertificates from '../pages/admin/Certificates'
import AdminReports from '../pages/admin/Reports'

export default function AppRoutes() {
  return (
    <Routes>
      {/* Public routes */}
      <Route element={<PublicLayout />}>
        <Route path="/" element={<Landing />} />
        <Route path="/olimpiadalar" element={<Olympiads />} />
        <Route path="/natijalar" element={<Results />} />
        <Route path="/sertifikatlar" element={<Certificates />} />
      </Route>

      {/* Auth routes (no layout) */}
      <Route path="/login" element={<Login />} />
      <Route path="/register" element={<Register />} />

      {/* Student routes */}
      <Route element={<StudentLayout />}>
        <Route path="/dashboard" element={<StudentDashboard />} />
        <Route path="/profile" element={<Profile />} />
      </Route>

      {/* Admin routes */}
      <Route element={<AdminLayout />}>
        <Route path="/admin" element={<AdminDashboard />} />
        <Route path="/admin/students" element={<AdminStudents />} />
        <Route path="/admin/olympiads" element={<AdminOlympiads />} />
        <Route path="/admin/results" element={<AdminResults />} />
        <Route path="/admin/certificates" element={<AdminCertificates />} />
        <Route path="/admin/reports" element={<AdminReports />} />
      </Route>

      {/* Catch-all */}
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  )
}
