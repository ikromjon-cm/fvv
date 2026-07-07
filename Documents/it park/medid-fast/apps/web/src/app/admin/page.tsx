'use client'

import { useEffect, useState, useMemo } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Shield, AlertTriangle, MapPin, CheckCircle, X, UserPlus, Search, Clock, Users, Activity, Cpu, ChevronRight, Phone, RefreshCw } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { useRouter } from 'next/navigation'
import dynamic from 'next/dynamic'

const MiniMap = dynamic(() => import('@/components/shared/leaflet-map').then((m) => m.LeafletMap), { ssr: false })

// ---- Mock Data ----
interface SosRequest {
  id: string
  citizenName: string
  phone: string
  problem: string
  location: string
  coordinates: [number, number]
  time: string
  status: 'yangi' | 'qabul_qilindi' | 'yopildi'
  assignedTo?: string
}

const initialSosList: SosRequest[] = [
  { id: 'SOS-001', citizenName: 'Akmal Karimov', phone: '+998 90 123 45 67', problem: 'Yong\'in', location: 'Navbahor ko\'ch, 12', coordinates: [41.055, 71.765], time: '10:23', status: 'yangi' },
  { id: 'SOS-002', citizenName: 'Dilnoza Rahimova', phone: '+998 91 234 56 78', problem: 'Tez yordam', location: 'Xamid Olimjon, 5', coordinates: [41.048, 71.775], time: '10:15', status: 'qabul_qilindi', assignedTo: 'Botir Toshmatov' },
  { id: 'SOS-003', citizenName: 'Jahongir Sobirov', phone: '+998 93 345 67 89', problem: 'Gaz sizishi', location: 'Mustaqillik, 34', coordinates: [41.06, 71.76], time: '09:58', status: 'yangi' },
]

const employees = [
  { id: 'EMP-001', name: 'Botir Toshmatov', role: 'MCHS Xodimi', status: 'online' },
  { id: 'EMP-002', name: 'Shavkat Rahimov', role: 'Tez Yordam', status: 'online' },
  { id: 'EMP-003', name: 'Gulnora Saidova', role: 'Dispecher', status: 'busy' },
  { id: 'EMP-004', name: 'Aziz Karimov', role: 'MCHS Xodimi', status: 'online' },
]

const problemColors: Record<string, string> = {
  'Yong\'in': '#DC2626',
  'MCHS': '#F59E0B',
  'Tez yordam': '#22C55E',
  'Yo\'l hodisasi': '#3B82F6',
  'Gaz sizishi': '#8B5CF6',
  'Suv toshqini': '#06B6D4',
  'Boshqa': '#64748B',
}

export default function AdminPage() {
  const router = useRouter()
  const [user, setUser] = useState<{ role: string } | null>(null)
  const [sosList, setSosList] = useState<SosRequest[]>(initialSosList)
  const [selectedSos, setSelectedSos] = useState<SosRequest | null>(null)
  const [assignSosId, setAssignSosId] = useState<string | null>(null)
  const [selectedEmployee, setSelectedEmployee] = useState('')
  const [searchQuery, setSearchQuery] = useState('')

  useEffect(() => {
    try {
      const stored = localStorage.getItem('fvv_user')
      if (stored) {
        const u = JSON.parse(stored)
        if (u.role !== 'admin') { router.push('/dashboard'); return }
        setUser(u)
      } else { router.push('/auth/login') }
    } catch (e) { console.error(e) }
  }, [router])

  const handleAccept = (id: string) => {
    setSosList((prev) => prev.map((s) => s.id === id ? { ...s, status: 'qabul_qilindi' } : s))
    setSelectedSos(sosList.find((s) => s.id === id) || null)
  }

  const handleReject = (id: string) => {
    setSosList((prev) => prev.map((s) => s.id === id ? { ...s, status: 'yopildi' } : s))
    setSelectedSos(null)
  }

  const handleAssign = () => {
    if (!assignSosId || !selectedEmployee) return
    setSosList((prev) => prev.map((s) => s.id === assignSosId ? { ...s, assignedTo: selectedEmployee } : s))
    setAssignSosId(null)
    setSelectedEmployee('')
  }

  const filteredSos = sosList.filter((s) =>
    !searchQuery || s.citizenName.toLowerCase().includes(searchQuery.toLowerCase()) || s.id.toLowerCase().includes(searchQuery.toLowerCase()) || s.problem.toLowerCase().includes(searchQuery.toLowerCase())
  )

  const newCount = sosList.filter((s) => s.status === 'yangi').length
  const activeCount = sosList.filter((s) => s.status === 'qabul_qilindi').length
  const resolvedCount = sosList.filter((s) => s.status === 'yopildi').length

  const newSosMarkers = sosList.filter((s) => s.status !== 'yopildi').map((s) => ({
    id: s.id,
    coordinates: s.coordinates,
    severity: s.status === 'yangi' ? 'CRITICAL' as const : 'HIGH' as const,
    label: s.problem,
  }))

  const center = useMemo<[number, number]>(() => [41.053, 71.77], [])

  if (!user) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="flex flex-col items-center gap-3">
          <Shield className="h-8 w-8 text-[#0066FF] animate-pulse" />
          <p className="text-sm text-medid-muted">Yuklanmoqda...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="p-6">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-xl font-bold text-medid-text">Admin Panel</h1>
            <p className="text-sm text-medid-muted">SOS murojaatlar, xodimlar va tizim boshqaruvi</p>
          </div>
          <Badge variant="success">Tizim ishlayapti</Badge>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 mb-6">
          <div className="rounded-xl border border-medid-border bg-medid-card p-4">
            <div className="flex items-center gap-2 mb-1">
              <AlertTriangle className="h-4 w-4 text-[#DC2626]" />
              <span className="text-xs text-medid-muted">Yangi SOS</span>
            </div>
            <p className="text-2xl font-bold text-medid-text">{newCount}</p>
          </div>
          <div className="rounded-xl border border-medid-border bg-medid-card p-4">
            <div className="flex items-center gap-2 mb-1">
              <Activity className="h-4 w-4 text-[#F59E0B]" />
              <span className="text-xs text-medid-muted">Jarayonda</span>
            </div>
            <p className="text-2xl font-bold text-medid-text">{activeCount}</p>
          </div>
          <div className="rounded-xl border border-medid-border bg-medid-card p-4">
            <div className="flex items-center gap-2 mb-1">
              <CheckCircle className="h-4 w-4 text-[#22C55E]" />
              <span className="text-xs text-medid-muted">Yopilgan</span>
            </div>
            <p className="text-2xl font-bold text-medid-text">{resolvedCount}</p>
          </div>
          <div className="rounded-xl border border-medid-border bg-medid-card p-4">
            <div className="flex items-center gap-2 mb-1">
              <Users className="h-4 w-4 text-[#3B82F6]" />
              <span className="text-xs text-medid-muted">Xodimlar</span>
            </div>
            <p className="text-2xl font-bold text-medid-text">{employees.length}</p>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Left: SOS List */}
          <div className="lg:col-span-2 space-y-4">
            {/* Search */}
            <div className="flex items-center justify-between">
              <h2 className="text-sm font-semibold text-medid-text">SOS Murojaatlar</h2>
              <div className="relative w-48">
                <Search className="absolute left-2 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-medid-muted" />
                <input value={searchQuery} onChange={(e) => setSearchQuery(e.target.value)} placeholder="Qidirish..." className="w-full pl-7 pr-2 py-1.5 text-xs rounded-lg border border-medid-border bg-medid-surface text-medid-text placeholder:text-medid-muted focus:outline-none focus:border-[#0066FF]" />
              </div>
            </div>

            {/* SOS List */}
            <div className="space-y-2 max-h-[500px] overflow-y-auto">
              {filteredSos.length === 0 ? (
                <div className="text-center py-12 text-medid-muted text-sm">Murojaatlar mavjud emas</div>
              ) : (
                filteredSos.map((sos, idx) => (
                  <motion.div
                    key={sos.id}
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: idx * 0.03 }}
                    className={`rounded-xl border p-4 cursor-pointer transition-all ${
                      selectedSos?.id === sos.id
                        ? 'border-[#0066FF] bg-[#0066FF]/5 shadow-sm'
                        : 'border-medid-border bg-medid-card hover:border-medid-muted/30'
                    }`}
                    onClick={() => setSelectedSos(sos)}
                  >
                    <div className="flex items-start justify-between">
                      <div className="flex items-start gap-3 min-w-0 flex-1">
                        <div className={`w-9 h-9 rounded-lg flex items-center justify-center shrink-0 ${
                          sos.status === 'yangi' ? 'bg-[#DC2626]/10' :
                          sos.status === 'qabul_qilindi' ? 'bg-[#F59E0B]/10' : 'bg-[#22C55E]/10'
                        }`}>
                          {sos.status === 'yangi' ? (
                            <span className="flex h-3 w-3 rounded-full bg-[#DC2626] animate-pulse-dot" />
                          ) : sos.status === 'qabul_qilindi' ? (
                            <Activity className="h-4 w-4 text-[#F59E0B]" />
                          ) : (
                            <CheckCircle className="h-4 w-4 text-[#22C55E]" />
                          )}
                        </div>
                        <div className="min-w-0 flex-1">
                          <div className="flex items-center gap-2 flex-wrap">
                            <span className="text-sm font-semibold text-medid-text">{sos.citizenName}</span>
                            <span className="text-[10px] px-1.5 py-0.5 rounded-full text-white" style={{ backgroundColor: problemColors[sos.problem] || '#64748B' }}>
                              {sos.problem}
                            </span>
                            <Badge variant={sos.status === 'yangi' ? 'danger' : sos.status === 'qabul_qilindi' ? 'warning' : 'success'} size="sm">
                              {sos.status === 'yangi' ? 'Yangi' : sos.status === 'qabul_qilindi' ? 'Jarayonda' : 'Yopilgan'}
                            </Badge>
                          </div>
                          <p className="text-xs text-medid-muted mt-0.5">{sos.location}</p>
                          <p className="text-xs text-medid-muted">{sos.phone} • {sos.time}</p>
                          {sos.assignedTo && <p className="text-xs text-[#0066FF] mt-0.5">Biriktirilgan: {sos.assignedTo}</p>}
                        </div>
                      </div>
                      <div className="flex items-center gap-1 shrink-0">
                        {sos.status === 'yangi' && (
                          <>
                            <button onClick={(e) => { e.stopPropagation(); handleAccept(sos.id) }} className="p-1.5 rounded-lg bg-[#22C55E]/10 text-[#22C55E] hover:bg-[#22C55E]/20">
                              <CheckCircle className="h-4 w-4" />
                            </button>
                            <button onClick={(e) => { e.stopPropagation(); handleReject(sos.id) }} className="p-1.5 rounded-lg bg-[#DC2626]/10 text-[#DC2626] hover:bg-[#DC2626]/20">
                              <X className="h-4 w-4" />
                            </button>
                          </>
                        )}
                        {sos.status === 'qabul_qilindi' && (
                          assignSosId === sos.id ? (
                            <div className="flex items-center gap-1" onClick={(e) => e.stopPropagation()}>
                              <select value={selectedEmployee} onChange={(e) => setSelectedEmployee(e.target.value)} className="text-[10px] px-1.5 py-1 rounded border border-medid-border bg-medid-surface text-medid-text">
                                <option value="">Tanlang</option>
                                {employees.filter((e) => e.status === 'online').map((e) => <option key={e.id} value={e.name}>{e.name}</option>)}
                              </select>
                              <button onClick={handleAssign} disabled={!selectedEmployee} className="p-1 rounded bg-[#0066FF] text-white disabled:opacity-50">
                                <CheckCircle className="h-3.5 w-3.5" />
                              </button>
                              <button onClick={() => setAssignSosId(null)} className="p-1 rounded text-medid-muted hover:bg-medid-surface">
                                <X className="h-3.5 w-3.5" />
                              </button>
                            </div>
                          ) : (
                            <button onClick={(e) => { e.stopPropagation(); setAssignSosId(sos.id) }} className="p-1.5 rounded-lg bg-[#0066FF]/10 text-[#0066FF] hover:bg-[#0066FF]/20">
                              <UserPlus className="h-4 w-4" />
                            </button>
                          )
                        )}
                      </div>
                    </div>
                  </motion.div>
                ))
              )}
            </div>
          </div>

          {/* Right: Mini Map + Detail */}
          <div className="space-y-4">
            {/* Mini Map */}
            <div className="rounded-xl overflow-hidden border border-medid-border bg-medid-card" style={{ height: 280 }}>
              <MiniMap center={center} zoom={13} markers={newSosMarkers} className="w-full h-full" />
            </div>

            {/* Selected SOS Detail */}
            <AnimatePresence>
              {selectedSos && (
                <motion.div
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: 10 }}
                  className="rounded-xl border border-medid-border bg-medid-card p-4"
                >
                  <div className="flex items-center justify-between mb-3">
                    <h3 className="text-sm font-semibold text-medid-text">{selectedSos.citizenName}</h3>
                    <Badge variant={selectedSos.status === 'yangi' ? 'danger' : selectedSos.status === 'qabul_qilindi' ? 'warning' : 'success'} size="sm">
                      {selectedSos.status === 'yangi' ? 'Yangi' : selectedSos.status === 'qabul_qilindi' ? 'Jarayonda' : 'Yopilgan'}
                    </Badge>
                  </div>
                  <div className="space-y-2 text-sm">
                    <div className="flex items-center gap-2 text-medid-muted">
                      <span className="text-[10px] px-1.5 py-0.5 rounded text-white" style={{ backgroundColor: problemColors[selectedSos.problem] || '#64748B' }}>{selectedSos.problem}</span>
                      <span className="text-xs">{selectedSos.id}</span>
                    </div>
                    <div className="flex items-center gap-2 text-xs text-medid-muted">
                      <MapPin className="h-3.5 w-3.5" /> {selectedSos.location}
                    </div>
                    <div className="flex items-center gap-2 text-xs text-medid-muted">
                      <Phone className="h-3.5 w-3.5" /> {selectedSos.phone}
                    </div>
                    <div className="flex items-center gap-2 text-xs text-medid-muted">
                      <Clock className="h-3.5 w-3.5" /> {selectedSos.time}
                    </div>
                    {selectedSos.assignedTo && (
                      <div className="flex items-center gap-2 text-xs text-[#0066FF]">
                        <UserPlus className="h-3.5 w-3.5" /> Biriktirilgan: {selectedSos.assignedTo}
                      </div>
                    )}
                  </div>
                  {selectedSos.status === 'yangi' && (
                    <div className="flex items-center gap-2 mt-3">
                      <Button size="xs" variant="primary" onClick={() => handleAccept(selectedSos.id)}>
                        <CheckCircle className="h-3.5 w-3.5" /> Qabul qilish
                      </Button>
                      <Button size="xs" variant="outline" onClick={() => handleReject(selectedSos.id)}>
                        <X className="h-3.5 w-3.5" /> Rad etish
                      </Button>
                    </div>
                  )}
                </motion.div>
              )}
            </AnimatePresence>

            {/* Quick Actions */}
            <div className="rounded-xl border border-medid-border bg-medid-card p-4">
              <h3 className="text-sm font-semibold text-medid-text mb-3">Tezkor o'tish</h3>
              <div className="space-y-2">
                <Button variant="outline" className="w-full justify-between" onClick={() => router.push('/employees')}>
                  <span className="flex items-center gap-2"><Users className="h-4 w-4" /> Xodimlar</span>
                  <ChevronRight className="h-4 w-4" />
                </Button>
                <Button variant="outline" className="w-full justify-between" onClick={() => router.push('/map')}>
                  <span className="flex items-center gap-2"><MapPin className="h-4 w-4" /> Xarita</span>
                  <ChevronRight className="h-4 w-4" />
                </Button>
                <Button variant="outline" className="w-full justify-between" onClick={() => router.push('/dashboard')}>
                  <span className="flex items-center gap-2"><Activity className="h-4 w-4" /> Dashboard</span>
                  <ChevronRight className="h-4 w-4" />
                </Button>
              </div>
            </div>
          </div>
        </div>

        {/* System Modules */}
        <div className="mt-8">
          <h2 className="text-sm font-semibold text-medid-text mb-3">Tizim modullari</h2>
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-3">
            {[
              { name: 'Web Dispatcher', status: 'online', version: '2.1.0' },
              { name: 'MCHS Mobile', status: 'online', version: '1.5.2' },
              { name: 'SMS/Telegram', status: 'online', version: '1.2.0' },
              { name: 'AI Monitoring', status: 'degraded', version: '1.8.3' },
              { name: 'IoT Gateway', status: 'online', version: '2.0.1' },
            ].map((m) => (
              <div key={m.name} className="rounded-xl border border-medid-border bg-medid-card p-3 flex items-center gap-3">
                <div className={`w-2 h-2 rounded-full shrink-0 ${m.status === 'online' ? 'bg-[#22C55E]' : 'bg-[#F59E0B]'}`} />
                <div className="min-w-0">
                  <p className="text-xs font-medium text-medid-text truncate">{m.name}</p>
                  <p className="text-[10px] text-medid-muted">v{m.version}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}
