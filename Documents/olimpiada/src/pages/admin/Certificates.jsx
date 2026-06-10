import { useState } from 'react'
import { motion } from 'framer-motion'
import { certificates } from '../../utils/data'
import { getCertColor } from '../../utils/helpers'
import SearchInput from '../../components/ui/SearchInput'
import DataTable from '../../components/ui/DataTable'
import Pagination from '../../components/ui/Pagination'
import { Award, Search } from 'lucide-react'

const ITEMS_PER_PAGE = 10

export default function AdminCertificates() {
  const [search, setSearch] = useState('')
  const [page, setPage] = useState(1)

  const filtered = certificates.filter(c =>
    c.title.toLowerCase().includes(search.toLowerCase()) ||
    c.student.toLowerCase().includes(search.toLowerCase())
  )
  const totalPages = Math.ceil(filtered.length / ITEMS_PER_PAGE)
  const paginated = filtered.slice((page - 1) * ITEMS_PER_PAGE, page * ITEMS_PER_PAGE)

  const columns = [
    { key: 'id', label: 'ID' },
    { key: 'student', label: "O'quvchi" },
    { key: 'title', label: 'Olimpiada' },
    { key: 'rank', label: "O'rin" },
    { key: 'date', label: 'Sana' },
    {
      key: 'type', label: 'Turi',
      render: (row) => (
        <span className={`text-xs font-semibold px-2.5 py-1 rounded-full bg-gradient-to-r ${getCertColor(row.type)} text-white`}>
          {row.type === 'gold' ? 'Oltin' : row.type === 'silver' ? 'Kumush' : row.type === 'bronze' ? 'Bronza' : 'Faxriy'}
        </span>
      ),
    },
  ]

  return (
    <div className="space-y-6">
      <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}>
        <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">Sertifikatlar boshqaruvi</h1>
        <p className="text-gray-500 dark:text-gray-400 text-sm mt-1">Barcha sertifikatlarni boshqaring.</p>
      </motion.div>

      <div className="sm:w-72">
        <SearchInput value={search} onChange={v => { setSearch(v); setPage(1) }} placeholder="Qidirish..." />
      </div>

      <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.05 }} className="glass-card overflow-hidden">
        <DataTable columns={columns} data={paginated} emptyIcon={Award} emptyTitle="Sertifikat topilmadi" />
      </motion.div>

      <Pagination currentPage={page} totalPages={totalPages} onPageChange={setPage} />
    </div>
  )
}
