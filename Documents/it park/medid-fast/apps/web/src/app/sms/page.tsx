'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { MessageSquare, Send, Smartphone, Clock, CheckCircle } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { PageHeader } from '@/components/layout/page-header'

const messages = [
  { id: 1, from: 'citizen', text: 'Assalomu alaykum, Navbahor mahallasida yong\'in xavfi bor.', time: '14:23', status: 'read' },
  { id: 2, from: 'bot', text: 'Xabar qabul qilindi. Tekshiruv uchun MCHS xodimi yo\'naltirildi.', time: '14:23', status: 'sent' },
  { id: 3, from: 'citizen', text: 'Rahmat, xodim keldi va muammoni bartaraf qildi.', time: '15:45', status: 'read' },
  { id: 4, from: 'bot', text: 'Tasdiq uchun rahmat. FVV Ekotizimi orqali monitoring qilishingiz mumkin.', time: '15:45', status: 'sent' },
]

const stats = [
  { label: 'Bugungi xabarlar', value: '127', color: '#3B82F6' },
  { label: 'Murojaatlar', value: '43', color: '#F59E0B' },
  { label: 'Bot ulangan', value: '12 450', color: '#22C55E' },
  { label: 'Xatolik', value: '0.2%', color: '#DC2626' },
]

export default function SmsPage() {
  const [message, setMessage] = useState('')

  return (
    <div className="min-h-screen bg-medid-surface flex flex-col">
      <PageHeader
        title="SMS / Telegram Bot"
        subtitle="Fuqarolar bilan avtomatik aloqa kanali"
        icon={<div className="flex items-center justify-center w-9 h-9 rounded-xl bg-[#22C55E]/10"><MessageSquare className="h-5 w-5 text-[#22C55E]" /></div>}
        backTo="/dashboard"
      />
      <div className="flex-1 p-4 sm:p-6">
        <div className="max-w-6xl mx-auto">
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-6">
            {stats.map((s) => (
              <div key={s.label} className="rounded-xl border border-medid-border bg-medid-card p-4">
                <p className="text-2xl font-bold" style={{ color: s.color }}>{s.value}</p>
                <p className="text-xs text-medid-muted mt-1">{s.label}</p>
              </div>
            ))}
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <div className="lg:col-span-2 rounded-xl border border-medid-border bg-medid-card overflow-hidden">
              <div className="p-3 border-b border-medid-border flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Smartphone className="h-4 w-4 text-[#22C55E]" />
                  <span className="text-sm font-medium text-medid-text">Telegram Bot — FVV Ekotizimi</span>
                </div>
                <Badge variant="success">Online</Badge>
              </div>
              <div className="h-80 overflow-y-auto p-4 space-y-3 bg-gray-50/50">
                {messages.map((m) => (
                  <motion.div
                    key={m.id}
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    className={`flex ${m.from === 'bot' ? 'justify-start' : 'justify-end'}`}
                  >
                    <div
                      className={`max-w-xs rounded-2xl px-4 py-2 text-sm ${
                        m.from === 'bot'
                          ? 'bg-white border border-medid-border text-medid-text rounded-bl-sm'
                          : 'bg-[#0066FF] text-white rounded-br-sm'
                      }`}
                    >
                      <p>{m.text}</p>
                      <div className={`flex items-center gap-1 mt-1 ${m.from === 'bot' ? 'justify-start' : 'justify-end'}`}>
                        <span className="text-[10px] opacity-60">{m.time}</span>
                        {m.from === 'citizen' && (
                          m.status === 'read' ? <CheckCircle className="h-3 w-3 text-[#22C55E]" /> : <Clock className="h-3 w-3" />
                        )}
                      </div>
                    </div>
                  </motion.div>
                ))}
              </div>
              <div className="p-3 border-t border-medid-border">
                <div className="flex gap-2">
                  <input
                    type="text"
                    value={message}
                    onChange={(e) => setMessage(e.target.value)}
                    placeholder="Xabar yozish..."
                    className="flex-1 px-3 py-2 rounded-lg border border-medid-border text-sm focus:outline-none focus:border-[#0066FF]"
                  />
                  <Button variant="primary" size="sm" onClick={() => { setMessage('') }}>
                    <Send className="h-4 w-4" />
                  </Button>
                </div>
              </div>
            </div>

            <div className="space-y-4">
              <div className="rounded-xl border border-medid-border bg-medid-card p-4">
                <h3 className="text-sm font-semibold text-medid-text mb-3">Shablon xabarlar</h3>
                <div className="space-y-2">
                  {[
                    'Xabar qabul qilindi. Tekshiruv boshlandi.',
                    'MCHS xodimi yo\'naltirildi.',
                    'Muammo bartaraf qilindi. Rahmat!',
                    'Iltimos, qo\'shimcha ma\'lumot bering.',
                  ].map((t, i) => (
                    <button
                      key={i}
                      onClick={() => setMessage(t)}
                      className="w-full text-left p-2 rounded-lg border border-medid-border text-xs text-medid-text hover:bg-gray-50"
                    >
                      {t}
                    </button>
                  ))}
                </div>
              </div>

              <div className="rounded-xl border border-medid-border bg-medid-card p-4">
                <h3 className="text-sm font-semibold text-medid-text mb-3">Kanal statistikasi</h3>
                <div className="space-y-2 text-sm">
                  {[
                    { label: 'SMS orqali', value: '67%' },
                    { label: 'Telegram orqali', value: '28%' },
                    { label: 'Boshqa', value: '5%' },
                  ].map((c) => (
                    <div key={c.label} className="flex items-center justify-between">
                      <span className="text-medid-muted">{c.label}</span>
                      <span className="font-medium text-medid-text">{c.value}</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
