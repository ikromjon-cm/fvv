'use client'

import { useEffect, useMemo } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { MapPin, Circle, X, Camera, Shield } from 'lucide-react'
import { useFvvStore } from '@/store/fvvStore'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import dynamic from 'next/dynamic'
import Link from 'next/link'

const LeafletMap = dynamic(() => import('@/components/shared/leaflet-map').then((m) => m.LeafletMap), { ssr: false })

const severityConfig: Record<string, { label: string; color: string }> = {
  CRITICAL: { label: 'Kritik', color: '#DC2626' },
  HIGH: { label: 'Yuqori', color: '#F59E0B' },
  MEDIUM: { label: "O'rtacha", color: '#3B82F6' },
  LOW: { label: 'Past', color: '#22C55E' },
}

const statusLabels: Record<string, string> = {
  UNDER_INVESTIGATION: 'Tekshirilmoqda',
  IN_PROGRESS: 'Jarayonda',
  RESOLVED: 'Hal qilingan',
}

export default function MapPage() {
  const { incidents, fetchIncidents, selectedIncident, setSelectedIncident } = useFvvStore()
  const center = useMemo<[number, number]>(() => [41.053, 71.77], [])

  useEffect(() => {
    fetchIncidents()
  }, [fetchIncidents])

  const markers = useMemo(() => incidents.map((inc) => ({
    id: inc.id,
    coordinates: inc.coordinates,
    severity: inc.severity,
    label: `${inc.id} — ${inc.neighborhood.slice(0, 15)}...`,
    onClick: () => setSelectedIncident(inc),
  })), [incidents, setSelectedIncident])

  return (
    <div className="min-h-screen overflow-hidden bg-medid-navy flex flex-col">
      {/* Header */}
      <div className="shrink-0 bg-medid-navy/80 border-b border-white/10 px-6 py-2 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <MapPin className="h-5 w-5 text-[#0066FF]" />
          <h1 className="text-sm font-bold text-white">Xarita — Uychi tumani</h1>
        </div>
        <div className="flex items-center gap-2">
          <Button variant="outline" size="xs" className="text-white border-white/20">
            <Circle className="h-3 w-3" /> Radius
          </Button>
        </div>
      </div>

      {/* Map area */}
      <div className="flex-1 relative">
        <LeafletMap center={center} zoom={14} markers={markers} className="w-full h-full" />

        {/* Legend */}
        <div className="absolute bottom-4 left-4 bg-black/60 rounded-lg p-3 text-white/80 text-[11px] space-y-1.5 z-[1000]">
          <p className="text-xs font-semibold text-white mb-1">Legenda</p>
          {[
            { color: '#DC2626', label: 'Kritik' },
            { color: '#F59E0B', label: 'Yuqori' },
            { color: '#3B82F6', label: "O'rtacha" },
            { color: '#22C55E', label: 'Past' },
          ].map((l) => (
            <div key={l.label} className="flex items-center gap-2">
              <span className="w-3 h-3 rounded-full" style={{ backgroundColor: l.color }} /> {l.label}
            </div>
          ))}
        </div>

        {/* Count badge */}
        <div className="absolute top-3 right-3 bg-black/60 rounded-lg px-3 py-1.5 text-white/80 text-xs z-[1000]">
          {incidents.length} ta hodisa
        </div>

        {/* Selected Incident Detail Panel */}
        <AnimatePresence>
          {selectedIncident && (
            <motion.div
              initial={{ opacity: 0, y: 80 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: 80 }}
              className="absolute bottom-3 left-3 right-3 z-[1001]"
            >
              <div className="max-w-xl mx-auto bg-medid-card/95 backdrop-blur rounded-xl border border-medid-border shadow-xl p-3">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 shrink-0 rounded-lg overflow-hidden bg-gray-100">
                    <img
                      src={selectedIncident.initial_report_photo}
                      alt=""
                      className="w-full h-full object-cover"
                      onError={(e) => { (e.target as HTMLImageElement).style.display = 'none' }}
                    />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-1.5 flex-wrap">
                      <span className="text-xs font-semibold text-medid-text">{selectedIncident.id}</span>
                      <Badge variant={selectedIncident.severity === 'CRITICAL' ? 'danger' : selectedIncident.severity === 'HIGH' ? 'warning' : 'info'} size="sm">
                        {severityConfig[selectedIncident.severity]?.label || selectedIncident.severity}
                      </Badge>
                    </div>
                    <p className="text-[11px] text-medid-muted truncate">{selectedIncident.category} • {selectedIncident.neighborhood}</p>
                  </div>
                  <div className="flex items-center gap-1.5 shrink-0">
                    <Link href={`/incidents/${selectedIncident.id}`}>
                      <Button size="xs" variant="outline" className="h-7 text-[11px] px-2">Batafsil</Button>
                    </Link>
                    <button onClick={() => setSelectedIncident(null)} className="p-1 rounded-lg hover:bg-medid-surface text-medid-muted">
                      <X className="h-3.5 w-3.5" />
                    </button>
                  </div>
                </div>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  )
}
