'use client'

import { useEffect, useState, useRef, useMemo } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  Shield,
  Activity,
  Play,
  Search,
  List,
} from 'lucide-react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { useFvvStore } from '@/store/fvvStore'
import { navItems, getUserRole } from '@/lib/roles'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { NotificationBell } from '@/components/shared/notification-bell'
import dynamic from 'next/dynamic'

const LeafletMap = dynamic(() => import('@/components/shared/leaflet-map').then((m) => m.LeafletMap), { ssr: false })

const severityConfig = {
  CRITICAL: { color: 'bg-[#DC2626]', text: 'text-white', label: 'Kritik', pulse: true },
  HIGH: { color: 'bg-[#F59E0B]', text: 'text-white', label: 'Yuqori', pulse: false },
  MEDIUM: { color: 'bg-[#3B82F6]', text: 'text-white', label: "O'rtacha", pulse: false },
  LOW: { color: 'bg-[#22C55E]', text: 'text-white', label: 'Past', pulse: false },
}

const statusConfig: Record<string, { label: string; color: string }> = {
  UNDER_INVESTIGATION: { label: 'Tekshirilmoqda', color: 'bg-[#F59E0B]' },
  IN_PROGRESS: { label: 'Jarayonda', color: 'bg-[#3B82F6]' },
  RESOLVED: { label: 'Hal qilingan', color: 'bg-[#22C55E]' },
}

const validationConfig: Record<string, { label: string; color: string }> = {
  PENDING_APPROVAL: { label: 'Tasdiqlanmagan', color: 'bg-[#F59E0B]/20 text-[#F59E0B]' },
  APPROVED: { label: 'Tasdiqlangan', color: 'bg-[#22C55E]/20 text-[#22C55E]' },
  REJECTED: { label: 'Rad etilgan', color: 'bg-[#DC2626]/20 text-[#DC2626]' },
}

export default function DashboardPage() {
  const router = useRouter()
  const {
    incidents,
    stats,
    isLoading,
    selectedIncident,
    fetchIncidents,
    fetchStats,
    simulateNew,
    triggerSiren,
    setSelectedIncident,
  } = useFvvStore()

  const [filterCat, setFilterCat] = useState('all')
  const [filterStatus, setFilterStatus] = useState<string>('all')
  const [searchQuery, setSearchQuery] = useState('')
  const [sidebarOpen, setSidebarOpen] = useState(true)
  const [alertLog, setAlertLog] = useState<string[]>([])
  const [autoSimulate, setAutoSimulate] = useState(false)
  const autoRef = useRef<ReturnType<typeof setInterval> | undefined>(undefined)

  useEffect(() => {
    fetchIncidents().catch(console.error)
    fetchStats().catch(console.error)
  }, [fetchIncidents, fetchStats])

  useEffect(() => {
    if (autoSimulate) {
      const delay = 15000 + Math.random() * 10000
      autoRef.current = setInterval(async () => {
        try {
          await simulateNew()
          const latest = useFvvStore.getState().incidents
          const critical = latest.filter((i) => i.severity === 'CRITICAL' && i.status !== 'RESOLVED')
          if (critical.length > 0) await triggerSiren()
          setAlertLog((prev) => [`🆕 Yangi hodisa aniqlandi — ${new Date().toLocaleTimeString()}`, ...prev.slice(0, 9)])
        } catch (e) { console.error(e) }
      }, delay)
    } else {
      clearInterval(autoRef.current)
    }
    return () => clearInterval(autoRef.current)
  }, [autoSimulate, simulateNew, triggerSiren])

  const filteredIncidents = incidents
    .filter((i) => filterCat === 'all' || i.category === filterCat)
    .filter((i) => filterStatus === 'all' || i.status === filterStatus)
    .filter((i) => !searchQuery || i.id.toLowerCase().includes(searchQuery.toLowerCase()) || i.neighborhood.toLowerCase().includes(searchQuery.toLowerCase()) || i.household_address.toLowerCase().includes(searchQuery.toLowerCase()))

  const categories = [...new Set(incidents.map((i) => i.category))]

  const latestCritical = incidents.filter((i) => i.severity === 'CRITICAL' && i.status !== 'RESOLVED')

  return (
    <div className="bg-medid-surface">
      {/* Top Stats Bar */}
      <div className="bg-medid-navy px-3 sm:px-6 py-2 sm:py-3">
        <div className="flex items-center justify-between mb-2">
          <div className="flex items-center gap-3">
            <Shield className="h-6 w-6 text-[#0066FF]" />
            <h1 className="text-lg font-bold text-white">FVV Ekotizimi</h1>
            <span className="text-xs text-gray-400">| Uychi tumani, Namangan viloyati</span>
          </div>
          <div className="flex items-center gap-3">
            {latestCritical.length > 0 && (
              <motion.div
                animate={{ scale: [1, 1.05, 1] }}
                transition={{ duration: 1, repeat: Infinity }}
                className="hidden sm:flex items-center gap-1.5"
              >
                <span className="flex h-2 w-2 rounded-full bg-[#DC2626]" />
                <span className="text-xs text-[#DC2626] font-bold">{latestCritical.length} ta kritik</span>
              </motion.div>
            )}
            <div className="hidden md:flex items-center gap-1">
              <DynamicNavLinks />
            </div>
            <NotificationBell />
            <Button variant="outline" size="xs" onClick={() => setSidebarOpen(!sidebarOpen)} className="lg:hidden text-white border-white/20 hover:bg-white/10">
              <List className="h-3 w-3" />
            </Button>
            <Button variant="outline" size="xs" onClick={() => simulateNew()} className="hidden sm:inline-flex text-white border-white/20 hover:bg-white/10">
              <Play className="h-3 w-3" /> Simulyatsiya
            </Button>
            <Button
              variant={autoSimulate ? 'danger' : 'outline'}
              size="xs"
              onClick={() => setAutoSimulate(!autoSimulate)}
              className={autoSimulate ? 'hidden sm:inline-flex' : 'hidden sm:inline-flex text-white border-white/20 hover:bg-white/10'}
            >
              <Activity className="h-3 w-3" />
            </Button>
          </div>
        </div>
        <div className="grid grid-cols-2 sm:grid-cols-4 lg:grid-cols-7 gap-2 sm:gap-3">
          <StatCard label="Jami hodisalar" value={stats.total} color="text-white" />
          <StatCard label="Kutilayotgan" value={stats.pending} color="text-[#F59E0B]" />
          <StatCard label="Jarayonda" value={stats.inProgress} color="text-[#3B82F6]" />
          <StatCard label="Hal qilingan" value={stats.resolved} color="text-[#22C55E]" />
          <StatCard label="Kritik" value={stats.critical} color="text-[#DC2626]" />
          <StatCard label="Bugungi" value={stats.todayNew} color="text-[#06B6D4]" />
          <StatCard label="Faol xodimlar" value={stats.activeOfficers} color="text-[#8B5CF6]" />
        </div>
      </div>

      {/* Map Section */}
      <div className="p-4 sm:p-6">
        <div className="max-w-7xl mx-auto">
          <div className="rounded-xl overflow-hidden border border-medid-border" style={{ height: 400 }}>
            <FvvMap incidents={filteredIncidents} selectedId={selectedIncident?.id} onSelect={setSelectedIncident} />
          </div>

          {/* Alert Log */}
          <div className="mt-3 flex flex-wrap gap-2">
            {alertLog.map((msg, i) => (
              <span key={i} className="text-[11px] bg-black/5 rounded px-2 py-1 text-medid-muted font-mono">{msg}</span>
            ))}
          </div>
        </div>
      </div>

      {/* Incidents Section */}
      <div className="pb-6">
        <div className="max-w-7xl mx-auto px-4 sm:px-6">
          <div className="flex items-center gap-3 mb-4">
            <h2 className="text-base font-semibold text-medid-text">Hodisalar</h2>
            <div className="flex gap-1.5 flex-1">
              {categories.map((cat) => (
                <button
                  key={cat}
                  onClick={() => setFilterCat(cat)}
                  className={`px-2.5 py-1 rounded-full text-[11px] font-medium transition-colors ${
                    filterCat === cat ? 'bg-[#0066FF] text-white' : 'bg-medid-card border border-medid-border text-medid-muted hover:bg-medid-surface'
                  }`}
                >
                  {cat}
                </button>
              ))}
            </div>
            <div className="relative w-48">
              <Search className="absolute left-2 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-medid-muted" />
              <input
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Qidirish..."
                className="w-full pl-7 pr-2 py-1.5 text-xs rounded-lg border border-medid-border bg-medid-card text-medid-text placeholder:text-medid-muted focus:outline-none focus:border-[#0066FF]"
              />
            </div>
            <select
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value)}
              className="text-xs px-2 py-1.5 rounded-lg border border-medid-border bg-medid-card text-medid-text focus:outline-none focus:border-[#0066FF]"
            >
              <option value="all">Barcha</option>
              <option value="UNDER_INVESTIGATION">Tekshirilmoqda</option>
              <option value="IN_PROGRESS">Jarayonda</option>
              <option value="RESOLVED">Hal qilingan</option>
            </select>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
            {isLoading ? (
              Array.from({ length: 6 }).map((_, i) => (
                <div key={i} className="animate-pulse rounded-xl bg-medid-card p-4 h-28 border border-medid-border" />
              ))
            ) : filteredIncidents.length === 0 ? (
              <div className="col-span-full text-center py-12 text-medid-muted text-sm">Hodisalar mavjud emas</div>
            ) : (
              filteredIncidents.map((inc, idx) => (
                <motion.div
                  key={inc.id}
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: idx * 0.03 }}
                  onClick={() => setSelectedIncident(inc)}
                  onDoubleClick={() => router.push(`/incidents/${inc.id}`)}
                  className="group rounded-xl border border-medid-border bg-medid-card p-4 cursor-pointer transition-all hover:shadow-md"
                >
                  <div className="flex gap-3">
                    <img
                      src={inc.initial_report_photo}
                      alt=""
                      className="h-14 w-14 rounded-lg object-cover shrink-0"
                      onError={(e) => { (e.target as HTMLImageElement).style.display = 'none' }}
                    />
                    <div className="min-w-0 flex-1">
                      <div className="flex items-center gap-1.5 flex-wrap">
                        <Badge variant={inc.severity === 'CRITICAL' ? 'danger' : inc.severity === 'HIGH' ? 'warning' : inc.severity === 'MEDIUM' ? 'info' : 'success'} size="sm">
                          {severityConfig[inc.severity]?.label || inc.severity}
                        </Badge>
                        <span className="text-[11px] font-mono text-medid-muted">{inc.id}</span>
                      </div>
                      <p className="text-sm font-medium text-medid-text truncate mt-1">{inc.category}</p>
                      <p className="text-[11px] text-medid-muted truncate">{inc.neighborhood} • {inc.household_address}</p>
                      <div className="flex items-center gap-2 mt-1">
                        <span className={`text-[10px] px-1.5 py-0.5 rounded-full ${statusConfig[inc.status]?.color || ''} text-white`}>
                          {statusConfig[inc.status]?.label || inc.status}
                        </span>
                        <span className="text-[10px] text-medid-muted">{inc.inspection_timestamp}</span>
                      </div>
                    </div>
                  </div>
                </motion.div>
              ))
            )}
          </div>
        </div>
      </div>
    </div>
  )
}

function StatCard({ label, value, color }: { label: string; value: number; color: string }) {
  const [displayValue, setDisplayValue] = useState(value)
  const prevRef = useRef(value)
  useEffect(() => {
    if (value === prevRef.current) return
    prevRef.current = value
    const duration = 500
    const steps = 20
    const increment = value / steps
    let current = 0
    const timer = setInterval(() => {
      current += increment
      if (current >= value) {
        setDisplayValue(value)
        clearInterval(timer)
      } else {
        setDisplayValue(Math.round(current))
      }
    }, duration / steps)
    return () => clearInterval(timer)
  }, [value])
  return (
    <div className="bg-white/5 rounded-lg px-4 py-2 border border-white/10">
      <p className="text-[11px] text-gray-400">{label}</p>
      <p className={`text-2xl font-bold tabular-nums ${color}`}>{displayValue}</p>
    </div>
  )
}

function FvvMap({
  incidents,
  selectedId,
  onSelect,
}: {
  incidents: import('@/mock/data').FvvIncident[]
  selectedId?: string
  onSelect: (i: import('@/mock/data').FvvIncident) => void
}) {
  const center = useMemo<[number, number]>(() => [41.053, 71.77], [])

  const markers = useMemo(
    () =>
      incidents.map((inc) => ({
        id: inc.id,
        coordinates: inc.coordinates,
        severity: inc.severity,
        label: inc.id,
        onClick: () => onSelect(inc),
      })),
    [incidents, onSelect],
  )

  return (
    <LeafletMap center={center} zoom={14} markers={markers} className="w-full h-full" />
  )
}

function DynamicNavLinks() {
  const role = getUserRole()
  const links = role ? navItems[role].filter((l) => l.href !== '/dashboard' && l.href !== '/profile') : []
  return (
    <>
      {links.map((l) => (
        <Link key={l.href} href={l.href} className="px-2 py-1 text-xs text-white/60 hover:text-white hover:bg-white/5 rounded-lg transition-colors">
          {l.label}
        </Link>
      ))}
    </>
  )
}
