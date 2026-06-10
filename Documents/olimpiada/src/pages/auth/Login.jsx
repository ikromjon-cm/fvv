import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { motion } from 'framer-motion'
import { useAuth } from '../../context/AuthContext'
import { useToast } from '../../context/ToastContext'
import { Eye, EyeOff, GraduationCap, LogIn, ArrowLeft } from 'lucide-react'

export default function Login() {
  const { login } = useAuth()
  const { addToast } = useToast()
  const navigate = useNavigate()
  const [phone, setPhone] = useState('')
  const [password, setPassword] = useState('')
  const [remember, setRemember] = useState(false)
  const [showPassword, setShowPassword] = useState(false)
  const [loading, setLoading] = useState(false)
  const [errors, setErrors] = useState({})

  const validate = () => {
    const errs = {}
    if (!phone) errs.phone = 'Telefon raqam kiritilishi shart'
    else if (!/^\+998\d{9}$/.test(phone)) errs.phone = "Noto'g'ri format"
    if (!password) errs.password = 'Parol kiritilishi shart'
    setErrors(errs)
    return Object.keys(errs).length === 0
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    if (!validate()) return
    setLoading(true)
    try {
      const result = await login(phone, password)
      if (result.success) {
        addToast('Xush kelibsiz!', 'success')
        navigate('/dashboard')
      }
    } catch {
      addToast('Login yoki parol noto\'g\'ri', 'error')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex">
      <div className="hidden lg:flex lg:w-1/2 bg-gradient-to-br from-indigo-500 via-indigo-600 to-violet-700 p-12 flex-col justify-between relative overflow-hidden">
        <div className="absolute top-0 right-0 w-64 h-64 bg-white/5 rounded-full -translate-y-1/2 translate-x-1/2" />
        <div className="absolute bottom-0 left-0 w-96 h-96 bg-white/5 rounded-full translate-y-1/2 -translate-x-1/2" />
        <Link to="/" className="flex items-center gap-2.5 text-white relative z-10">
          <div className="p-2 rounded-xl bg-white/20 backdrop-blur">
            <GraduationCap size={24} />
          </div>
          <span className="text-xl font-bold">Olimpiada</span>
        </Link>
        <div className="relative z-10">
          <blockquote className="text-white/90 text-lg leading-relaxed">
            "Bilim — bu kuch. Bilimli inson kelajak egasidir."
          </blockquote>
          <p className="text-white/60 mt-3 text-sm">— O'zbekiston Respublikasi</p>
        </div>
      </div>

      <div className="flex-1 flex items-center justify-center p-4 sm:p-6 lg:p-8">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="w-full max-w-md"
        >
          <Link to="/" className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-gray-700 dark:hover:text-gray-300 mb-6 transition-colors">
            <ArrowLeft size={16} /> Bosh sahifa
          </Link>

          <h1 className="text-2xl md:text-3xl font-bold text-gray-900 dark:text-gray-100 mb-1">Kirish</h1>
          <p className="text-gray-500 dark:text-gray-400 text-sm mb-8">Hisobingizga kiring va olimpiadalarda qatnashing.</p>

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Telefon raqam</label>
              <input
                value={phone}
                onChange={e => setPhone(e.target.value)}
                className={`input-field ${errors.phone ? 'ring-2 ring-red-500/50 border-red-500' : ''}`}
                placeholder="+998901234567"
              />
              {errors.phone && <p className="text-xs text-red-500 mt-1">{errors.phone}</p>}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Parol</label>
              <div className="relative">
                <input
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={e => setPassword(e.target.value)}
                  className={`input-field pr-10 ${errors.password ? 'ring-2 ring-red-500/50 border-red-500' : ''}`}
                  placeholder="••••••••"
                />
                <button type="button" onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600">
                  {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                </button>
              </div>
              {errors.password && <p className="text-xs text-red-500 mt-1">{errors.password}</p>}
            </div>

            <div className="flex items-center justify-between">
              <label className="flex items-center gap-2 cursor-pointer">
                <input
                  type="checkbox"
                  checked={remember}
                  onChange={e => setRemember(e.target.checked)}
                  className="w-4 h-4 rounded border-gray-300 dark:border-gray-600 text-indigo-600 focus:ring-indigo-500"
                />
                <span className="text-sm text-gray-600 dark:text-gray-400">Eslab qolish</span>
              </label>
              <button type="button" className="text-sm text-indigo-600 dark:text-indigo-400 hover:underline">
                Parolni unutdingizmi?
              </button>
            </div>

            <button type="submit" disabled={loading}
              className="gradient-btn w-full py-3.5 text-base flex items-center justify-center gap-2">
              {loading ? (
                <span className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
              ) : (
                <>Kirish <LogIn size={18} /></>
              )}
            </button>

            <p className="text-center text-sm text-gray-500 dark:text-gray-400 mt-4">
              Akkauntingiz yo'qmi?{' '}
              <Link to="/register" className="text-indigo-600 dark:text-indigo-400 font-medium hover:underline">
                Ro'yxatdan o'tish
              </Link>
            </p>
          </form>
        </motion.div>
      </div>
    </div>
  )
}
