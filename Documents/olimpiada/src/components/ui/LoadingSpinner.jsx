import { motion } from 'framer-motion'

export default function LoadingSpinner({ size = 'md', text = 'Yuklanmoqda...' }) {
  const sizes = { sm: 'w-5 h-5', md: 'w-8 h-8', lg: 'w-12 h-12' }

  return (
    <div className="flex flex-col items-center justify-center gap-3 py-12">
      <motion.div
        className={`${sizes[size]} border-4 border-indigo-200 dark:border-indigo-900 border-t-indigo-600 rounded-full`}
        animate={{ rotate: 360 }}
        transition={{ duration: 0.8, repeat: Infinity, ease: 'linear' }}
      />
      {text && <p className="text-sm text-gray-500 dark:text-gray-400">{text}</p>}
    </div>
  )
}
