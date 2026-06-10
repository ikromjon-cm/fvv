import { useState } from 'react'
import { motion } from 'framer-motion'
import { useNavigate } from 'react-router-dom'
import SearchInput from '../../components/ui/SearchInput'
import DataTable from '../../components/ui/DataTable'
import Pagination from '../../components/ui/Pagination'
import { upcomingOlympiads, subjects } from '../../utils/data'
import { getStatusColor, getStatusLabel, formatDate } from '../../utils/helpers'
import { GraduationCap, Search, Plus } from 'lucide-react'

const ITEMS_PER_PAGE = 8

export default function AdminOlympiads() {
  const [search, setSearch] = useState('')
  const [page, setPage] = useState(1)

  const filtered = upcomingOlympiads.filter(o =>
    o.title.toLowerCase().includes(search.toLowerCase())
  )
  const totalPages = Math.ceil(filtered.length / ITEMS_PER_PAGE)
  const paginated = filtered.slice((page - 1) * ITEMS_PER_PAGE, page * ITEMS_PER_PAGE)

  const columns = [
    { key: 'title', label: 'Nomi' },
    { key: 'subject', label: 'Fan' },
    { key: 'grade', label: 'Sinf' },
    {
      key: 'participants', label: 'Ishtirokchilar',
      render: (row) => row.participants.toLocaleString(),
    },
    { key: 'date', label: 'Sana' },
    {
      key: 'status', label: 'Holat',
      render: (row) => (
        <span className={`text-xs font-medium px-2.5 py-1 rounded-full ${getStatusColor(row.status)}`}>
          {getStatusLabel(row.status)}
        </span>
      ),
    },
  ]

  return (
    <div className="space-y-6">
      <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">Olimpiadalar boshqaruvi</h1>
          <p className="text-gray-500 dark:text-gray-400 text-sm mt-1">Olimpiadalarni boshqaring va yangilarini qo'shing.</p>
        </div>
        <button className="gradient-btn px-4 py-2.5 text-sm flex items-center gap-2">
          <Plus size={16} /> Yangi olimpiada
        </button>
      </motion.div>

      <div className="sm:w-72">
        <SearchInput value={search} onChange={v => { setSearch(v); setPage(1) }} placeholder="Qidirish..." />
      </div>

      <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.05 }} className="glass-card overflow-hidden">
        <DataTable columns={columns} data={paginated} emptyIcon={GraduationCap} emptyTitle="Olimpiada topilmadi" />
      </motion.div>

      <Pagination currentPage={page} totalPages={totalPages} onPageChange={setPage} />
    </div>
  )
}
