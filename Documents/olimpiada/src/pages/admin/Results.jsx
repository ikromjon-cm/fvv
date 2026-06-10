import { useState } from 'react'
import { motion } from 'framer-motion'
import SearchInput from '../../components/ui/SearchInput'
import DataTable from '../../components/ui/DataTable'
import Pagination from '../../components/ui/Pagination'
import { allResults } from '../../utils/data'
import { Search, CheckCircle, XCircle } from 'lucide-react'

const ITEMS_PER_PAGE = 10

export default function AdminResults() {
  const [search, setSearch] = useState('')
  const [page, setPage] = useState(1)

  const filtered = allResults.filter(r =>
    r.student.toLowerCase().includes(search.toLowerCase()) ||
    r.id.toLowerCase().includes(search.toLowerCase())
  )
  const totalPages = Math.ceil(filtered.length / ITEMS_PER_PAGE)
  const paginated = filtered.slice((page - 1) * ITEMS_PER_PAGE, page * ITEMS_PER_PAGE)

  const columns = [
    { key: 'id', label: 'ID' },
    { key: 'student', label: "O'quvchi" },
    { key: 'subject', label: 'Fan' },
    {
      key: 'score', label: 'Ball',
      render: (row) => <span className="font-semibold">{row.score}</span>,
    },
    { key: 'rank', label: 'Reyting', render: (row) => `#${row.rank}` },
    { key: 'date', label: 'Sana' },
    {
      key: 'certificate', label: 'Sertifikat',
      render: (row) => row.certificate
        ? <span className="text-emerald-600 dark:text-emerald-400 flex items-center gap-1"><CheckCircle size={14} /> Bor</span>
        : <span className="text-gray-400 flex items-center gap-1"><XCircle size={14} /> Yo'q</span>,
    },
  ]

  return (
    <div className="space-y-6">
      <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}>
        <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">Natijalar boshqaruvi</h1>
        <p className="text-gray-500 dark:text-gray-400 text-sm mt-1">Barcha olimpiada natijalarini boshqaring.</p>
      </motion.div>

      <div className="sm:w-72">
        <SearchInput value={search} onChange={v => { setSearch(v); setPage(1) }} placeholder="Qidirish..." />
      </div>

      <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.05 }} className="glass-card overflow-hidden">
        <DataTable columns={columns} data={paginated} emptyIcon={Search} emptyTitle="Natija topilmadi" />
      </motion.div>

      <Pagination currentPage={page} totalPages={totalPages} onPageChange={setPage} />
    </div>
  )
}
