import { motion } from 'framer-motion'
import { ChevronDown, ArrowUpDown, ArrowUp, ArrowDown } from 'lucide-react'
import { useState } from 'react'
import EmptyState from './EmptyState'
import LoadingSpinner from './LoadingSpinner'

export default function DataTable({
  columns,
  data,
  loading,
  emptyIcon,
  emptyTitle = "Ma'lumot topilmadi",
  emptyDescription,
  sortColumn,
  sortDirection,
  onSort,
  onRowClick,
}) {
  const [hoveredRow, setHoveredRow] = useState(null)

  if (loading) return <LoadingSpinner text="Ma'lumotlar yuklanmoqda..." />

  if (!data || data.length === 0) {
    return <EmptyState icon={emptyIcon} title={emptyTitle} description={emptyDescription} />
  }

  const SortIcon = ({ column }) => {
    if (sortColumn !== column) return <ArrowUpDown size={14} className="text-gray-400" />
    return sortDirection === 'asc' ? <ArrowUp size={14} /> : <ArrowDown size={14} />
  }

  return (
    <div className="overflow-x-auto">
      <table className="w-full text-sm">
        <thead>
          <tr className="border-b border-gray-200 dark:border-gray-700">
            {columns.map((col, i) => (
              <th
                key={i}
                className={`px-4 py-3.5 text-left text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider ${
                  col.sortable ? 'cursor-pointer hover:text-gray-700 dark:hover:text-gray-200 select-none' : ''
                }`}
                onClick={() => col.sortable && onSort && onSort(col.key)}
              >
                <div className="flex items-center gap-1.5">
                  {col.label}
                  {col.sortable && <SortIcon column={col.key} />}
                </div>
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {data.map((row, rowIdx) => (
            <motion.tr
              key={row.id || rowIdx}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: rowIdx * 0.03 }}
              className={`border-b border-gray-100 dark:border-gray-800/50 transition-colors ${
                onRowClick ? 'cursor-pointer' : ''
              } ${
                hoveredRow === rowIdx ? 'bg-indigo-50/50 dark:bg-indigo-500/5' : ''
              }`}
              onClick={() => onRowClick && onRowClick(row)}
              onMouseEnter={() => setHoveredRow(rowIdx)}
              onMouseLeave={() => setHoveredRow(null)}
            >
              {columns.map((col, colIdx) => (
                <td key={colIdx} className="px-4 py-3.5 text-gray-700 dark:text-gray-300 whitespace-nowrap">
                  {col.render ? col.render(row) : row[col.key]}
                </td>
              ))}
            </motion.tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
