import { motion } from 'framer-motion'
import { FileText, Download, BarChart3 } from 'lucide-react'

export default function AdminReports() {
  return (
    <div className="space-y-6">
      <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}>
        <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">Hisobotlar</h1>
        <p className="text-gray-500 dark:text-gray-400 text-sm mt-1">Platforma hisobotlari va tahlillari.</p>
      </motion.div>

      <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
        {[
          { icon: FileText, title: 'Oylik hisobot', desc: 'Foydalanuvchilar va olimpiadalar bo\'yicha oylik statistika' },
          { icon: BarChart3, title: 'Analitika', desc: 'Platforma faoliyati haqida batafsil tahlil' },
          { icon: Download, title: 'Eksport', desc: "Ma'lumotlarni Excel va PDF formatida yuklab olish" },
        ].map((item, i) => (
          <motion.div
            key={i}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.05 }}
            className="glass-card p-6 group cursor-pointer hover:shadow-xl hover:shadow-indigo-500/5 transition-all"
          >
            <div className="p-3 rounded-xl bg-indigo-50 dark:bg-indigo-500/10 text-indigo-600 dark:text-indigo-400 w-fit mb-4 group-hover:scale-110 transition-transform">
              <item.icon size={24} />
            </div>
            <h3 className="font-semibold text-gray-900 dark:text-gray-100 mb-1">{item.title}</h3>
            <p className="text-sm text-gray-500 dark:text-gray-400">{item.desc}</p>
            <button className="mt-4 text-sm font-medium text-indigo-600 dark:text-indigo-400 hover:underline">
              Ko'rish →
            </button>
          </motion.div>
        ))}
      </div>
    </div>
  )
}
