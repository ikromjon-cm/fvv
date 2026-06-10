import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useForm } from 'react-hook-form'
import { motion } from 'framer-motion'
import { useAuth } from '../../context/AuthContext'
import { useToast } from '../../context/ToastContext'
import { regions, subjects, grades } from '../../utils/data'
import { Eye, EyeOff, GraduationCap, ArrowLeft } from 'lucide-react'

export default function Register() {
  const { register: signUp } = useAuth()
  const { addToast } = useToast()
  const navigate = useNavigate()
  const [showPassword, setShowPassword] = useState(false)
  const [loading, setLoading] = useState(false)

  const {
    register,
    handleSubmit,
    watch,
    formState: { errors },
  } = useForm()

  const password = watch('password')

  const districts = {
    "Toshkent shahri": ["Yashnobod", "Mirzo Ulug'bek", "Chilonzor", "Sergeli", "Olmazor", "Yunusobod", "Uchtepa", "Bektemir"],
    "Toshkent viloyati": ["Nurafshon", "Olmaliq", "Angren", "Bekobod", "Chirchiq", "G'azalkent", "Quyichirchiq", "O'rta Chirchiq"],
    "Samarqand": ["Samarqand shahri", "Kattaqo'rg'on", "Urgut", "Ishtixon", "Jomboy", "Narpay", "Payariq", "Pastdarg'om"],
    "Buxoro": ["Buxoro shahri", "Kogon", "G'ijduvon", "Shofirkon", "Romitan", "Vobkent", "Qoravulbozor", "Jondor"],
    "Andijon": ["Andijon shahri", "Xonobod", "Asaka", "Jalaquduq", "Marxamat", "Qo'rg'ontepa", "Baliqchi", "Bo'z"],
  }

  const onSubmit = async (data) => {
    setLoading(true)
    try {
      const result = await signUp(data)
      if (result.success) {
        addToast("Muvaffaqiyatli ro'yxatdan o'tdingiz!", 'success')
        navigate('/dashboard')
      }
    } catch {
      addToast("Xatolik yuz berdi", 'error')
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
            "Bilimli inson hech qachon yengilmaydi. Bilim — eng kuchli qurol."
          </blockquote>
          <p className="text-white/60 mt-3 text-sm">— O'zbekiston Respublikasi</p>
        </div>
      </div>

      <div className="flex-1 flex items-center justify-center p-4 sm:p-6 lg:p-8">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="w-full max-w-lg"
        >
          <Link to="/" className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-gray-700 dark:hover:text-gray-300 mb-6 transition-colors">
            <ArrowLeft size={16} /> Bosh sahifa
          </Link>

          <h1 className="text-2xl md:text-3xl font-bold text-gray-900 dark:text-gray-100 mb-1">
            Ro'yxatdan o'tish
          </h1>
          <p className="text-gray-500 dark:text-gray-400 text-sm mb-8">
            Barcha maydonlarni to'ldiring va olimpiadalarda qatnashing.
          </p>

          <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
            <div className="grid sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Ism</label>
                <input {...register('firstName', { required: 'Ism kiritilishi shart' })}
                  className={`input-field ${errors.firstName ? 'ring-2 ring-red-500/50 border-red-500' : ''}`}
                  placeholder="Ali" />
                {errors.firstName && <p className="text-xs text-red-500 mt-1">{errors.firstName.message}</p>}
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Familiya</label>
                <input {...register('lastName', { required: 'Familiya kiritilishi shart' })}
                  className={`input-field ${errors.lastName ? 'ring-2 ring-red-500/50 border-red-500' : ''}`}
                  placeholder="Karimov" />
                {errors.lastName && <p className="text-xs text-red-500 mt-1">{errors.lastName.message}</p>}
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Telefon raqam</label>
              <input {...register('phone', {
                required: 'Telefon raqam kiritilishi shart',
                pattern: { value: /^\+998\d{9}$/, message: "To'g'ri format: +998901234567" }
              })}
                className={`input-field ${errors.phone ? 'ring-2 ring-red-500/50 border-red-500' : ''}`}
                placeholder="+998901234567" />
              {errors.phone && <p className="text-xs text-red-500 mt-1">{errors.phone.message}</p>}
            </div>

            <div className="grid sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Viloyat</label>
                <select {...register('region', { required: 'Viloyat tanlang' })}
                  className={`input-field ${errors.region ? 'ring-2 ring-red-500/50 border-red-500' : ''}`}>
                  <option value="">Tanlang</option>
                  {regions.map(r => <option key={r} value={r}>{r}</option>)}
                </select>
                {errors.region && <p className="text-xs text-red-500 mt-1">{errors.region.message}</p>}
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Tuman</label>
                <select {...register('district', { required: 'Tuman tanlang' })}
                  className={`input-field ${errors.district ? 'ring-2 ring-red-500/50 border-red-500' : ''}`}>
                  <option value="">Tanlang</option>
                  {(districts[watch('region')] || []).map(d => <option key={d} value={d}>{d}</option>)}
                </select>
                {errors.district && <p className="text-xs text-red-500 mt-1">{errors.district.message}</p>}
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Maktab</label>
              <input {...register('school', { required: 'Maktab nomi kiritilishi shart' })}
                className={`input-field ${errors.school ? 'ring-2 ring-red-500/50 border-red-500' : ''}`}
                placeholder="215-IDUM" />
              {errors.school && <p className="text-xs text-red-500 mt-1">{errors.school.message}</p>}
            </div>

            <div className="grid sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Sinf</label>
                <select {...register('grade', { required: 'Sinf tanlang' })}
                  className={`input-field ${errors.grade ? 'ring-2 ring-red-500/50 border-red-500' : ''}`}>
                  <option value="">Tanlang</option>
                  {grades.map(g => <option key={g} value={g}>{g}-sinf</option>)}
                </select>
                {errors.grade && <p className="text-xs text-red-500 mt-1">{errors.grade.message}</p>}
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Fanlar</label>
                <select {...register('subjects', { required: 'Kamida bitta fan tanlang' })}
                  className={`input-field ${errors.subjects ? 'ring-2 ring-red-500/50 border-red-500' : ''}`} multiple>
                  {subjects.map(s => <option key={s} value={s}>{s}</option>)}
                </select>
                {errors.subjects && <p className="text-xs text-red-500 mt-1">{errors.subjects.message}</p>}
              </div>
            </div>

            <div className="grid sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Parol</label>
                <div className="relative">
                  <input type={showPassword ? 'text' : 'password'}
                    {...register('password', {
                      required: 'Parol kiritilishi shart',
                      minLength: { value: 6, message: 'Kamida 6 belgi' }
                    })}
                    className={`input-field pr-10 ${errors.password ? 'ring-2 ring-red-500/50 border-red-500' : ''}`}
                    placeholder="••••••••" />
                  <button type="button" onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600">
                    {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                  </button>
                </div>
                {errors.password && <p className="text-xs text-red-500 mt-1">{errors.password.message}</p>}
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Parolni tasdiqlang</label>
                <input type={showPassword ? 'text' : 'password'}
                  {...register('confirmPassword', {
                    required: 'Parolni tasdiqlang',
                    validate: v => v === password || 'Parollar mos emas'
                  })}
                  className={`input-field ${errors.confirmPassword ? 'ring-2 ring-red-500/50 border-red-500' : ''}`}
                  placeholder="••••••••" />
                {errors.confirmPassword && <p className="text-xs text-red-500 mt-1">{errors.confirmPassword.message}</p>}
              </div>
            </div>

            <button type="submit" disabled={loading}
              className="gradient-btn w-full py-3.5 text-base flex items-center justify-center gap-2 mt-6">
              {loading ? (
                <span className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
              ) : (
                "Ro'yxatdan o'tish"
              )}
            </button>

            <p className="text-center text-sm text-gray-500 dark:text-gray-400 mt-4">
              Akkauntingiz bormi?{' '}
              <Link to="/login" className="text-indigo-600 dark:text-indigo-400 font-medium hover:underline">Kirish</Link>
            </p>
          </form>
        </motion.div>
      </div>
    </div>
  )
}
