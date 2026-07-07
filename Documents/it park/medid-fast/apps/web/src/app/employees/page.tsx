'use client'

import { useState, useMemo } from 'react'
import { motion } from 'framer-motion'
import { MapPin, Phone, Mail, Shield, Circle, User, RefreshCw } from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import dynamic from 'next/dynamic'

const LeafletMap = dynamic(() => import('@/components/shared/leaflet-map').then((m) => m.LeafletMap), { ssr: false })

const employees = [
  { id: 'EMP-001', name: 'Botir Toshmatov', role: 'MCHS Xodimi', phone: '+998 90 111 22 33', email: 'botir@fvv.uz', status: 'online', coordinates: [41.053, 71.768] as [number, number], lastActive: 'Hozir', tasks: 3 },
  { id: 'EMP-002', name: 'Shavkat Rahimov', role: 'Tez Yordam', phone: '+998 91 222 33 44', email: 'shavkat@fvv.uz', status: 'online', coordinates: [41.06, 71.775] as [number, number], lastActive: '5 min', tasks: 1 },
  { id: 'EMP-003', name: 'Gulnora Saidova', role: 'Dispecher', phone: '+998 93 333 44 55', email: 'gulnora@fvv.uz', status: 'busy', coordinates: [41.045, 71.76] as [number, number], lastActive: '2 min', tasks: 5 },
  { id: 'EMP-004', name: 'Aziz Karimov', role: 'MCHS Xodimi', phone: '+998 94 444 55 66', email: 'aziz@fvv.uz', status: 'offline', coordinates: [41.07, 71.785] as [number, number], lastActive: '1 soat', tasks: 0 },
]

const employeeMarkers = employees.map((emp) => ({
  id: emp.id,
  coordinates: emp.coordinates,
  severity: emp.status === 'online' ? 'LOW' as const : emp.status === 'busy' ? 'HIGH' as const : 'MEDIUM' as const,
  label: emp.name,
}))

export default function EmployeesPage() {
  const [selected, setSelected] = useState<typeof employees[0] | null>(null)
  const [filter, setFilter] = useState<string>('all')

  const center = useMemo<[number, number]>(() => [41.053, 71.77], [])

  const filtered = filter === 'all' ? employees : employees.filter((e) => e.status === filter)

  return (
    <div className="p-6">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-xl font-bold text-medid-text">Xodimlar</h1>
            <p className="text-sm text-medid-muted">Xodimlarning joylashuvi va holati</p>
          </div>
          <div className="flex items-center gap-2">
            {['all', 'online', 'busy', 'offline'].map((f) => (
              <button
                key={f}
                onClick={() => setFilter(f)}
                className={`px-3 py-1.5 rounded-lg text-xs font-medium transition-colors ${
                  filter === f ? 'bg-[#0066FF] text-white' : 'bg-medid-card border border-medid-border text-medid-muted hover:bg-medid-surface'
                }`}
              >
                {f === 'all' ? 'Barcha' : f === 'online' ? 'Onlayn' : f === 'busy' ? 'Band' : 'Offlayn'}
              </button>
            ))}
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Employee cards */}
          <div className="lg:col-span-1 space-y-3">
            {filtered.map((emp, idx) => (
              <motion.button
                key={emp.id}
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: idx * 0.05 }}
                onClick={() => setSelected(emp)}
                className={`w-full text-left rounded-xl border p-4 transition-all ${
                  selected?.id === emp.id
                    ? 'border-[#0066FF] bg-[#0066FF]/5 shadow-sm'
                    : 'border-medid-border bg-medid-card hover:border-medid-muted/30'
                }`}
              >
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-lg bg-[#3B82F6]/10 flex items-center justify-center">
                    <User className="h-5 w-5 text-[#3B82F6]" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <p className="text-sm font-semibold text-medid-text">{emp.name}</p>
                      <span className={`flex h-2 w-2 rounded-full shrink-0 ${
                        emp.status === 'online' ? 'bg-[#22C55E] animate-pulse-dot' :
                        emp.status === 'busy' ? 'bg-[#F59E0B]' : 'bg-medid-muted'
                      }`} />
                    </div>
                    <p className="text-xs text-medid-muted">{emp.role}</p>
                  </div>
                  <Badge variant={emp.status === 'online' ? 'info' : emp.status === 'busy' ? 'warning' : 'default'} size="sm">
                    {emp.status === 'online' ? 'Onlayn' : emp.status === 'busy' ? 'Band' : 'Offlayn'}
                  </Badge>
                </div>
                <div className="mt-3 flex items-center gap-3 text-[11px] text-medid-muted">
                  <span className="flex items-center gap-1"><Shield className="h-3 w-3" />{emp.tasks} topshiriq</span>
                  <span>{emp.lastActive}</span>
                </div>
              </motion.button>
            ))}
          </div>

          {/* Map + detail */}
          <div className="lg:col-span-2 space-y-4">
            <div className="rounded-xl overflow-hidden border border-medid-border bg-medid-card" style={{ height: 400 }}>
              <LeafletMap center={center} zoom={13} markers={employeeMarkers} className="w-full h-full" />
            </div>

            {selected && (
              <motion.div
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                className="rounded-xl border border-medid-border bg-medid-card p-4"
              >
                <div className="flex items-start justify-between mb-3">
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 rounded-xl bg-[#3B82F6]/10 flex items-center justify-center">
                      <User className="h-6 w-6 text-[#3B82F6]" />
                    </div>
                    <div>
                      <h3 className="text-base font-semibold text-medid-text">{selected.name}</h3>
                      <p className="text-sm text-medid-muted">{selected.role} • {selected.id}</p>
                    </div>
                  </div>
                  <Badge variant={selected.status === 'online' ? 'info' : selected.status === 'busy' ? 'warning' : 'default'}>
                    {selected.status === 'online' ? 'Faol' : selected.status === 'busy' ? 'Band' : 'Offlayn'}
                  </Badge>
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div className="flex items-center gap-2 text-sm text-medid-muted">
                    <Phone className="h-4 w-4 text-[#22C55E]" /> {selected.phone}
                  </div>
                  <div className="flex items-center gap-2 text-sm text-medid-muted">
                    <Mail className="h-4 w-4 text-[#3B82F6]" /> {selected.email}
                  </div>
                  <div className="flex items-center gap-2 text-sm text-medid-muted">
                    <MapPin className="h-4 w-4 text-[#DC2626]" /> {selected.coordinates.join(', ')}
                  </div>
                  <div className="flex items-center gap-2 text-sm text-medid-muted">
                    <RefreshCw className="h-4 w-4" /> {selected.lastActive}
                  </div>
                </div>
              </motion.div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
