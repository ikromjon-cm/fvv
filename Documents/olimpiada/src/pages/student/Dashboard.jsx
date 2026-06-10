import { useState } from 'react'
import { motion } from 'framer-motion'
import { Link } from 'react-router-dom'
import { useAuth } from '../../context/AuthContext'
import {
  GraduationCap, Award, TrendingUp, Clock, Medal, Bell, ChevronRight,
  BookOpen, Users, Calendar, ClipboardCheck, Eye, Download
} from 'lucide-react'
import { upcomingOlympiads, olympiadHistory, notifications, subjects } from '../../utils/data'
import { formatDate, getStatusColor, getStatusLabel } from '../../utils/helpers'

const statCards = [
  { icon: Medal, label: 'Olimpiadalar', value: olympiadHistory.length, color: 'from-amber-400 to-orange-500' },
  { icon: Award, label: 'Sertifikatlar', value: olympiadHistory.filter(h => h.certificate).length, color: 'from-emerald-400 to-green-500' },
  { icon: TrendingUp, label: "O'rtacha ball", value: Math.round(olympiadHistory.reduce((a, h) => a + h.score, 0) / olympiadHistory.length), color: 'from-blue-400 to-indigo-500' },
  { icon: Medal, label: 'Eng yaxshi natija', value: `#${Math.min(...olympiadHistory.map(h => h.rank))}`, color: 'from-violet-400 to-purple-500' },
]

export default function StudentDashboard() {
  const { user } = useAuth()

  return (
    <div className="space-y-6 md:space-y-8">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="flex flex-col sm:flex-row sm:items-center justify-between gap-4"
      >
        <div>
          <h1 className="text-2xl md:text-3xl font-bold text-gray-900 dark:text-gray-100">
            Xush kelibsiz, {user?.firstName}!
          </h1>
          <p className="text-gray-500 dark:text-gray-400 mt-1">O'z natijalaringizni kuzatib boring.</p>
        </div>
        <Link to="/olimpiadalar" className="gradient-btn px-5 py-2.5 text-sm flex items-center gap-2 self-start">
          <BookOpen size={16} /> Olimpiadalarni ko'rish
        </Link>
      </motion.div>

      {/* Unique ID Card */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.1 }}
        className="gradient-card rounded-2xl p-6 md:p-8"
      >
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
          <div>
            <p className="text-indigo-200 text-sm mb-1">Shaxsiy ID raqamingiz</p>
            <p className="text-2xl md:text-3xl font-mono font-bold tracking-wider">{user?.uniqueId}</p>
          </div>
          <div className="flex items-center gap-4">
            <div className="text-right">
              <p className="text-indigo-200 text-xs">{user?.firstName} {user?.lastName}</p>
              <p className="text-indigo-200 text-xs">{user?.grade}-sinf | {user?.school}</p>
            </div>
            <div className="p-2 rounded-xl bg-white/20 backdrop-blur">
              <GraduationCap size={28} />
            </div>
          </div>
        </div>
      </motion.div>

      {/* Stats */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 md:gap-5">
        {statCards.map((stat, i) => (
          <motion.div
            key={i}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 + i * 0.05 }}
            className="glass-card p-4 md:p-5 flex items-center gap-3 md:gap-4"
          >
            <div className={`p-3 rounded-xl bg-gradient-to-br ${stat.color} text-white shrink-0`}>
              <stat.icon size={22} />
            </div>
            <div>
              <p className="text-2xl font-bold text-gray-900 dark:text-gray-100">{stat.value}</p>
              <p className="text-xs text-gray-500 dark:text-gray-400">{stat.label}</p>
            </div>
          </motion.div>
        ))}
      </div>

      <div className="grid lg:grid-cols-3 gap-6">
        {/* Upcoming Olympiads */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="lg:col-span-2 glass-card p-5 md:p-6"
        >
          <div className="flex items-center justify-between mb-4">
            <h2 className="font-semibold text-gray-900 dark:text-gray-100 flex items-center gap-2">
              <Calendar size={18} className="text-indigo-500" /> Kelayotgan olimpiadalar
            </h2>
            <Link to="/olimpiadalar" className="text-sm text-indigo-600 dark:text-indigo-400 hover:underline flex items-center gap-1">
              Hammasi <ChevronRight size={14} />
            </Link>
          </div>
          <div className="space-y-3">
            {upcomingOlympiads.filter(o => o.status !== 'closed').slice(0, 4).map((o, i) => (
              <div key={o.id}
                className="flex items-center justify-between p-3.5 rounded-xl bg-gray-50 dark:bg-gray-800/50 hover:bg-indigo-50/50 dark:hover:bg-indigo-500/5 transition-colors"
              >
                <div className="flex items-center gap-3">
                  <div className="p-2 rounded-lg bg-indigo-100 dark:bg-indigo-500/10 text-indigo-600 dark:text-indigo-400">
                    <BookOpen size={16} />
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-900 dark:text-gray-100">{o.title}</p>
                    <p className="text-xs text-gray-500 dark:text-gray-400">{o.subject} | {o.grade}-sinflar</p>
                  </div>
                </div>
                <div className="flex items-center gap-3">
                  <span className={`text-xs font-medium px-2.5 py-1 rounded-full ${getStatusColor(o.status)}`}>
                    {getStatusLabel(o.status)}
                  </span>
                  <span className="text-xs text-gray-400">{o.date}</span>
                </div>
              </div>
            ))}
          </div>
        </motion.div>

        {/* Notifications */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.35 }}
          className="glass-card p-5 md:p-6"
        >
          <h2 className="font-semibold text-gray-900 dark:text-gray-100 flex items-center gap-2 mb-4">
            <Bell size={18} className="text-indigo-500" /> Bildirishnomalar
          </h2>
          <div className="space-y-3">
            {notifications.map((n, i) => (
              <div key={n.id} className="flex gap-3 p-3 rounded-xl bg-gray-50 dark:bg-gray-800/50">
                <div className={`p-1.5 rounded-full shrink-0 h-fit ${
                  n.type === 'success' ? 'bg-emerald-100 text-emerald-600 dark:bg-emerald-500/10 dark:text-emerald-400' :
                  n.type === 'warning' ? 'bg-amber-100 text-amber-600 dark:bg-amber-500/10 dark:text-amber-400' :
                  'bg-indigo-100 text-indigo-600 dark:bg-indigo-500/10 dark:text-indigo-400'
                }`}>
                  <Bell size={14} />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-gray-900 dark:text-gray-100 truncate">{n.title}</p>
                  <p className="text-xs text-gray-500 dark:text-gray-400 mt-0.5 line-clamp-2">{n.message}</p>
                  <p className="text-xs text-gray-400 mt-1">{n.time}</p>
                </div>
              </div>
            ))}
          </div>
        </motion.div>
      </div>

      {/* Recent Results */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.4 }}
        className="glass-card p-5 md:p-6"
      >
        <div className="flex items-center justify-between mb-4">
          <h2 className="font-semibold text-gray-900 dark:text-gray-100 flex items-center gap-2">
            <ClipboardCheck size={18} className="text-indigo-500" /> Oxirgi natijalar
          </h2>
          <Link to="/natijalar" className="text-sm text-indigo-600 dark:text-indigo-400 hover:underline flex items-center gap-1">
            Barchasi <ChevronRight size={14} />
          </Link>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-200 dark:border-gray-700">
                <th className="text-left px-3 py-3 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase">Nomi</th>
                <th className="text-left px-3 py-3 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase">Sana</th>
                <th className="text-center px-3 py-3 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase">Ball</th>
                <th className="text-center px-3 py-3 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase">Reyting</th>
                <th className="text-center px-3 py-3 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase">Sertifikat</th>
                <th className="text-right px-3 py-3 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase">Amal</th>
              </tr>
            </thead>
            <tbody>
              {olympiadHistory.slice(0, 3).map((h, i) => (
                <motion.tr
                  key={h.id}
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.4 + i * 0.05 }}
                  className="border-b border-gray-100 dark:border-gray-800/50"
                >
                  <td className="px-3 py-3.5 text-gray-700 dark:text-gray-300 font-medium">{h.title}</td>
                  <td className="px-3 py-3.5 text-gray-500 dark:text-gray-400">{h.date}</td>
                  <td className="px-3 py-3.5 text-center">
                    <span className={`font-semibold ${h.score >= 85 ? 'text-emerald-600 dark:text-emerald-400' : h.score >= 70 ? 'text-amber-600 dark:text-amber-400' : 'text-gray-600 dark:text-gray-400'}`}>
                      {h.score}
                    </span>
                  </td>
                  <td className="px-3 py-3.5 text-center text-gray-700 dark:text-gray-300">#{h.rank}</td>
                  <td className="px-3 py-3.5 text-center">
                    {h.certificate ? (
                      <span className="text-emerald-600 dark:text-emerald-400 text-xs font-medium bg-emerald-50 dark:bg-emerald-500/10 px-2 py-1 rounded-full">Bor</span>
                    ) : (
                      <span className="text-gray-400 text-xs">Yo'q</span>
                    )}
                  </td>
                  <td className="px-3 py-3.5 text-right">
                    <button className="text-indigo-600 dark:text-indigo-400 hover:bg-indigo-50 dark:hover:bg-indigo-500/10 p-1.5 rounded-lg transition-colors">
                      <Eye size={16} />
                    </button>
                  </td>
                </motion.tr>
              ))}
            </tbody>
          </table>
        </div>
      </motion.div>
    </div>
  )
}
