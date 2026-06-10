import { useState } from 'react'
import { motion } from 'framer-motion'
import SearchInput from '../../components/ui/SearchInput'
import DataTable from '../../components/ui/DataTable'
import Pagination from '../../components/ui/Pagination'
import { Users, Search, Shield, MoreHorizontal } from 'lucide-react'

const students = Array.from({ length: 25 }, (_, i) => ({
  id: `OLY-2024-${String(i + 1).padStart(4, '0')}`,
  name: ['Ali Karimov', 'Zarina Ahmedova', 'Bekzod Rahimov', 'Dilnoza Xasanova', 'Javohir Abdullayev',
    'Sarvar Umarov', 'Malika Rashidova', 'Azizjon Qodirov', 'Nigora Toshmatova', 'Rustam Xudoyberdiyev',
    'Munisa Abdurahmonova', 'Jasur Ergashev', 'Sevara Shukurova', 'Oybek Abdullayev', 'Zilola Nurmatova',
    'Iskandar Ismailov', 'Gulruh Rahimova', 'Diyorjon Yusupov', 'Mohigul Sobirova', 'Farruh Hamidov',
    'Madina Umarova', 'Akmal Raximov', 'Dildora Salimova', 'Sherzod Egamberdiyev', 'Laylo Xasanova'][i],
  region: ['Toshkent', 'Samarqand', 'Buxoro', 'Andijon', 'Namangan', "Farg'ona", 'Xorazm', 'Navoiy', 'Jizzax', 'Qashqadaryo'][i % 10],
  grade: [5, 6, 7, 8, 9, 10, 11][i % 7],
  subject: ['Matematika', 'Fizika', 'Kimyo', 'Biologiya', 'Informatika'][i % 5],
  registered: `2025-${String(i + 1).padStart(2, '0')}-10`,
  status: i % 3 === 0 ? 'active' : 'active',
}))

const ITEMS_PER_PAGE = 10

export default function AdminStudents() {
  const [search, setSearch] = useState('')
  const [page, setPage] = useState(1)

  const filtered = students.filter(s =>
    s.name.toLowerCase().includes(search.toLowerCase()) ||
    s.id.toLowerCase().includes(search.toLowerCase())
  )
  const totalPages = Math.ceil(filtered.length / ITEMS_PER_PAGE)
  const paginated = filtered.slice((page - 1) * ITEMS_PER_PAGE, page * ITEMS_PER_PAGE)

  const columns = [
    { key: 'id', label: 'ID' },
    { key: 'name', label: "Ism" },
    { key: 'region', label: 'Viloyat' },
    { key: 'grade', label: 'Sinf', render: (row) => `${row.grade}-sinf` },
    { key: 'subject', label: 'Fan' },
    { key: 'registered', label: "Ro'yxatdan o'tgan" },
    {
      key: 'status', label: 'Holat',
      render: () => (
        <span className="text-xs font-medium px-2.5 py-1 rounded-full bg-emerald-100 text-emerald-700 dark:bg-emerald-500/20 dark:text-emerald-400">Faol</span>
      ),
    },
  ]

  return (
    <div className="space-y-6">
      <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}>
        <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">O'quvchilar boshqaruvi</h1>
        <p className="text-gray-500 dark:text-gray-400 text-sm mt-1">Barcha o'quvchilarni boshqaring.</p>
      </motion.div>

      <div className="sm:w-72">
        <SearchInput value={search} onChange={v => { setSearch(v); setPage(1) }} placeholder="Ism yoki ID qidirish..." />
      </div>

      <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.05 }} className="glass-card overflow-hidden">
        <DataTable columns={columns} data={paginated} emptyIcon={Users} emptyTitle="O'quvchi topilmadi" />
      </motion.div>

      <Pagination currentPage={page} totalPages={totalPages} onPageChange={setPage} />
    </div>
  )
}
