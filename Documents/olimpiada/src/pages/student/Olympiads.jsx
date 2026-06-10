import { useState } from 'react'
import { motion } from 'framer-motion'
import { useNavigate } from 'react-router-dom'
import { useToast } from '../../context/ToastContext'
import { upcomingOlympiads, subjects, grades } from '../../utils/data'
import { formatDate, getStatusColor, getStatusLabel } from '../../utils/helpers'
import SearchInput from '../../components/ui/SearchInput'
import FilterPanel from '../../components/ui/FilterPanel'
import Pagination from '../../components/ui/Pagination'
import EmptyState from '../../components/ui/EmptyState'
import { BookOpen, Calendar, Users, Clock, CheckCircle, ArrowRight } from 'lucide-react'

const ITEMS_PER_PAGE = 6

export default function Olympiads() {
  const navigate = useNavigate()
  const { addToast } = useToast()
  const [search, setSearch] = useState('')
  const [filters, setFilters] = useState({ subject: '', grade: '', status: '' })
  const [page, setPage] = useState(1)

  const filtered = upcomingOlympiads.filter(o => {
    if (search && !o.title.toLowerCase().includes(search.toLowerCase())) return false
    if (filters.subject && o.subject !== filters.subject) return false
    if (filters.grade) {
      const [min, max] = o.grade.split('-').map(Number)
      if (max && (Number(filters.grade) < min || Number(filters.grade) > max)) return false
      if (!max && Number(filters.grade) !== min) return false
    }
    if (filters.status && o.status !== filters.status) return false
    return true
  })

  const totalPages = Math.ceil(filtered.length / ITEMS_PER_PAGE)
  const paginated = filtered.slice((page - 1) * ITEMS_PER_PAGE, page * ITEMS_PER_PAGE)

  const handleRegister = (olympiad) => {
    addToast(`${olympiad.title} ga muvaffaqiyatli ro'yxatdan o'tdingiz!`, 'success')
  }

  return (
    <div className="space-y-6 md:space-y-8">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
      >
        <h1 className="text-2xl md:text-3xl font-bold text-gray-900 dark:text-gray-100">Olimpiadalar</h1>
        <p className="text-gray-500 dark:text-gray-400 mt-1">Barcha mavjud olimpiadalarni ko'ring va qatnashing.</p>
      </motion.div>

      {/* Search & Filters */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.05 }}
        className="flex flex-col sm:flex-row gap-4"
      >
        <SearchInput value={search} onChange={v => { setSearch(v); setPage(1) }} placeholder="Olimpiada qidirish..." className="sm:w-72" />
        <FilterPanel
          filters={filters}
          onFilterChange={f => { setFilters(f); setPage(1) }}
          subjects={subjects}
          grades={grades}
          onClear={() => { setFilters({ subject: '', grade: '', status: '' }); setPage(1) }}
        />
      </motion.div>

      {/* Olympiad List */}
      {paginated.length === 0 ? (
        <EmptyState icon={BookOpen} title="Olimpiada topilmadi" description="Qidiruv so'roviga mos olimpiada mavjud emas." />
      ) : (
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
          {paginated.map((o, i) => (
            <motion.div
              key={o.id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.05 }}
              className="glass-card p-5 group hover:shadow-xl hover:shadow-indigo-500/5 transition-all duration-300"
            >
              <div className="flex items-start justify-between mb-3">
                <div className="p-2.5 rounded-xl bg-indigo-50 dark:bg-indigo-500/10 text-indigo-600 dark:text-indigo-400">
                  <BookOpen size={22} />
                </div>
                <span className={`text-xs font-medium px-2.5 py-1 rounded-full ${getStatusColor(o.status)}`}>
                  {getStatusLabel(o.status)}
                </span>
              </div>

              <h3 className="font-semibold text-gray-900 dark:text-gray-100 mb-3 group-hover:text-indigo-600 dark:group-hover:text-indigo-400 transition-colors">
                {o.title}
              </h3>

              <div className="space-y-2 text-sm text-gray-500 dark:text-gray-400 mb-4">
                <div className="flex items-center gap-2">
                  <BookOpen size={14} className="shrink-0" />
                  <span>{o.subject}</span>
                </div>
                <div className="flex items-center gap-2">
                  <Users size={14} className="shrink-0" />
                  <span>{o.grade}-sinflar</span>
                </div>
                <div className="flex items-center gap-2">
                  <Calendar size={14} className="shrink-0" />
                  <span>{o.date}</span>
                </div>
                <div className="flex items-center gap-2">
                  <Users size={14} className="shrink-0" />
                  <span>{o.participants.toLocaleString()} ishtirokchi</span>
                </div>
              </div>

              <button
                onClick={() => handleRegister(o)}
                disabled={o.status === 'closed'}
                className={`w-full py-2.5 rounded-xl text-sm font-medium flex items-center justify-center gap-2 transition-all ${
                  o.status === 'closed'
                    ? 'bg-gray-100 dark:bg-gray-800 text-gray-400 cursor-not-allowed'
                    : o.status === 'coming_soon'
                    ? 'bg-amber-50 dark:bg-amber-500/10 text-amber-600 dark:text-amber-400'
                    : 'gradient-btn'
                }`}
              >
                {o.status === 'closed' ? 'Yopilgan' : o.status === 'coming_soon' ? 'Tez orada' : "Ro'yxatdan o'tish"}
                {o.status === 'open' && <ArrowRight size={16} />}
              </button>
            </motion.div>
          ))}
        </div>
      )}

      <Pagination currentPage={page} totalPages={totalPages} onPageChange={setPage} />
    </div>
  )
}
