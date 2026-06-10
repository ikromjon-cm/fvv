import { Link } from 'react-router-dom'
import { GraduationCap, Mail, Phone, MapPin, Heart } from 'lucide-react'

export default function Footer() {
  return (
    <footer className="bg-white dark:bg-gray-900 border-t border-gray-200 dark:border-gray-800">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 md:py-16">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8 lg:gap-12">
          <div className="lg:col-span-1">
            <Link to="/" className="flex items-center gap-2.5 mb-4">
              <div className="p-2 rounded-xl bg-gradient-to-br from-indigo-500 to-violet-600 text-white">
                <GraduationCap size={22} />
              </div>
              <span className="text-lg font-bold gradient-text">Olimpiada</span>
            </Link>
            <p className="text-sm text-gray-500 dark:text-gray-400 leading-relaxed">
              O'quvchilar uchun zamonaviy olimpiada platformasi. Bilim va iste'dodni rivojlantirishga qaratilgan.
            </p>
          </div>

          <div>
            <h3 className="font-semibold text-sm text-gray-900 dark:text-gray-100 mb-4">Sahifalar</h3>
            <ul className="space-y-2.5">
              {[
                { to: '/olimpiadalar', label: 'Olimpiadalar' },
                { to: '/natijalar', label: 'Natijalar' },
                { to: '/sertifikatlar', label: 'Sertifikatlar' },
                { to: '/login', label: 'Kirish' },
                { to: '/register', label: "Ro'yxatdan o'tish" },
              ].map(link => (
                <li key={link.to}>
                  <Link to={link.to} className="text-sm text-gray-500 dark:text-gray-400 hover:text-indigo-600 dark:hover:text-indigo-400 transition-colors">
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h3 className="font-semibold text-sm text-gray-900 dark:text-gray-100 mb-4">Fanlar</h3>
            <ul className="space-y-2.5">
              {['Matematika', 'Fizika', 'Kimyo', 'Biologiya', 'Informatika', 'Ingliz tili'].map(s => (
                <li key={s}>
                  <Link to="/olimpiadalar" className="text-sm text-gray-500 dark:text-gray-400 hover:text-indigo-600 dark:hover:text-indigo-400 transition-colors">
                    {s}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h3 className="font-semibold text-sm text-gray-900 dark:text-gray-100 mb-4">Bog'lanish</h3>
            <ul className="space-y-3">
              <li className="flex items-center gap-2.5 text-sm text-gray-500 dark:text-gray-400">
                <Mail size={16} className="shrink-0" />
                info@olimpiada.uz
              </li>
              <li className="flex items-center gap-2.5 text-sm text-gray-500 dark:text-gray-400">
                <Phone size={16} className="shrink-0" />
                +998 71 200 00 00
              </li>
              <li className="flex items-center gap-2.5 text-sm text-gray-500 dark:text-gray-400">
                <MapPin size={16} className="shrink-0" />
                Toshkent, O'zbekiston
              </li>
            </ul>
          </div>
        </div>

        <hr className="my-8 border-gray-200 dark:border-gray-800" />
        <div className="flex flex-col md:flex-row items-center justify-between gap-4">
          <p className="text-xs text-gray-400 dark:text-gray-500">
            &copy; {new Date().getFullYear()} Olimpiada. Barcha huquqlar himoyalangan.
          </p>
          <p className="text-xs text-gray-400 dark:text-gray-500 flex items-center gap-1">
            Made with <Heart size={12} className="text-red-400" /> for education
          </p>
        </div>
      </div>
    </footer>
  )
}
