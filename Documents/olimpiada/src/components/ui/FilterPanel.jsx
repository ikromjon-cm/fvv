import { motion } from 'framer-motion'
import { Filter, X } from 'lucide-react'

export default function FilterPanel({ filters, onFilterChange, subjects, grades, onClear }) {
  const hasFilters = Object.values(filters).some(v => v)

  return (
    <div className="flex flex-wrap items-center gap-3">
      <div className="flex items-center gap-1.5 text-sm text-gray-500">
        <Filter size={16} />
        <span>Filter:</span>
      </div>

      <select
        value={filters.subject}
        onChange={e => onFilterChange({ ...filters, subject: e.target.value })}
        className="input-field py-2 px-3 text-sm w-auto min-w-[140px]"
      >
        <option value="">Barcha fanlar</option>
        {subjects.map(s => <option key={s} value={s}>{s}</option>)}
      </select>

      <select
        value={filters.grade}
        onChange={e => onFilterChange({ ...filters, grade: e.target.value })}
        className="input-field py-2 px-3 text-sm w-auto min-w-[120px]"
      >
        <option value="">Barcha sinflar</option>
        {grades.map(g => <option key={g} value={g}>{g}-sinf</option>)}
      </select>

      <select
        value={filters.status}
        onChange={e => onFilterChange({ ...filters, status: e.target.value })}
        className="input-field py-2 px-3 text-sm w-auto min-w-[130px]"
      >
        <option value="">Barcha holatlar</option>
        <option value="open">Ochiq</option>
        <option value="coming_soon">Tez kunda</option>
        <option value="closed">Yopilgan</option>
      </select>

      {hasFilters && (
        <button
          onClick={onClear}
          className="flex items-center gap-1 text-sm text-red-500 hover:text-red-600 transition-colors"
        >
          <X size={16} />
          Tozalash
        </button>
      )}
    </div>
  )
}
