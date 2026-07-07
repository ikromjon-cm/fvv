'use client'

import { useEffect, useState } from 'react'
import { useParams, useRouter } from 'next/navigation'
import { motion } from 'framer-motion'
import { ArrowLeft, MapPin, Clock, User, Calendar, Camera, Shield, AlertTriangle, type LucideProps } from 'lucide-react'
import { useFvvStore } from '@/store/fvvStore'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import type { FvvIncident } from '@/mock/data'

const severityConfig: Record<string, { label: string; color: string }> = {
  CRITICAL: { label: 'Kritik', color: 'bg-[#DC2626]' },
  HIGH: { label: 'Yuqori', color: 'bg-[#F59E0B]' },
  MEDIUM: { label: "O'rtacha", color: 'bg-[#3B82F6]' },
  LOW: { label: 'Past', color: 'bg-[#22C55E]' },
}

const statusLabels: Record<string, string> = {
  UNDER_INVESTIGATION: 'Tekshirilmoqda',
  IN_PROGRESS: 'Jarayonda',
  RESOLVED: 'Hal qilingan',
}

const validationLabels: Record<string, { label: string; color: string }> = {
  PENDING_APPROVAL: { label: 'Tasdiqlanmagan', color: 'text-[#F59E0B] bg-[#F59E0B]/10' },
  APPROVED: { label: 'Tasdiqlangan', color: 'text-[#22C55E] bg-[#22C55E]/10' },
  REJECTED: { label: 'Rad etilgan', color: 'text-[#DC2626] bg-[#DC2626]/10' },
}

export function IncidentDetailClient() {
  const params = useParams()
  const router = useRouter()
  const { incidents, fetchIncidents } = useFvvStore()
  const [incident, setIncident] = useState<FvvIncident | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchIncidents().catch(console.error)
  }, [fetchIncidents])

  useEffect(() => {
    if (incidents.length > 0) {
      const found = incidents.find((i) => i.id === params.id)
      setIncident(found || null)
    }
    setLoading(false)
  }, [incidents, params.id])

  if (loading) {
    return (
      <div className="h-screen bg-medid-surface p-8">
        <div className="animate-pulse space-y-4 max-w-4xl">
          <div className="h-6 w-32 bg-gray-200 rounded" />
          <div className="h-8 w-64 bg-gray-200 rounded" />
          <div className="grid grid-cols-2 gap-4">
            <div className="h-48 bg-gray-200 rounded-xl" />
            <div className="h-48 bg-gray-200 rounded-xl" />
          </div>
        </div>
      </div>
    )
  }

  if (!incident) {
    return (
      <div className="h-screen bg-medid-surface flex items-center justify-center">
        <div className="text-center">
          <AlertTriangle className="h-12 w-12 text-[#F59E0B] mx-auto mb-3" />
          <h2 className="text-lg font-semibold text-medid-text mb-1">Hodisa topilmadi</h2>
          <p className="text-sm text-medid-muted mb-4">ID: {params.id}</p>
          <Button variant="outline" onClick={() => router.push('/dashboard')}>
            <ArrowLeft className="h-4 w-4" /> Dashboardga qaytish
          </Button>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-medid-surface">
      <div className="max-w-5xl mx-auto p-6">
        <div className="flex items-center gap-3 mb-6">
          <button onClick={() => router.back()} className="p-2 rounded-lg hover:bg-gray-100">
            <ArrowLeft className="h-5 w-5 text-medid-muted" />
          </button>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-xl font-bold text-medid-text">{incident.id}</h1>
              <Badge variant={incident.severity === 'CRITICAL' ? 'danger' : incident.severity === 'HIGH' ? 'warning' : 'info'}>
                {severityConfig[incident.severity]?.label || incident.severity}
              </Badge>
              <span className={`text-xs px-2 py-0.5 rounded-full ${validationLabels[incident.validation_status]?.color || ''}`}>
                {validationLabels[incident.validation_status]?.label || incident.validation_status}
              </span>
            </div>
            <p className="text-sm text-medid-muted">{incident.category}</p>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}>
            <div className="rounded-xl border border-medid-border bg-medid-card overflow-hidden">
              <div className="p-3 border-b border-medid-border flex items-center gap-2">
                <Camera className="h-4 w-4 text-[#DC2626]" />
                <span className="text-sm font-medium text-medid-text">Foto-1: Muammo aniqlangandagi holat</span>
              </div>
              <img
                src={incident.initial_report_photo}
                alt=""
                className="w-full h-64 object-cover"
                onError={(e) => { (e.target as HTMLImageElement).style.display = 'none' }}
              />
            </div>
          </motion.div>

          <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}>
            <div className="rounded-xl border border-medid-border bg-medid-card overflow-hidden">
              <div className="p-3 border-b border-medid-border flex items-center gap-2">
                <Camera className="h-4 w-4 text-[#22C55E]" />
                <span className="text-sm font-medium text-medid-text">Foto-2: Hal qilingandan keyingi holat</span>
              </div>
              {incident.resolved_photo ? (
                <img
                  src={incident.resolved_photo}
                  alt=""
                  className="w-full h-64 object-cover"
                  onError={(e) => { (e.target as HTMLImageElement).style.display = 'none' }}
                />
              ) : (
                <div className="w-full h-64 flex items-center justify-center bg-gray-50">
                  <div className="text-center">
                    <Camera className="h-10 w-10 text-medid-muted mx-auto mb-2" />
                    <p className="text-sm text-medid-muted">Xodim tasviri kutilmoqda</p>
                    <p className="text-xs text-medid-muted mt-1">Muddat: {incident.resolution_deadline}</p>
                  </div>
                </div>
              )}
            </div>
          </motion.div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-6">
          <InfoCard icon={MapPin} label="Manzil" value={`${incident.neighborhood}, ${incident.household_address}`} />
          <InfoCard icon={User} label="Xodim" value={incident.reporter} />
          <InfoCard icon={Clock} label="Status" value={statusLabels[incident.status] || incident.status} />
          <InfoCard icon={Calendar} label="Tekshiruv vaqti" value={incident.inspection_timestamp} />
          <InfoCard icon={AlertTriangle} label="Muddat" value={incident.resolution_deadline} />
          <InfoCard icon={Shield} label="Validatsiya" value={validationLabels[incident.validation_status]?.label || incident.validation_status} />
        </div>

        {incident.notes && (
          <div className="mt-6 p-4 rounded-xl border border-medid-border bg-medid-card">
            <h3 className="text-sm font-semibold text-medid-text mb-2">Qo'shimcha ma'lumot</h3>
            <p className="text-sm text-medid-muted">{incident.notes}</p>
          </div>
        )}

        <div className="mt-6 flex items-center gap-3">
          <Button variant="outline" onClick={() => router.push('/dashboard')}>
            Dashboardga qaytish
          </Button>
          {incident.status !== 'RESOLVED' && (
            <Button variant="primary" onClick={() => router.push('/mchs')}>
              MCHS Inspeksiyaga o'tish
            </Button>
          )}
        </div>
      </div>
    </div>
  )
}

function InfoCard({ icon: Icon, label, value }: { icon: React.ComponentType<LucideProps>; label: string; value: string }) {
  return (
    <div className="rounded-xl border border-medid-border bg-medid-card p-4">
      <div className="flex items-center gap-2 mb-1">
        <Icon className="h-4 w-4 text-medid-muted" />
        <span className="text-xs text-medid-muted">{label}</span>
      </div>
      <p className="text-sm font-medium text-medid-text">{value}</p>
    </div>
  )
}
