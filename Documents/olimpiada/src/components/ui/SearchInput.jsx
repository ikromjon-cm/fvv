import { Search, X } from 'lucide-react'

export default function SearchInput({ value, onChange, placeholder = 'Qidirish...', className = '' }) {
  return (
    <div className={`relative ${className}`}>
      <Search size={18} className="absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400" />
      <input
        type="text"
        value={value}
        onChange={e => onChange(e.target.value)}
        placeholder={placeholder}
        className="input-field pl-10 pr-10"
      />
      {value && (
        <button onClick={() => onChange('')} className="absolute right-3.5 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors">
          <X size={16} />
        </button>
      )}
    </div>
  )
}
