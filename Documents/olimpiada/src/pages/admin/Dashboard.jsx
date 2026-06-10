import { useState } from 'react'
import { motion } from 'framer-motion'
import { adminStats, upcomingOlympiads } from '../../utils/data'
import {
  Users, GraduationCap, ClipboardList, Award, TrendingUp, Activity,
  DollarSign, BookOpen, Calendar, ChevronRight
} from 'lucide-react'
import { getStatusColor, getStatusLabel } from '../../utils/helpers'

const statCards = [
  { icon: Users, label: "O'quvchilar", value: adminStats.totalStudents.toLocaleString(), change: '+12%', color: 'from-blue-400 to-indigo-500' },
  { icon: GraduationCap, label: 'Faol olimpiadalar', value: adminStats.activeOlympiads, change: '+2', color: 'from-emerald-400 to-green-500' },
  { icon: ClipboardList, label: "Ro'yxatdan o'tishlar", value: adminStats.totalRegistrations.toLocaleString(), change: '+8%', color: 'from-amber-400 to-orange-500' },
  { icon: Award, label: 'Sertifikatlar', value: adminStats.certificatesIssued.toLocaleString(), change: '+15%', color: 'from-violet-400 to-purple-500' },
]

export default function AdminDashboard() {
  return (
    <div className="space-y-6 md:space-y-8">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
      >
        <h1 className="text-2xl md:text-3xl font-bold text-gray-900 dark:text-gray-100">Admin Dashboard</h1>
        <p className="text-gray-500 dark:text-gray-400 mt-1">Platforma statistikasi va boshqaruvi.</p>
      </motion.div>

      {/* Stats */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 md:gap-5">
        {statCards.map((s, i) => (
          <motion.div
            key={i}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.05 }}
            className="glass-card p-4 md:p-5"
          >
            <div className="flex items-center justify-between mb-3">
              <div className={`p-2.5 rounded-xl bg-gradient-to-br ${s.color} text-white`}>
                <s.icon size={20} />
              </div>
              <span className="text-xs font-medium text-emerald-600 dark:text-emerald-400 bg-emerald-50 dark:bg-emerald-500/10 px-2 py-0.5 rounded-full">
                {s.change}
              </span>
            </div>
            <p className="text-2xl font-bold text-gray-900 dark:text-gray-100">{s.value}</p>
            <p className="text-xs text-gray-500 dark:text-gray-400 mt-0.5">{s.label}</p>
          </motion.div>
        ))}
      </div>

      <div className="grid lg:grid-cols-3 gap-6">
        {/* Chart placeholder */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="lg:col-span-2 glass-card p-5 md:p-6"
        >
          <h2 className="font-semibold text-gray-900 dark:text-gray-100 mb-4">Oylik statistika</h2>
          <div className="h-64 flex items-end justify-between gap-2">
            {[35, 55, 40, 70, 60, 85, 65, 90, 75, 95, 80, 100].map((h, i) => (
              <div key={i} className="flex-1 flex flex-col items-center gap-1">
                <motion.div
                  initial={{ height: 0 }}
                  animate={{ height: `${h}%` }}
                  transition={{ delay: 0.3 + i * 0.03, duration: 0.5 }}
                  className="w-full rounded-lg bg-gradient-to-t from-indigo-500 to-violet-500 max-w-8"
                />
                <span className="text-[10px] text-gray-400">
                  {['Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyun', 'Iyl', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek'][i]}
                </span>
              </div>
            ))}
          </div>
        </motion.div>

        {/* Quick info */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.25 }}
          className="glass-card p-5 md:p-6"
        >
          <h2 className="font-semibold text-gray-900 dark:text-gray-100 mb-4">Tezkor ma'lumotlar</h2>
          <div className="space-y-4">
            {[
              { icon: Users, label: "Yangi o'quvchilar", value: `+${adminStats.newThisMonth}`, color: 'text-blue-500' },
              { icon: Activity, label: 'Faol foydalanuvchilar', value: adminStats.activeUsers.toLocaleString(), color: 'text-emerald-500' },
              { icon: BookOpen, label: "Yakunlangan olimpiadalar", value: adminStats.completedOlympiads, color: 'text-amber-500' },
            ].map((item, i) => (
              <div key={i} className="flex items-center justify-between p-3 rounded-xl bg-gray-50 dark:bg-gray-800/50">
                <div className="flex items-center gap-3">
                  <item.icon size={18} className={item.color} />
                  <span className="text-sm text-gray-600 dark:text-gray-400">{item.label}</span>
                </div>
                <span className={`text-sm font-semibold ${item.color}`}>{item.value}</span>
              </div>
            ))}
          </div>
        </motion.div>
      </div>

      {/* Recent Olympiads */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.3 }}
        className="glass-card p-5 md:p-6"
      >
        <div className="flex items-center justify-between mb-4">
          <h2 className="font-semibold text-gray-900 dark:text-gray-100">Oxirgi olimpiadalar</h2>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-200 dark:border-gray-700">
                <th className="text-left px-3 py-3 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase">Nomi</th>
                <th className="text-left px-3 py-3 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase">Fan</th>
                <th className="text-center px-3 py-3 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase">Sinf</th>
                <th className="text-center px-3 py-3 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase">Ishtirokchilar</th>
                <th className="text-center px-3 py-3 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase">Sana</th>
                <th className="text-center px-3 py-3 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase">Holat</th>
              </tr>
            </thead>
            <tbody>
              {upcomingOlympiads.map((o, i) => (
                <motion.tr
                  key={o.id}
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.3 + i * 0.03 }}
                  className="border-b border-gray-100 dark:border-gray-800/50"
                >
                  <td className="px-3 py-3.5 text-gray-700 dark:text-gray-300 font-medium">{o.title}</td>
                  <td className="px-3 py-3.5 text-gray-500 dark:text-gray-400">{o.subject}</td>
                  <td className="px-3 py-3.5 text-center text-gray-500 dark:text-gray-400">{o.grade}</td>
                  <td className="px-3 py-3.5 text-center text-gray-700 dark:text-gray-300">{o.participants.toLocaleString()}</td>
                  <td className="px-3 py-3.5 text-center text-gray-500 dark:text-gray-400">{o.date}</td>
                  <td className="px-3 py-3.5 text-center">
                    <span className={`text-xs font-medium px-2.5 py-1 rounded-full ${getStatusColor(o.status)}`}>
                      {getStatusLabel(o.status)}
                    </span>
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
