'use client'

import { useState } from 'react'
import { usePathname } from 'next/navigation'
import { motion, AnimatePresence } from 'framer-motion'
import { X, MapPin, AlertTriangle, Send, Smartphone } from 'lucide-react'

interface SosRequest {
  id: string
  citizenName: string
  phone: string
  problem: string
  location: string
  coordinates: [number, number]
  time: string
  status: 'yangi' | 'qabul_qilindi' | 'yopildi'
}

const problems = ['Yong\'in', 'MCHS', 'Tez yordam', 'Yo\'l hodisasi', 'Gaz sizishi', 'Suv toshqini', 'Boshqa']

const initialSos: SosRequest[] = [
  {
    id: 'SOS-001',
    citizenName: 'Akmal Karimov',
    phone: '+998 90 123 45 67',
    problem: 'Yong\'in',
    location: 'Uychi, Navbahor ko\'ch, 12',
    coordinates: [41.055, 71.765],
    time: '10:23',
    status: 'yangi',
  },
  {
    id: 'SOS-002',
    citizenName: 'Dilnoza Rahimova',
    phone: '+998 91 234 56 78',
    problem: 'Tez yordam',
    location: 'Uychi, Xamid Olimjon, 5',
    coordinates: [41.048, 71.775],
    time: '10:15',
    status: 'qabul_qilindi',
  },
]

export function AndroidEmulator() {
  const pathname = usePathname()
  const [open, setOpen] = useState(false)
  const [sosList] = useState<SosRequest[]>(initialSos)
  const [form, setForm] = useState({ name: '', phone: '', problem: '', location: '' })
  const [sent, setSent] = useState(false)

  if (pathname === '/auth/login') return null

  const handleSend = () => {
    if (!form.name || !form.problem) return
    setSent(true)
    setTimeout(() => {
      setSent(false)
      setForm({ name: '', phone: '', problem: '', location: '' })
    }, 2000)
  }

  const newCount = sosList.filter((s) => s.status === 'yangi').length

  return (
    <>
      {/* Toggle button */}
      <button
        onClick={() => setOpen(!open)}
        className="fixed bottom-4 right-4 z-50 flex items-center gap-2 px-4 py-2.5 rounded-full bg-[#DC2626] text-white shadow-lg hover:bg-[#B91C1C] transition-all"
      >
        <Smartphone className="h-4 w-4" />
        <span className="text-sm font-medium">Fuqaro SOS</span>
        {newCount > 0 && (
          <span className="flex items-center justify-center w-5 h-5 rounded-full bg-white text-[#DC2626] text-[10px] font-bold">
            {newCount}
          </span>
        )}
      </button>

      <AnimatePresence>
        {open && (
          <motion.div
            initial={{ opacity: 0, y: 20, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: 20, scale: 0.95 }}
            className="fixed bottom-20 right-4 z-50 w-[340px] rounded-2xl border border-medid-border bg-medid-card shadow-2xl overflow-hidden"
          >
            {/* Header */}
            <div className="bg-gradient-to-r from-[#DC2626] to-[#B91C1C] px-4 py-3 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Smartphone className="h-4 w-4 text-white" />
                <span className="text-sm font-semibold text-white">Fuqaro SOS</span>
              </div>
              <button onClick={() => setOpen(false)} className="p-1 rounded hover:bg-white/20 text-white">
                <X className="h-4 w-4" />
              </button>
            </div>

            <div className="max-h-[500px] overflow-y-auto">
              {/* SOS Requests */}
              <div className="p-3 border-b border-medid-border">
                <p className="text-xs font-semibold text-medid-text mb-2">Kelib tushgan murojaatlar</p>
                <div className="space-y-2">
                  {sosList.map((sos) => (
                    <div key={sos.id} className="rounded-lg border border-medid-border p-3 bg-medid-surface/50">
                      <div className="flex items-center justify-between mb-1">
                        <span className="text-xs font-semibold text-medid-text">{sos.citizenName}</span>
                        <span className={`text-[10px] px-1.5 py-0.5 rounded-full ${
                          sos.status === 'yangi' ? 'bg-[#DC2626]/10 text-[#DC2626]' :
                          sos.status === 'qabul_qilindi' ? 'bg-[#F59E0B]/10 text-[#F59E0B]' :
                          'bg-[#22C55E]/10 text-[#22C55E]'
                        }`}>
                          {sos.status === 'yangi' ? 'Yangi' : sos.status === 'qabul_qilindi' ? 'Jarayonda' : 'Yopilgan'}
                        </span>
                      </div>
                      <div className="flex items-center gap-1.5 text-[11px] text-medid-muted">
                        <AlertTriangle className="h-3 w-3 text-[#DC2626]" />
                        {sos.problem}
                      </div>
                      <div className="flex items-center gap-1.5 text-[11px] text-medid-muted">
                        <MapPin className="h-3 w-3" />
                        {sos.location}
                      </div>
                      <p className="text-[10px] text-medid-muted mt-1">{sos.time}</p>
                    </div>
                  ))}
                </div>
              </div>

              {/* Citizen Report Form */}
              <div className="p-3">
                <p className="text-xs font-semibold text-medid-text mb-2">Fuqaro sifatida xabar berish</p>
                <div className="space-y-2">
                  <input
                    value={form.name}
                    onChange={(e) => setForm({ ...form, name: e.target.value })}
                    placeholder="Ismingiz"
                    className="w-full rounded-lg border border-medid-border bg-medid-surface px-3 py-2 text-xs text-medid-text placeholder:text-medid-muted/50 outline-none focus:border-[#0066FF]"
                  />
                  <input
                    value={form.phone}
                    onChange={(e) => setForm({ ...form, phone: e.target.value })}
                    placeholder="Telefon"
                    className="w-full rounded-lg border border-medid-border bg-medid-surface px-3 py-2 text-xs text-medid-text placeholder:text-medid-muted/50 outline-none focus:border-[#0066FF]"
                  />
                  <input
                    value={form.location}
                    onChange={(e) => setForm({ ...form, location: e.target.value })}
                    placeholder="Manzil"
                    className="w-full rounded-lg border border-medid-border bg-medid-surface px-3 py-2 text-xs text-medid-text placeholder:text-medid-muted/50 outline-none focus:border-[#0066FF]"
                  />
                  <select
                    value={form.problem}
                    onChange={(e) => setForm({ ...form, problem: e.target.value })}
                    className="w-full rounded-lg border border-medid-border bg-medid-surface px-3 py-2 text-xs text-medid-text outline-none focus:border-[#0066FF]"
                  >
                    <option value="">Muammo turi</option>
                    {problems.map((p) => <option key={p} value={p}>{p}</option>)}
                  </select>
                  <button
                    onClick={handleSend}
                    disabled={!form.name || !form.problem}
                    className="w-full flex items-center justify-center gap-2 rounded-lg bg-[#DC2626] text-white py-2.5 text-xs font-medium hover:bg-[#B91C1C] disabled:opacity-50 transition-colors"
                  >
                    {sent ? 'Yuborildi ✓' : <><Send className="h-3.5 w-3.5" /> Yuborish</>}
                  </button>
                </div>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  )
}
