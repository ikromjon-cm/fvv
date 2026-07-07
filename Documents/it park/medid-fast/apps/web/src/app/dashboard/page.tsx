'use client'

import { useEffect, useState, useRef, useMemo } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  Shield,
  Activity,
  Camera,
  X,
  Play,
  Search,
  ExternalLink,
  List,
} from 'lucide-react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { useFvvStore } from '@/store/fvvStore'
import { navItems, getUserRole } from '@/lib/roles'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card'
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
    <div className="h-screen overflow-hidden bg-medid-surface flex flex-col">
      {/* Top Stats Bar */}
      <div className="shrink-0 bg-medid-navy px-3 sm:px-6 py-2 sm:py-3">
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

      {/* Main Content - Video Wall Layout */}
      <div className="flex-1 flex overflow-hidden">
        {/* Center - Map Area */}
        <div className="flex-1 relative bg-[#0A1628]/90 overflow-hidden">
          <FvvMap incidents={filteredIncidents} selectedId={selectedIncident?.id} onSelect={setSelectedIncident} />

          {/* Alert Log Overlay - Bottom Right */}
          <div className="absolute bottom-3 right-3 w-72">
            <AnimatePresence>
              {alertLog.map((msg) => (
                <motion.div
                  key={msg}
                  initial={{ opacity: 0, x: 20 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: 20 }}
                  className="text-[11px] text-white/70 bg-black/50 rounded px-2 py-1 mb-1 font-mono"
                >
                  {msg}
                </motion.div>
              ))}
            </AnimatePresence>
          </div>

          {/* Category Filters */}
          <div className="absolute top-3 left-3 flex gap-1.5 flex-wrap max-w-md">
            <button
              onClick={() => setFilterCat('all')}
              className={`px-2.5 py-1 rounded-full text-[11px] font-medium transition-colors ${
                filterCat === 'all' ? 'bg-[#0066FF] text-white' : 'bg-black/40 text-white/70 hover:bg-black/60'
              }`}
            >
              Barchasi ({incidents.length})
            </button>
            {categories.map((cat) => (
              <button
                key={cat}
                onClick={() => setFilterCat(cat)}
                className={`px-2.5 py-1 rounded-full text-[11px] font-medium transition-colors whitespace-nowrap ${
                  filterCat === cat ? 'bg-[#0066FF] text-white' : 'bg-black/40 text-white/70 hover:bg-black/60'
                }`}
              >
                {cat}
              </button>
            ))}
          </div>
        </div>

        {/* Sidebar Overlay (mobile) */}
        {sidebarOpen && <div className="fixed inset-0 bg-black/50 z-20 lg:hidden" onClick={() => setSidebarOpen(false)} />}

        {/* Right Sidebar - Incidents List */}
        <div className={`${sidebarOpen ? 'fixed right-0 top-0 bottom-0 w-full sm:w-96 z-30' : 'hidden'} lg:relative lg:block lg:w-96 shrink-0 border-l border-medid-border bg-medid-card flex flex-col`}>
          <div className="shrink-0 px-4 py-3 border-b border-medid-border space-y-2">
            <div className="flex items-center justify-between">
              <h2 className="text-sm font-semibold text-medid-text">Hodisalar ro'yxati</h2>
              <button onClick={() => setSidebarOpen(false)} className="lg:hidden p-1 rounded hover:bg-gray-100">
                <X className="h-4 w-4 text-medid-muted" />
              </button>
            </div>
            <div className="flex gap-1.5">
              <div className="relative flex-1">
                <Search className="absolute left-2 top-1/2 -translate-y-1/2 h-3 w-3 text-medid-muted" />
                <input
                  type="text"
                  placeholder="Qidirish..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="w-full pl-7 pr-2 py-1.5 text-[11px] rounded-lg border border-medid-border bg-medid-surface text-medid-text placeholder:text-medid-muted focus:outline-none focus:border-[#0066FF]"
                />
              </div>
              <select
                value={filterStatus}
                onChange={(e) => setFilterStatus(e.target.value)}
                className="text-[11px] px-2 py-1.5 rounded-lg border border-medid-border bg-medid-surface text-medid-text focus:outline-none focus:border-[#0066FF]"
              >
                <option value="all">Barcha</option>
                <option value="UNDER_INVESTIGATION">Tekshirilmoqda</option>
                <option value="IN_PROGRESS">Jarayonda</option>
                <option value="RESOLVED">Hal qilingan</option>
              </select>
            </div>
          </div>
          <div className="flex-1 overflow-y-auto scrollbar-thin p-3 space-y-2">
            {isLoading ? (
              Array.from({ length: 4 }).map((_, i) => (
                <div key={i} className="animate-pulse rounded-xl bg-gray-100 p-4 h-24" />
              ))
            ) : (
              <AnimatePresence>
                {filteredIncidents.map((inc, idx) => (
                  <motion.div
                    key={inc.id}
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: idx * 0.05 }}
                    onClick={() => setSelectedIncident(inc)}
                    onDoubleClick={() => router.push(`/incidents/${inc.id}`)}
                    className={`group rounded-xl border p-3 cursor-pointer transition-all duration-200 hover:shadow-md ${
                      selectedIncident?.id === inc.id
                        ? 'border-[#0066FF] bg-[#0066FF]/5 shadow-sm'
                        : 'border-medid-border bg-medid-card hover:border-medid-muted/30'
                    }`}
                  >
                    <div className="flex gap-3">
                      <img
                        src={inc.initial_report_photo}
                        alt=""
                        className="h-14 w-14 rounded-lg object-cover shrink-0"
                        onError={(e) => { (e.target as HTMLImageElement).src = 'https://via.placeholder.com/200x150?text=No+Image' }}
                      />
                      <div className="min-w-0 flex-1">
                        <div className="flex items-center gap-1.5 flex-wrap">
                          <Badge
                            variant={
                              inc.severity === 'CRITICAL' ? 'danger' :
                              inc.severity === 'HIGH' ? 'warning' :
                              inc.severity === 'MEDIUM' ? 'info' : 'success'
                            }
                            size="sm"
                          >
                            {severityConfig[inc.severity]?.label || inc.severity}
                          </Badge>
                          <span className="text-[11px] font-mono text-medid-muted">{inc.id}</span>
                        </div>
                        <p className="text-sm font-medium text-medid-text truncate mt-1">{inc.category}</p>
                        <p className="text-[11px] text-medid-muted truncate">
                          {inc.neighborhood} • {inc.household_address}
                        </p>
                        <div className="flex items-center gap-2 mt-1">
                          <span className={`text-[10px] px-1.5 py-0.5 rounded-full ${statusConfig[inc.status]?.color || ''} text-white`}>
                            {statusConfig[inc.status]?.label || inc.status}
                          </span>
                          <span className="text-[10px] text-medid-muted">{inc.inspection_timestamp}</span>
                        </div>
                      </div>
                      <div className="shrink-0 self-center opacity-0 group-hover:opacity-100 transition-opacity">
                        <ExternalLink className="h-4 w-4 text-medid-muted" />
                      </div>
                    </div>
                  </motion.div>
                ))}
              </AnimatePresence>
            )}
          </div>
        </div>
      </div>

      {/* Selected Incident Detail Panel */}
      <AnimatePresence>
        {selectedIncident && (
          <motion.div
            initial={{ opacity: 0, y: 300 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 300 }}
            className="fixed bottom-0 left-0 right-0 z-50 bg-medid-card border-t border-medid-border shadow-2xl"
          >
            <div className="max-w-7xl mx-auto p-3 sm:p-4">
              <div className="flex flex-col sm:flex-row items-start gap-4 sm:gap-6">
                {/* Photo 1 */}
                <div className="w-full sm:w-48 shrink-0">
                  <p className="text-[11px] font-medium text-medid-muted mb-1">❌ Muammo (Foto-1)</p>
                  <img
                    src={selectedIncident.initial_report_photo}
                    alt=""
                    className="w-full h-32 rounded-lg object-cover border border-medid-border"
                    onError={(e) => { (e.target as HTMLImageElement).src = 'https://via.placeholder.com/400x300?text=No+Image' }}
                  />
                </div>

                {/* Info */}
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <h3 className="text-base font-semibold text-medid-text">{selectedIncident.category}</h3>
                    <Badge variant={selectedIncident.severity === 'CRITICAL' ? 'danger' : selectedIncident.severity === 'HIGH' ? 'warning' : 'info'}>
                      {severityConfig[selectedIncident.severity]?.label || selectedIncident.severity}
                    </Badge>
                  </div>
                  <div className="mt-2 grid grid-cols-3 gap-2 text-sm">
                    <div>
                      <span className="text-medid-muted text-[11px]">Manzil:</span>
                      <p className="text-medid-text text-xs">{selectedIncident.neighborhood}, {selectedIncident.household_address}</p>
                    </div>
                    <div>
                      <span className="text-medid-muted text-[11px]">Xodim:</span>
                      <p className="text-medid-text text-xs">{selectedIncident.reporter}</p>
                    </div>
                    <div>
                      <span className="text-medid-muted text-[11px]">Muddat:</span>
                      <p className="text-medid-text text-xs">{selectedIncident.resolution_deadline}</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2 mt-2">
                    <Badge variant={selectedIncident.validation_status === 'APPROVED' ? 'success' : selectedIncident.validation_status === 'REJECTED' ? 'danger' : 'warning'} size="sm">
                      {validationConfig[selectedIncident.validation_status]?.label}
                    </Badge>
                    <span className="text-xs text-medid-muted">{selectedIncident.inspection_timestamp}</span>
                  </div>
                </div>

                {/* Photo 2 or placeholder */}
                <div className="w-full sm:w-48 shrink-0">
                  <p className="text-[11px] font-medium text-medid-muted mb-1">✅ Hal qilingan (Foto-2)</p>
                  {selectedIncident.resolved_photo ? (
                    <img
                      src={selectedIncident.resolved_photo}
                      alt=""
                      className="w-full h-32 rounded-lg object-cover border border-medid-border"
                      onError={(e) => { (e.target as HTMLImageElement).src = 'https://via.placeholder.com/400x300?text=No+Image' }}
                    />
                  ) : (
                    <div className="w-full h-32 rounded-lg border-2 border-dashed border-medid-border flex items-center justify-center bg-gray-50">
                      <div className="text-center">
                        <Camera className="h-6 w-6 text-medid-muted mx-auto" />
                        <p className="text-[11px] text-medid-muted mt-1">Xodim tasviri kutilmoqda</p>
                      </div>
                    </div>
                  )}
                </div>

                {/* Close */}
                <button
                  onClick={() => setSelectedIncident(null)}
                  className="shrink-0 p-1 rounded-lg hover:bg-medid-surface text-medid-muted"
                >
                  <X className="h-5 w-5" />
                </button>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
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
    <div className="absolute inset-0">
      <LeafletMap center={center} zoom={14} markers={markers} className="w-full h-full" />
    </div>
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
