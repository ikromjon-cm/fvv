import { useState, useMemo } from 'react'
import { motion } from 'framer-motion'
import { allResults, subjects } from '../../utils/data'
import SearchInput from '../../components/ui/SearchInput'
import DataTable from '../../components/ui/DataTable'
import Pagination from '../../components/ui/Pagination'
import { ClipboardList, Search, CheckCircle, XCircle } from 'lucide-react'

const ITEMS_PER_PAGE = 8

export default function Results() {
  const [search, setSearch] = useState('')
  const [sortColumn, setSortColumn] = useState('score')
  const [sortDirection, setSortDirection] = useState('desc')
  const [page, setPage] = useState(1)

  const filtered = useMemo(() => {
    let data = [...allResults]
    if (search) {
      data = data.filter(r =>
        r.student.toLowerCase().includes(search.toLowerCase()) ||
        r.id.toLowerCase().includes(search.toLowerCase()) ||
        r.subject.toLowerCase().includes(search.toLowerCase())
      )
    }
    data.sort((a, b) => {
      const mult = sortDirection === 'asc' ? 1 : -1
      if (sortColumn === 'score' || sortColumn === 'rank' || sortColumn === 'total') {
        return (a[sortColumn] - b[sortColumn]) * mult
      }
      return String(a[sortColumn]).localeCompare(String(b[sortColumn])) * mult
    })
    return data
  }, [search, sortColumn, sortDirection])

  const totalPages = Math.ceil(filtered.length / ITEMS_PER_PAGE)
  const paginated = filtered.slice((page - 1) * ITEMS_PER_PAGE, page * ITEMS_PER_PAGE)

  const handleSort = (col) => {
    if (sortColumn === col) {
      setSortDirection(d => d === 'asc' ? 'desc' : 'asc')
    } else {
      setSortColumn(col)
      setSortDirection('desc')
    }
  }

  const columns = [
    { key: 'id', label: 'ID', sortable: true },
    { key: 'student', label: "O'quvchi", sortable: true },
    {
      key: 'score', label: 'Ball', sortable: true,
      render: (row) => (
        <span className={`font-semibold ${row.score >= 85 ? 'text-emerald-600 dark:text-emerald-400' : row.score >= 70 ? 'text-amber-600 dark:text-amber-400' : 'text-gray-600 dark:text-gray-400'}`}>
          {row.score}
        </span>
      ),
    },
    { key: 'rank', label: 'Reyting', sortable: true, render: (row) => `#${row.rank}` },
    { key: 'total', label: 'Jami', sortable: true },
    { key: 'subject', label: 'Fan', sortable: true },
    { key: 'date', label: 'Sana', sortable: true },
    {
      key: 'certificate', label: 'Sertifikat',
      render: (row) => row.certificate
        ? <span className="flex items-center gap-1 text-emerald-600 dark:text-emerald-400 text-xs font-medium"><CheckCircle size={14} /> Bor</span>
        : <span className="flex items-center gap-1 text-gray-400 text-xs"><XCircle size={14} /> Yo'q</span>,
    },
  ]

  return (
    <div className="space-y-6 md:space-y-8">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
      >
        <h1 className="text-2xl md:text-3xl font-bold text-gray-900 dark:text-gray-100">Natijalar</h1>
        <p className="text-gray-500 dark:text-gray-400 mt-1">Barcha olimpiada natijalarini ko'ring va qidiring.</p>
      </motion.div>

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.05 }}
        className="flex flex-col sm:flex-row gap-4"
      >
        <SearchInput
          value={search}
          onChange={v => { setSearch(v); setPage(1) }}
          placeholder="ID, ism yoki fan bo'yicha qidirish..."
          className="sm:w-80"
        />
      </motion.div>

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.1 }}
        className="glass-card overflow-hidden"
      >
        <DataTable
          columns={columns}
          data={paginated}
          sortColumn={sortColumn}
          sortDirection={sortDirection}
          onSort={handleSort}
          emptyIcon={Search}
          emptyTitle="Natija topilmadi"
          emptyDescription="Qidiruv so'roviga mos natija mavjud emas."
        />
      </motion.div>

      <Pagination currentPage={page} totalPages={totalPages} onPageChange={setPage} />
    </div>
  )
}
