'use client'

import { useEffect, useMemo, useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { MapPin, X, ArrowUpRight, Layers, ArrowRight } from 'lucide-react'
import { useFvvStore } from '@/store/fvvStore'
import { Badge } from '@/components/ui/badge'
import dynamic from 'next/dynamic'
import Link from 'next/link'

const LeafletMap = dynamic(() => import('@/components/shared/leaflet-map').then((m) => m.LeafletMap), { ssr: false })

const EASE: [number, number, number, number] = [0.32, 0.72, 0, 1]

const severityMeta: Record<string, { label: string; color: string; variant: 'danger' | 'warning' | 'info' | 'success' }> = {
  CRITICAL: { label: 'Kritik', color: '#E11D48', variant: 'danger' },
  HIGH: { label: 'Yuqori', color: '#F59E0B', variant: 'warning' },
  MEDIUM: { label: "O'rtacha", color: '#2563EB', variant: 'info' },
  LOW: { label: 'Past', color: '#10B981', variant: 'success' },
}

const filters = [
  { key: 'all', label: 'Barchasi' },
  { key: 'CRITICAL', label: 'Kritik' },
  { key: 'HIGH', label: 'Yuqori' },
  { key: 'MEDIUM', label: "O'rtacha" },
  { key: 'LOW', label: 'Past' },
] as const

export default function MapPage() {
  const { incidents, fetchIncidents, selectedIncident, setSelectedIncident } = useFvvStore()
  const center = useMemo<[number, number]>(() => [41.053, 71.77], [])
  const [sev, setSev] = useState<(typeof filters)[number]['key']>('all')

  useEffect(() => { fetchIncidents() }, [fetchIncidents])

  const visible = sev === 'all' ? incidents : incidents.filter((i) => i.severity === sev)

  const markers = useMemo(() => visible.map((inc) => ({
    id: inc.id,
    coordinates: inc.coordinates,
    severity: inc.severity,
    label: inc.id,
    onClick: () => setSelectedIncident(inc),
  })), [visible, setSelectedIncident])

  return (
    <div className="h-full flex flex-col overflow-hidden bg-medid-surface">
      {/* Map area */}
      <div className="relative flex-[5] min-h-0">
        <div className="absolute inset-0">
          <LeafletMap center={center} zoom={14} markers={markers} className="w-full h-full" />
        </div>

        {/* Floating top bar */}
        <div className="pointer-events-none absolute inset-x-0 top-0 z-[1000] p-2 sm:p-3">
          <div className="mx-auto flex max-w-6xl flex-wrap items-center gap-2 sm:gap-3">
            <div className="pointer-events-auto flex items-center gap-2 rounded-full bg-medid-card/85 px-3 py-1.5 sm:px-4 sm:py-2 ring-1 ring-medid-hairline shadow-float backdrop-blur-xl">
              <div className="flex h-6 w-6 sm:h-7 sm:w-7 items-center justify-center rounded-lg bg-gradient-to-br from-medid-primary to-medid-primary-dark">
                <MapPin className="h-3.5 w-3.5 sm:h-4 sm:w-4 text-white" strokeWidth={2.25} />
              </div>
              <div className="leading-tight">
                <p className="font-display text-xs sm:text-sm font-bold text-medid-text">Xarita — Uychi tumani</p>
                <p className="text-[10px] sm:text-[11px] text-medid-muted">{visible.length} ta hodisa</p>
              </div>
            </div>

            {/* Severity filter */}
            <div className="pointer-events-auto flex items-center gap-1 rounded-full bg-medid-card/85 p-1 ring-1 ring-medid-hairline shadow-float backdrop-blur-xl">
              {filters.map((f) => {
                const active = sev === f.key
                return (
                  <button
                    key={f.key}
                    onClick={() => setSev(f.key)}
                    className={`rounded-full px-2.5 py-1 sm:px-3 sm:py-1.5 text-[10px] sm:text-xs font-medium transition-[background-color,color] duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] ${
                      active ? 'bg-medid-primary text-white' : 'text-medid-muted hover:text-medid-text hover:bg-medid-surface-2'
                    }`}
                  >
                    {f.label}
                  </button>
                )
              })}
            </div>
          </div>
        </div>

        {/* Legend */}
        <div className="pointer-events-none absolute bottom-3 left-3 z-[1000] hidden sm:block">
          <div className="rounded-2xl bg-medid-card/85 p-3 ring-1 ring-medid-hairline shadow-float backdrop-blur-xl">
            <div className="flex items-center gap-1.5 mb-2">
              <Layers className="h-3.5 w-3.5 text-medid-muted" strokeWidth={1.75} />
              <p className="text-[11px] font-semibold text-medid-text">Xavf darajasi</p>
            </div>
            <div className="space-y-1.5">
              {Object.values(severityMeta).map((l) => (
                <div key={l.label} className="flex items-center gap-2 text-[11px] text-medid-muted">
                  <span className="h-2.5 w-2.5 rounded-full ring-2 ring-white/70" style={{ backgroundColor: l.color }} /> {l.label}
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Selected incident panel */}
        <AnimatePresence>
          {selectedIncident && (
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: 30 }}
              transition={{ duration: 0.35, ease: EASE }}
              className="absolute bottom-3 left-3 right-3 z-[1001]"
            >
              <div className="mx-auto max-w-xl rounded-2xl bg-medid-card/90 p-2.5 sm:p-3 ring-1 ring-medid-hairline shadow-lift backdrop-blur-xl">
                <div className="flex items-center gap-2.5 sm:gap-3">
                  <div className="relative h-12 w-12 sm:h-14 sm:w-14 shrink-0 overflow-hidden rounded-xl bg-medid-surface-2 ring-1 ring-inset ring-medid-hairline">
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
                      <Badge variant={severityMeta[selectedIncident.severity]?.variant || 'info'} size="sm" dot pulse={selectedIncident.severity === 'CRITICAL'}>
                        {severityMeta[selectedIncident.severity]?.label || selectedIncident.severity}
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
                      className="group inline-flex items-center gap-1.5 rounded-full bg-medid-primary px-3 py-1.5 sm:px-3.5 sm:py-2 text-xs font-medium text-white shadow-soft transition-transform duration-300 ease-[cubic-bezier(0.32,0.72,0,1)] hover:-translate-y-0.5 active:scale-95"
                    >
                      Batafsil
                      <ArrowUpRight className="h-3.5 w-3.5 transition-transform duration-300 group-hover:translate-x-0.5 group-hover:-translate-y-0.5" strokeWidth={2} />
                    </Link>
                    <button onClick={() => setSelectedIncident(null)} className="flex h-7 w-7 sm:h-8 sm:w-8 items-center justify-center rounded-full text-medid-muted hover:bg-medid-surface-2 hover:text-medid-text transition-colors active:scale-95">
                      <X className="h-3.5 w-3.5 sm:h-4 sm:w-4" />
                    </button>
                  </div>
                </div>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      {/* Incident list below map */}
      <div className="flex-[3] min-h-0 border-t border-medid-border bg-medid-card overflow-hidden">
        <div className="h-full flex flex-col">
          <div className="shrink-0 flex items-center justify-between px-4 py-2.5 border-b border-medid-border">
            <div className="flex items-center gap-2">
              <MapPin className="h-4 w-4 text-medid-primary" strokeWidth={2} />
              <span className="text-sm font-semibold text-medid-text">Hodisalar ro'yxati</span>
            </div>
            <span className="text-xs text-medid-muted">{visible.length} ta</span>
          </div>
          <div className="flex-1 overflow-y-auto scrollbar-thin">
            <AnimatePresence mode="popLayout">
              {visible.map((inc, i) => (
                <motion.div
                  key={inc.id}
                  layout
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: -20 }}
                  transition={{ duration: 0.3, ease: EASE, delay: i * 0.03 }}
                >
                  <Link
                    href={`/incidents/${inc.id}`}
                    className="flex items-center gap-3 px-4 py-3 transition-colors hover:bg-medid-surface-2 active:bg-medid-surface-2 border-b border-medid-hairline last:border-b-0"
                  >
                    <div className="h-2.5 w-2.5 shrink-0 rounded-full" style={{ backgroundColor: severityMeta[inc.severity]?.color }} />
                    <div className="min-w-0 flex-1">
                      <div className="flex items-center gap-2">
                        <span className="font-mono text-[11px] font-bold text-medid-text">{inc.id}</span>
                        <span className="text-xs text-medid-muted">{inc.category}</span>
                      </div>
                      <p className="text-[11px] text-medid-muted truncate mt-0.5">
                        {inc.neighborhood} • {inc.household_address}
                      </p>
                    </div>
                    <span className="shrink-0 text-[10px] font-medium text-medid-muted">
                      {inc.status === 'UNDER_INVESTIGATION' ? 'Tekshirilmoqda' : inc.status === 'IN_PROGRESS' ? 'Jarayonda' : 'Hal qilingan'}
                    </span>
                    <ArrowRight className="h-3.5 w-3.5 text-medid-muted shrink-0" strokeWidth={2} />
                  </Link>
                </motion.div>
              ))}
            </AnimatePresence>
            {visible.length === 0 && (
              <div className="flex items-center justify-center h-full">
                <p className="text-sm text-medid-muted">Bu filtr bo'yicha hodisalar topilmadi</p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
