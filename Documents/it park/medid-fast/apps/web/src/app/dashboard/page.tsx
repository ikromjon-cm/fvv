'use client'

import { useEffect, useState, useRef, useMemo } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  Shield,
  Activity,
  Play,
  Search,
  List,
  MapPin,
  ArrowUpRight,
  X,
} from 'lucide-react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { useFvvStore } from '@/store/fvvStore'
import { navItems, getUserRole } from '@/lib/roles'
import { Badge } from '@/components/ui/badge'
import { NotificationBell } from '@/components/shared/notification-bell'
import dynamic from 'next/dynamic'

const LeafletMap = dynamic(() => import('@/components/shared/leaflet-map').then((m) => m.LeafletMap), { ssr: false })

const severityConfig = {
  CRITICAL: { label: 'Kritik', variant: 'danger' as const },
  HIGH: { label: 'Yuqori', variant: 'warning' as const },
  MEDIUM: { label: "O'rtacha", variant: 'info' as const },
  LOW: { label: 'Past', variant: 'success' as const },
}

const statusConfig: Record<string, { label: string; variant: 'default' | 'success' | 'warning' | 'info' }> = {
  UNDER_INVESTIGATION: { label: 'Tekshirilmoqda', variant: 'warning' },
  IN_PROGRESS: { label: 'Jarayonda', variant: 'info' },
  RESOLVED: { label: 'Hal qilingan', variant: 'success' },
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
          setAlertLog((prev) => [`Yangi hodisa aniqlandi — ${new Date().toLocaleTimeString()}`, ...prev.slice(0, 9)])
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
    <div className="min-h-full">
      {/* ---------- Command Deck ---------- */}
      <div className="relative overflow-hidden bg-gradient-to-br from-medid-navy via-medid-navy to-[#0d1a33] px-4 sm:px-6 pt-4 pb-6 sm:pt-6 sm:pb-8">
        {/* Ambient orbs */}
        <div aria-hidden className="pointer-events-none absolute -top-28 -left-16 h-80 w-80 rounded-full bg-medid-primary/25 blur-[100px]" />
        <div aria-hidden className="pointer-events-none absolute -top-16 right-24 h-64 w-64 rounded-full bg-medid-success/12 blur-[90px]" />
        <div aria-hidden className="pointer-events-none absolute inset-x-0 bottom-0 h-px bg-gradient-to-r from-transparent via-white/10 to-transparent" />

        <div className="relative max-w-7xl mx-auto">
          {/* Header row */}
          <div className="flex items-center justify-between gap-3 mb-5 sm:mb-6">
            <div className="flex items-center gap-3 min-w-0">
              <div className="relative flex items-center justify-center w-10 h-10 rounded-2xl bg-gradient-to-br from-medid-primary to-medid-primary-dark shadow-[0_6px_18px_-4px_rgba(37,99,235,0.7),inset_0_1px_0_rgba(255,255,255,0.25)] shrink-0">
                <Shield className="h-[20px] w-[20px] text-white" strokeWidth={2.25} />
              </div>
              <div className="min-w-0">
                <h1 className="font-display text-lg sm:text-xl font-bold tracking-tight text-white truncate">FVV Ekotizimi</h1>
                <p className="text-[11px] sm:text-xs text-white/45 truncate flex items-center gap-1.5">
                  <MapPin className="h-3 w-3" strokeWidth={1.75} /> Uychi tumani, Namangan viloyati
                </p>
              </div>
            </div>

            <div className="flex items-center gap-2 sm:gap-2.5">
              {latestCritical.length > 0 && (
                <motion.div
                  animate={{ scale: [1, 1.04, 1] }}
                  transition={{ duration: 1.4, repeat: Infinity, ease: 'easeInOut' }}
                  className="hidden sm:flex items-center gap-2 rounded-full bg-medid-emergency/15 px-3 py-1.5 ring-1 ring-inset ring-medid-emergency/30"
                >
                  <span className="relative flex h-2 w-2">
                    <span className="absolute inline-flex h-full w-full rounded-full bg-medid-emergency opacity-60 animate-ping" />
                    <span className="relative inline-flex h-2 w-2 rounded-full bg-medid-emergency" />
                  </span>
                  <span className="text-xs font-semibold text-medid-emergency">{latestCritical.length} ta kritik</span>
                </motion.div>
              )}
              <div className="hidden 2xl:flex items-center gap-0.5">
                <DynamicNavLinks />
              </div>
              <NotificationBell />
              <button
                onClick={() => setSidebarOpen(!sidebarOpen)}
                className="lg:hidden flex h-9 w-9 items-center justify-center rounded-full text-white/70 ring-1 ring-inset ring-white/15 hover:bg-white/10 transition-colors"
              >
                <List className="h-4 w-4" />
              </button>
              <button
                onClick={() => simulateNew()}
                className="hidden sm:inline-flex h-9 items-center gap-1.5 rounded-full px-3.5 text-xs font-medium text-white/80 ring-1 ring-inset ring-white/15 hover:bg-white/10 transition-[background-color,transform] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] active:scale-95"
              >
                <Play className="h-3.5 w-3.5" strokeWidth={2} /> Simulyatsiya
              </button>
              <button
                onClick={() => setAutoSimulate(!autoSimulate)}
                className={`hidden sm:inline-flex h-9 w-9 items-center justify-center rounded-full transition-[background-color,transform] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] active:scale-95 ${
                  autoSimulate
                    ? 'bg-medid-emergency text-white shadow-[0_4px_14px_-2px_rgba(225,29,72,0.6)]'
                    : 'text-white/80 ring-1 ring-inset ring-white/15 hover:bg-white/10'
                }`}
                title="Avtomatik oqim"
              >
                <Activity className={`h-4 w-4 ${autoSimulate ? 'animate-pulse-emergency' : ''}`} strokeWidth={2} />
              </button>
            </div>
          </div>

          {/* Stat strip */}
          <div className="grid grid-cols-2 sm:grid-cols-4 lg:grid-cols-7 gap-2 sm:gap-3">
            <StatCard label="Jami hodisalar" value={stats.total} accent="#93B4FF" />
            <StatCard label="Kutilayotgan" value={stats.pending} accent="#F59E0B" />
            <StatCard label="Jarayonda" value={stats.inProgress} accent="#60A5FA" />
            <StatCard label="Hal qilingan" value={stats.resolved} accent="#34D399" />
            <StatCard label="Kritik" value={stats.critical} accent="#FB7185" />
            <StatCard label="Bugungi" value={stats.todayNew} accent="#22D3EE" />
            <StatCard label="Faol xodimlar" value={stats.activeOfficers} accent="#C4B5FD" />
          </div>
        </div>
      </div>

      {/* ---------- Map ---------- */}
      <div className="px-4 sm:px-6 pt-6 sm:pt-8">
        <div className="max-w-7xl mx-auto">
          <div className="rounded-[1.75rem] bg-medid-surface-2/60 p-1.5 ring-1 ring-medid-hairline shadow-float">
            <div className="rounded-[calc(1.75rem-0.375rem)] overflow-hidden ring-1 ring-medid-hairline" style={{ height: 400 }}>
              <FvvMap incidents={filteredIncidents} selectedId={selectedIncident?.id} onSelect={setSelectedIncident} />
            </div>
          </div>

          {/* Alert log */}
          {alertLog.length > 0 && (
            <div className="mt-3 flex flex-wrap gap-2">
              {alertLog.map((msg, i) => (
                <span
                  key={i}
                  className="inline-flex items-center gap-1.5 rounded-full bg-medid-card px-2.5 py-1 text-[11px] font-mono text-medid-muted ring-1 ring-inset ring-medid-hairline shadow-soft"
                >
                  <span className="h-1.5 w-1.5 rounded-full bg-medid-primary animate-pulse-dot" />
                  {msg}
                </span>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Selected incident panel */}
      <AnimatePresence>
        {selectedIncident && (
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 30 }}
            transition={{ duration: 0.35, ease: [0.32, 0.72, 0, 1] }}
            className="fixed bottom-6 left-1/2 -translate-x-1/2 z-50 w-[calc(100%-2rem)] max-w-xl"
          >
            <div className="rounded-2xl bg-medid-card/95 p-3 ring-1 ring-medid-hairline shadow-lift backdrop-blur-xl">
              <div className="flex items-center gap-3">
                <div className="relative h-14 w-14 shrink-0 overflow-hidden rounded-xl bg-medid-surface-2 ring-1 ring-inset ring-medid-hairline">
                  <img
                    src={selectedIncident.initial_report_photo}
                    alt=""
                    className="absolute inset-0 h-full w-full object-cover"
                    onError={(e) => { (e.target as HTMLImageElement).style.visibility = 'hidden' }}
                  />
                </div>
                <div className="min-w-0 flex-1">
                  <div className="flex items-center gap-2 flex-wrap">
                    <span className="font-mono text-xs font-bold text-medid-text">{selectedIncident.id}</span>
                    <Badge variant={severityConfig[selectedIncident.severity]?.variant || 'info'} size="sm" dot pulse={selectedIncident.severity === 'CRITICAL'}>
                      {severityConfig[selectedIncident.severity]?.label || selectedIncident.severity}
                    </Badge>
                  </div>
                  <p className="text-sm font-semibold text-medid-text truncate mt-0.5">{selectedIncident.category}</p>
                  <p className="text-[11px] text-medid-muted truncate flex items-center gap-1">
                    <MapPin className="h-3 w-3" strokeWidth={1.75} /> {selectedIncident.neighborhood} • {selectedIncident.household_address}
                  </p>
                </div>
                <div className="flex items-center gap-1.5 shrink-0">
                  <Link
                    href={`/incidents/${selectedIncident.id}`}
                    className="group inline-flex items-center gap-1.5 rounded-full bg-medid-primary px-3.5 py-2 text-xs font-medium text-white shadow-soft transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 active:scale-95"
                  >
                    Batafsil
                    <ArrowUpRight className="h-3.5 w-3.5 transition-transform duration-300 group-hover:translate-x-0.5 group-hover:-translate-y-0.5" strokeWidth={2} />
                  </Link>
                  <button onClick={() => setSelectedIncident(null)} className="flex h-8 w-8 items-center justify-center rounded-full text-medid-muted hover:bg-medid-surface-2 hover:text-medid-text transition-colors active:scale-95">
                    <X className="h-4 w-4" />
                  </button>
                </div>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* ---------- Incidents ---------- */}
      <div className="px-4 sm:px-6 py-8 sm:py-10">
        <div className="max-w-7xl mx-auto">
          <div className="flex flex-col sm:flex-row sm:items-center gap-3 mb-5">
            <div className="flex items-center gap-2.5 shrink-0">
              <h2 className="font-display text-lg font-bold tracking-tight text-medid-text">Hodisalar</h2>
              <span className="rounded-full bg-medid-surface-2 px-2 py-0.5 text-xs font-medium text-medid-muted tabular-nums ring-1 ring-inset ring-medid-hairline">
                {filteredIncidents.length}
              </span>
            </div>

            <div className="flex gap-1.5 flex-1 overflow-x-auto scrollbar-thin -mx-1 px-1 sm:mx-0 sm:px-0">
              <FilterChip active={filterCat === 'all'} onClick={() => setFilterCat('all')}>Barchasi</FilterChip>
              {categories.map((cat) => (
                <FilterChip key={cat} active={filterCat === cat} onClick={() => setFilterCat(cat)}>{cat}</FilterChip>
              ))}
            </div>

            <div className="flex items-center gap-2 shrink-0">
              <div className="relative w-full sm:w-52">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-medid-muted" strokeWidth={1.75} />
                <input
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  placeholder="Qidirish..."
                  className="w-full h-10 pl-9 pr-3 text-sm rounded-full border border-medid-border bg-medid-card text-medid-text placeholder:text-medid-muted shadow-soft focus:outline-none focus:ring-2 focus:ring-medid-primary/40 focus:border-medid-primary/40 transition-shadow"
                />
              </div>
              <select
                value={filterStatus}
                onChange={(e) => setFilterStatus(e.target.value)}
                className="h-10 text-sm px-3.5 rounded-full border border-medid-border bg-medid-card text-medid-text shadow-soft focus:outline-none focus:ring-2 focus:ring-medid-primary/40 focus:border-medid-primary/40 transition-shadow"
              >
                <option value="all">Barcha holat</option>
                <option value="UNDER_INVESTIGATION">Tekshirilmoqda</option>
                <option value="IN_PROGRESS">Jarayonda</option>
                <option value="RESOLVED">Hal qilingan</option>
              </select>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {isLoading ? (
              Array.from({ length: 6 }).map((_, i) => (
                <div key={i} className="animate-pulse rounded-2xl bg-medid-card p-5 h-32 ring-1 ring-medid-hairline shadow-soft" />
              ))
            ) : filteredIncidents.length === 0 ? (
              <div className="col-span-full flex flex-col items-center justify-center py-20 text-center">
                <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-medid-surface-2 ring-1 ring-inset ring-medid-hairline mb-3">
                  <Search className="h-6 w-6 text-medid-muted" strokeWidth={1.5} />
                </div>
                <p className="text-sm text-medid-muted">Hodisalar mavjud emas</p>
              </div>
            ) : (
              filteredIncidents.map((inc, idx) => {
                const sev = severityConfig[inc.severity]
                const st = statusConfig[inc.status]
                return (
                  <motion.div
                    key={inc.id}
                    initial={{ opacity: 0, y: 16, filter: 'blur(6px)' }}
                    animate={{ opacity: 1, y: 0, filter: 'blur(0px)' }}
                    transition={{ delay: Math.min(idx * 0.04, 0.4), duration: 0.55, ease: [0.32, 0.72, 0, 1] }}
                    onClick={() => router.push(`/incidents/${inc.id}`)}
                    className="group relative rounded-2xl bg-medid-card p-5 cursor-pointer ring-1 ring-medid-hairline shadow-soft shadow-inner-hi transition-[transform,box-shadow] duration-500 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-1 hover:shadow-float"
                  >
                    <ArrowUpRight
                      className="absolute right-4 top-4 h-4 w-4 text-medid-muted opacity-0 -translate-x-1 translate-y-1 transition-all duration-500 ease-[cubic-bezier(0.32,0.72,0,1)] group-hover:opacity-100 group-hover:translate-x-0 group-hover:translate-y-0"
                      strokeWidth={2}
                    />
                    <div className="flex gap-3.5">
                      <div className="relative shrink-0">
                        <img
                          src={inc.initial_report_photo}
                          alt=""
                          className="h-16 w-16 rounded-xl object-cover ring-1 ring-inset ring-medid-hairline"
                          onError={(e) => { (e.target as HTMLImageElement).style.visibility = 'hidden' }}
                        />
                      </div>
                      <div className="min-w-0 flex-1">
                        <div className="flex items-center gap-2 flex-wrap">
                          <Badge variant={sev?.variant || 'default'} dot pulse={inc.severity === 'CRITICAL'}>
                            {sev?.label || inc.severity}
                          </Badge>
                          <span className="text-[11px] font-mono text-medid-muted">{inc.id}</span>
                        </div>
                        <p className="text-sm font-semibold text-medid-text truncate mt-1.5">{inc.category}</p>
                        <p className="text-xs text-medid-muted truncate mt-0.5">{inc.neighborhood} • {inc.household_address}</p>
                        <div className="flex items-center gap-2 mt-2.5">
                          {st && <Badge variant={st.variant} size="sm">{st.label}</Badge>}
                          <span className="text-[11px] text-medid-muted tabular-nums">{inc.inspection_timestamp}</span>
                        </div>
                      </div>
                    </div>
                  </motion.div>
                )
              })
            )}
          </div>
        </div>
      </div>
    </div>
  )
}

function FilterChip({ active, onClick, children }: { active: boolean; onClick: () => void; children: React.ReactNode }) {
  return (
    <button
      onClick={onClick}
      className={`shrink-0 whitespace-nowrap rounded-full px-3.5 py-1.5 text-xs font-medium transition-[background-color,color,box-shadow] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] active:scale-95 ${
        active
          ? 'bg-medid-primary text-white shadow-[0_4px_14px_-4px_rgba(37,99,235,0.7)]'
          : 'bg-medid-card text-medid-muted ring-1 ring-inset ring-medid-hairline hover:text-medid-text hover:bg-medid-surface-2'
      }`}
    >
      {children}
    </button>
  )
}

function StatCard({ label, value, accent }: { label: string; value: number; accent: string }) {
  const [displayValue, setDisplayValue] = useState(value)
  const prevRef = useRef(value)
  useEffect(() => {
    if (value === prevRef.current) return
    prevRef.current = value
    const duration = 600
    const steps = 24
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
    <div className="group relative rounded-2xl bg-white/[0.05] px-4 py-3 ring-1 ring-inset ring-white/10 shadow-[inset_0_1px_0_rgba(255,255,255,0.08)] transition-[background-color,transform] duration-500 ease-[cubic-bezier(0.32,0.72,0,1)] hover:bg-white/[0.08] hover:-translate-y-0.5">
      <div className="flex items-center gap-1.5">
        <span className="h-1.5 w-1.5 rounded-full" style={{ backgroundColor: accent }} />
        <p className="text-[11px] text-white/50 truncate">{label}</p>
      </div>
      <p className="font-display text-2xl sm:text-[26px] font-bold tabular-nums leading-tight mt-1" style={{ color: accent }}>
        {displayValue}
      </p>
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
        <Link
          key={l.href}
          href={l.href}
          className="rounded-full px-3 py-1.5 text-xs font-medium text-white/55 hover:text-white hover:bg-white/[0.06] transition-colors"
        >
          {l.label}
        </Link>
      ))}
    </>
  )
}
