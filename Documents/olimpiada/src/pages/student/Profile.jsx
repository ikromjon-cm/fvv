import { useState, useRef } from 'react'
import { motion } from 'framer-motion'
import { useAuth } from '../../context/AuthContext'
import { useToast } from '../../context/ToastContext'
import { regions, subjects } from '../../utils/data'
import { Camera, Save, Eye, EyeOff, User } from 'lucide-react'

export default function Profile() {
  const { user, updateProfile } = useAuth()
  const { addToast } = useToast()
  const fileInputRef = useRef(null)
  const [saving, setSaving] = useState(false)

  const [form, setForm] = useState({
    firstName: user?.firstName || '',
    lastName: user?.lastName || '',
    phone: user?.phone || '',
    region: user?.region || '',
    district: user?.district || '',
    school: user?.school || '',
    grade: user?.grade || '',
    subjects: user?.subjects || [],
  })

  const [passwordForm, setPasswordForm] = useState({
    current: '', newPass: '', confirm: '',
  })
  const [showPasswords, setShowPasswords] = useState({})

  const handleChange = (e) => {
    const { name, value } = e.target
    setForm(prev => ({ ...prev, [name]: value }))
  }

  const handleSubjectToggle = (subject) => {
    setForm(prev => ({
      ...prev,
      subjects: prev.subjects.includes(subject)
        ? prev.subjects.filter(s => s !== subject)
        : [...prev.subjects, subject]
    }))
  }

  const handleSave = async () => {
    setSaving(true)
    try {
      await updateProfile(form)
      addToast("Profil muvaffaqiyatli yangilandi!", 'success')
    } catch {
      addToast("Xatolik yuz berdi", 'error')
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="max-w-4xl mx-auto space-y-6 md:space-y-8">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
      >
        <h1 className="text-2xl md:text-3xl font-bold text-gray-900 dark:text-gray-100">Profil</h1>
        <p className="text-gray-500 dark:text-gray-400 mt-1">Shaxsiy ma'lumotlaringizni boshqaring.</p>
      </motion.div>

      {/* Avatar */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.05 }}
        className="glass-card p-6 md:p-8 flex flex-col sm:flex-row items-center gap-6"
      >
        <div className="relative group">
          <div className="w-24 h-24 rounded-full bg-gradient-to-br from-indigo-500 to-violet-600 flex items-center justify-center text-white text-3xl font-bold">
            {user?.firstName?.[0]}{user?.lastName?.[0]}
          </div>
          <button
            onClick={() => fileInputRef.current?.click()}
            className="absolute bottom-0 right-0 p-2 rounded-full bg-indigo-600 text-white shadow-lg hover:bg-indigo-700 transition-colors"
          >
            <Camera size={16} />
          </button>
          <input ref={fileInputRef} type="file" accept="image/*" className="hidden" />
        </div>
        <div className="text-center sm:text-left">
          <h2 className="text-xl font-semibold text-gray-900 dark:text-gray-100">{user?.firstName} {user?.lastName}</h2>
          <p className="text-sm text-gray-500 dark:text-gray-400">ID: {user?.uniqueId}</p>
          <p className="text-xs text-gray-400">{user?.grade}-sinf | {user?.school}</p>
        </div>
      </motion.div>

      {/* Edit Profile */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.1 }}
        className="glass-card p-6 md:p-8"
      >
        <h2 className="font-semibold text-gray-900 dark:text-gray-100 mb-6 flex items-center gap-2">
          <User size={18} className="text-indigo-500" /> Shaxsiy ma'lumotlar
        </h2>

        <div className="grid sm:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Ism</label>
            <input name="firstName" value={form.firstName} onChange={handleChange} className="input-field" />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Familiya</label>
            <input name="lastName" value={form.lastName} onChange={handleChange} className="input-field" />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Telefon raqam</label>
            <input name="phone" value={form.phone} onChange={handleChange} className="input-field" />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Viloyat</label>
            <select name="region" value={form.region} onChange={handleChange} className="input-field">
              {regions.map(r => <option key={r}>{r}</option>)}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Tuman</label>
            <input name="district" value={form.district} onChange={handleChange} className="input-field" />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Maktab</label>
            <input name="school" value={form.school} onChange={handleChange} className="input-field" />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Sinf</label>
            <select name="grade" value={form.grade} onChange={handleChange} className="input-field">
              {[5, 6, 7, 8, 9, 10, 11].map(g => <option key={g} value={g}>{g}-sinf</option>)}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Fanlar</label>
            <div className="flex flex-wrap gap-1.5 mt-1">
              {subjects.map(s => (
                <button
                  key={s}
                  type="button"
                  onClick={() => handleSubjectToggle(s)}
                  className={`px-3 py-1.5 text-xs rounded-lg border transition-colors ${
                    form.subjects.includes(s)
                      ? 'bg-indigo-100 dark:bg-indigo-500/10 border-indigo-300 dark:border-indigo-600 text-indigo-700 dark:text-indigo-300'
                      : 'border-gray-200 dark:border-gray-700 text-gray-500 dark:text-gray-400 hover:border-gray-300'
                  }`}
                >
                  {s}
                </button>
              ))}
            </div>
          </div>
        </div>

        <button onClick={handleSave} disabled={saving}
          className="gradient-btn px-6 py-2.5 text-sm flex items-center gap-2 mt-6">
          {saving ? <span className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" /> : <Save size={16} />}
          Saqlash
        </button>
      </motion.div>

      {/* Change Password */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.15 }}
        className="glass-card p-6 md:p-8"
      >
        <h2 className="font-semibold text-gray-900 dark:text-gray-100 mb-6">Parolni o'zgartirish</h2>
        <div className="grid sm:grid-cols-3 gap-4">
          {['current', 'newPass', 'confirm'].map((field, i) => {
            const labels = { current: 'Joriy parol', newPass: 'Yangi parol', confirm: 'Yangi parolni tasdiqlang' }
            return (
              <div key={field}>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">{labels[field]}</label>
                <div className="relative">
                  <input
                    type={showPasswords[field] ? 'text' : 'password'}
                    value={passwordForm[field]}
                    onChange={e => setPasswordForm(p => ({ ...p, [field]: e.target.value }))}
                    className="input-field pr-10"
                    placeholder="••••••••"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPasswords(p => ({ ...p, [field]: !p[field] }))}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400"
                  >
                    {showPasswords[field] ? <EyeOff size={16} /> : <Eye size={16} />}
                  </button>
                </div>
              </div>
            )
          })}
        </div>
        <button className="gradient-btn px-6 py-2.5 text-sm flex items-center gap-2 mt-6">
          <Save size={16} /> Parolni yangilash
        </button>
      </motion.div>
    </div>
  )
}
