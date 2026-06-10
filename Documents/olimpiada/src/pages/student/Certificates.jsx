import { useState } from 'react'
import { motion } from 'framer-motion'
import { certificates } from '../../utils/data'
import { getCertColor } from '../../utils/helpers'
import SearchInput from '../../components/ui/SearchInput'
import EmptyState from '../../components/ui/EmptyState'
import Modal from '../../components/ui/Modal'
import { Award, Download, Eye, Search } from 'lucide-react'

export default function Certificates() {
  const [search, setSearch] = useState('')
  const [preview, setPreview] = useState(null)

  const filtered = certificates.filter(c =>
    c.title.toLowerCase().includes(search.toLowerCase()) ||
    c.student.toLowerCase().includes(search.toLowerCase())
  )

  const rankBadge = (rank) => {
    if (rank.includes('1')) return { label: "Oltin", color: 'from-yellow-400 to-amber-500' }
    if (rank.includes('2')) return { label: "Kumush", color: 'from-gray-300 to-gray-400' }
    if (rank.includes('3')) return { label: "Bronza", color: 'from-orange-400 to-amber-600' }
    return { label: "Faxriy", color: 'from-indigo-400 to-purple-500' }
  }

  return (
    <div className="space-y-6 md:space-y-8">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
      >
        <h1 className="text-2xl md:text-3xl font-bold text-gray-900 dark:text-gray-100">Sertifikatlar</h1>
        <p className="text-gray-500 dark:text-gray-400 mt-1">Sizning barcha sertifikatlaringiz.</p>
      </motion.div>

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.05 }}
        className="sm:w-72"
      >
        <SearchInput value={search} onChange={setSearch} placeholder="Sertifikat qidirish..." />
      </motion.div>

      {filtered.length === 0 ? (
        <EmptyState icon={Award} title="Sertifikat topilmadi" description="Sizda hali sertifikat mavjud emas." />
      ) : (
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
          {filtered.map((c, i) => {
            const badge = rankBadge(c.rank)
            return (
              <motion.div
                key={c.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: i * 0.05 }}
                className="glass-card overflow-hidden group"
              >
                <div className={`h-2 bg-gradient-to-r ${getCertColor(c.type)}`} />
                <div className="p-5">
                  <div className="flex items-start justify-between mb-4">
                    <div className={`p-2.5 rounded-xl bg-gradient-to-br ${getCertColor(c.type)} text-white`}>
                      <Award size={22} />
                    </div>
                    <span className={`text-xs font-bold px-2.5 py-1 rounded-full bg-gradient-to-r ${badge.color} text-white`}>
                      {badge.label}
                    </span>
                  </div>

                  <h3 className="font-semibold text-gray-900 dark:text-gray-100 mb-1">{c.title}</h3>
                  <p className="text-sm text-gray-500 dark:text-gray-400 mb-3">{c.student}</p>

                  <div className="flex items-center justify-between mb-4">
                    <span className="text-sm font-medium text-indigo-600 dark:text-indigo-400">{c.rank}</span>
                    <span className="text-xs text-gray-400">{c.date}</span>
                  </div>

                  <div className="flex gap-2">
                    <button
                      onClick={() => setPreview(c)}
                      className="flex-1 flex items-center justify-center gap-1.5 py-2 rounded-xl border border-gray-200 dark:border-gray-700 text-sm font-medium text-gray-600 dark:text-gray-400 hover:bg-gray-50 dark:hover:bg-gray-800 transition-all"
                    >
                      <Eye size={15} /> Ko'rish
                    </button>
                    <button className="flex-1 flex items-center justify-center gap-1.5 py-2 rounded-xl gradient-btn text-sm">
                      <Download size={15} /> Yuklash
                    </button>
                  </div>
                </div>
              </motion.div>
            )
          })}
        </div>
      )}

      <Modal open={!!preview} onClose={() => setPreview(null)} title="Sertifikat" size="lg">
        {preview && (
          <div className="text-center">
            <div className={`inline-flex p-4 rounded-2xl bg-gradient-to-br ${getCertColor(preview.type)} text-white mb-4`}>
              <Award size={48} />
            </div>
            <h3 className="text-xl font-bold text-gray-900 dark:text-gray-100 mb-1">{preview.title}</h3>
            <p className="text-gray-500 dark:text-gray-400 mb-2">{preview.student}</p>
            <div className={`inline-block px-4 py-1.5 rounded-full bg-gradient-to-r ${getCertColor(preview.type)} text-white text-sm font-semibold mb-4`}>
              {preview.rank}
            </div>
            <p className="text-sm text-gray-400 mb-6">ID: {preview.id} | {preview.date}</p>
            <button className="gradient-btn px-6 py-2.5 text-sm flex items-center gap-2 mx-auto">
              <Download size={16} /> Sertifikatni yuklash
            </button>
          </div>
        )}
      </Modal>
    </div>
  )
}
