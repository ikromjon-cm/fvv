'use client'

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { AlertTriangle, MapPin, Phone, Clock, CheckCircle, Send, User } from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { PageHeader } from '@/components/layout/page-header'

const sosRequests = [
  { id: 'SOS-001', name: 'Karimov A.', phone: '+998 90 123 45 67', location: 'Navbahor mahallasi', time: '2 min oldin', status: 'new', desc: 'Yong\'in xavfi aniqlangan' },
  { id: 'SOS-002', name: 'Raximova D.', phone: '+998 91 234 56 78', location: 'Guliston mahallasi', time: '15 min oldin', status: 'processing', desc: 'Gaz sizib chiqayapti' },
  { id: 'SOS-003', name: 'Usmonov B.', phone: '+998 93 345 67 89', location: 'Oqoltin mahallasi', time: '1 soat oldin', status: 'resolved', desc: 'Elektr uzilishi' },
  { id: 'SOS-004', name: 'Xolmatova M.', phone: '+998 94 456 78 90', location: 'Istiqlol mahallasi', time: '3 min oldin', status: 'new', desc: 'Binoning xavfli holati' },
]

const stats = [
  { label: 'Bugungi SOS', value: '8', color: '#DC2626' },
  { label: 'Yangi', value: '3', color: '#F59E0B' },
  { label: 'Jarayonda', value: '4', color: '#3B82F6' },
  { label: 'Hal qilingan', value: '1', color: '#22C55E' },
]

export default function SosPage() {
  const [requests, setRequests] = useState(sosRequests)

  const handleResolve = (id: string) => {
    setRequests((prev) => prev.map((r) => r.id === id ? { ...r, status: 'resolved' as const } : r))
  }

  const handleTake = (id: string) => {
    setRequests((prev) => prev.map((r) => r.id === id ? { ...r, status: 'processing' as const } : r))
  }

  return (
    <div className="min-h-screen bg-medid-surface flex flex-col">
      <PageHeader
        title="Fuqaro SOS"
        subtitle="Kraudsorsing orqali favqulodda murojaatlar"
        icon={<div className="flex items-center justify-center w-9 h-9 rounded-xl bg-[#DC2626]/10"><AlertTriangle className="h-5 w-5 text-[#DC2626]" /></div>}
        backTo="/dashboard"
      />
      <div className="flex-1 p-4 sm:p-6">
        <div className="max-w-6xl mx-auto">
          <div className="grid grid-cols-4 gap-3 mb-8">
          {stats.map((s) => (
            <div key={s.label} className="rounded-xl border border-medid-border bg-medid-card p-4">
              <p className="text-2xl font-bold" style={{ color: s.color }}>{s.value}</p>
              <p className="text-xs text-medid-muted mt-1">{s.label}</p>
            </div>
          ))}
        </div>

        {/* SOS List */}
        <div className="space-y-2">
          <AnimatePresence>
            {requests.map((sos, i) => (
              <motion.div
                key={sos.id}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: 20 }}
                transition={{ delay: i * 0.05 }}
                className={`rounded-xl border p-4 ${
                  sos.status === 'new'
                    ? 'border-[#DC2626]/30 bg-[#DC2626]/5'
                    : sos.status === 'processing'
                    ? 'border-[#F59E0B]/30 bg-[#F59E0B]/5'
                    : 'border-[#22C55E]/30 bg-[#22C55E]/5'
                }`}
              >
                <div className="flex items-start justify-between">
                  <div className="flex items-start gap-3">
                    <div className={`flex items-center justify-center w-10 h-10 rounded-full ${
                      sos.status === 'new' ? 'bg-[#DC2626]/10 text-[#DC2626] animate-pulse-emergency' :
                      sos.status === 'processing' ? 'bg-[#F59E0B]/10 text-[#F59E0B]' : 'bg-[#22C55E]/10 text-[#22C55E]'
                    }`}>
                      <User className="h-5 w-5" />
                    </div>
                    <div>
                      <div className="flex items-center gap-2">
                        <h3 className="text-sm font-semibold text-medid-text">{sos.name}</h3>
                        <Badge
                          variant={sos.status === 'new' ? 'danger' : sos.status === 'processing' ? 'warning' : 'success'}
                          size="sm"
                        >
                          {sos.status === 'new' ? 'Yangi' : sos.status === 'processing' ? 'Jarayonda' : 'Hal qilingan'}
                        </Badge>
                        <span className="text-[10px] font-mono text-medid-muted">{sos.id}</span>
                      </div>
                      <p className="text-sm text-medid-muted mt-1">{sos.desc}</p>
                      <div className="flex items-center gap-4 mt-2 text-xs text-medid-muted">
                        <span className="flex items-center gap-1"><MapPin className="h-3 w-3" /> {sos.location}</span>
                        <span className="flex items-center gap-1"><Phone className="h-3 w-3" /> {sos.phone}</span>
                        <span className="flex items-center gap-1"><Clock className="h-3 w-3" /> {sos.time}</span>
                      </div>
                    </div>
                  </div>
                  <div className="flex items-center gap-1">
                    {sos.status === 'new' && (
                      <Button variant="primary" size="xs" onClick={() => handleTake(sos.id)}>
                        <Send className="h-3 w-3" /> Qabul qilish
                      </Button>
                    )}
                    {sos.status === 'processing' && (
                      <Button variant="success" size="xs" onClick={() => handleResolve(sos.id)}>
                        <CheckCircle className="h-3 w-3" /> Yopish
                      </Button>
                    )}
                  </div>
                </div>
              </motion.div>
            ))}
          </AnimatePresence>
          </div>
        </div>
      </div>
    </div>
  )
}
