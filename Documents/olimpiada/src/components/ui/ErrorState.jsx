import { AlertTriangle, RefreshCw } from 'lucide-react'

export default function ErrorState({ message = 'Xatolik yuz berdi', onRetry }) {
  return (
    <div className="flex flex-col items-center justify-center py-16 text-center">
      <div className="p-4 rounded-2xl bg-red-50 dark:bg-red-500/10 mb-4">
        <AlertTriangle size={40} className="text-red-400" />
      </div>
      <h3 className="text-lg font-medium text-gray-900 dark:text-gray-100 mb-1">{message}</h3>
      <p className="text-sm text-gray-500 dark:text-gray-400 mb-4">Iltimos, qaytadan urinib ko'ring</p>
      {onRetry && (
        <button onClick={onRetry} className="flex items-center gap-2 px-4 py-2 rounded-xl bg-indigo-50 dark:bg-indigo-500/10 text-indigo-600 dark:text-indigo-400 hover:bg-indigo-100 dark:hover:bg-indigo-500/20 transition-colors text-sm font-medium">
          <RefreshCw size={16} />
          Qayta urinish
        </button>
      )}
    </div>
  )
}
