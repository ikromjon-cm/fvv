'use client'

import { useEffect, useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Shield, Camera, CheckCircle, X, Plus, Play, Image } from 'lucide-react'
import { useFvvStore } from '@/store/fvvStore'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent } from '@/components/ui/card'
import { useToast } from '@/components/shared/toast'
import { uychiMahallalar, incidentCategories } from '@/mock/data'

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

export default function MchsPage() {
  const {
    incidents,
    isLoading,
    fetchIncidents,
    fetchStats,
    addIncident,
    startInvestigation,
    resolveIncident,
    approveIncident,
    rejectIncident,
    selectedIncident,
    setSelectedIncident,
    showValidationPanel,
    setShowValidationPanel,
  } = useFvvStore()

  const { addToast } = useToast()
  const [showForm, setShowForm] = useState(false)
  const [formData, setFormData] = useState({
    neighborhood: '',
    household_address: '',
    category: "Yong'in xavfi / Profilaktika",
    severity: 'MEDIUM',
    reporter: '',
    resolution_deadline: '24 soat ichida',
    notes: '',
  })
  const [photo1Preview, setPhoto1Preview] = useState('')
  const [photo2Preview, setPhoto2Preview] = useState('')
  const [showRejectDialog, setShowRejectDialog] = useState(false)
  const [rejectReason, setRejectReason] = useState('')
  const [showConfirmDialog, setShowConfirmDialog] = useState(false)
  const [confirmName, setConfirmName] = useState('')

  useEffect(() => {
    fetchIncidents().catch(console.error)
    fetchStats().catch(console.error)
  }, [fetchIncidents, fetchStats])

  const handleCreate = async () => {
    if (!formData.neighborhood || !formData.household_address || !formData.reporter) {
      addToast('Mahalla, manzil va xodim FIO to\'ldirilishi shart', 'error')
      return
    }
    const photoUrl = photo1Preview || `https://images.unsplash.com/photo-${Math.floor(Math.random() * 1000000000)}?q=80&w=400`
    const lat = 41.05 + Math.random() * 0.02
    const lng = 71.76 + Math.random() * 0.03
    const success = await addIncident({
      ...formData,
      initial_report_photo: photoUrl,
      district: 'Uychi tumani',
      region: 'Namangan viloyati',
      coordinates: [lat, lng] as [number, number],
    } as Partial<import('@/mock/data').FvvIncident>)
    if (success) {
      addToast('Yangi tekshiruv muvaffaqiyatli yaratildi', 'success')
      setShowForm(false)
      setFormData({ neighborhood: '', household_address: '', category: "Yong'in xavfi / Profilaktika", severity: 'MEDIUM', reporter: '', resolution_deadline: '24 soat ichida', notes: '' })
      setPhoto1Preview('')
    } else {
      addToast('Xatolik yuz berdi, qayta urinib ko\'ring', 'error')
    }
  }

  const handleResolve = async (id: string) => {
    const photoUrl = photo2Preview || `https://images.unsplash.com/photo-${Math.floor(Math.random() * 1000000000)}?q=80&w=400`
    await resolveIncident(id, photoUrl)
    setPhoto2Preview('')
  }

  const handleApprove = async () => {
    if (selectedIncident && confirmName) {
      await approveIncident(selectedIncident.id)
      setShowConfirmDialog(false)
      setConfirmName('')
    }
  }

  const handleReject = async () => {
    if (selectedIncident && rejectReason) {
      await rejectIncident(selectedIncident.id)
      setShowRejectDialog(false)
      setRejectReason('')
    }
  }

  const generatePhoto = () => {
    return `https://images.unsplash.com/photo-${Math.floor(Math.random() * 1000000000)}?q=80&w=400`
  }

  const pendingValidation = incidents.filter((i) => i.validation_status === 'PENDING_APPROVAL' && i.resolved_photo)

  return (
    <div className="min-h-screen bg-medid-surface flex flex-col">
      {/* Header */}
      <div className="shrink-0 bg-medid-navy px-6 py-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Shield className="h-6 w-6 text-[#0066FF]" />
            <h1 className="text-lg font-bold text-white">MCHS Inspeksiya va Validatsiya</h1>
          </div>
          <div className="flex items-center gap-2">
            {pendingValidation.length > 0 && (
              <Button variant="warning" size="sm" onClick={() => setShowValidationPanel(true)}>
                <CheckCircle className="h-4 w-4" /> {pendingValidation.length} ta tasdiqlash
              </Button>
            )}
            <Button variant="primary" size="sm" onClick={() => setShowForm(true)}>
              <Plus className="h-4 w-4" /> Yangi tekshiruv
            </Button>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="flex-1">
        {/* Main list */}
        <div className="p-4">
          <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-3">
            <AnimatePresence>
              {isLoading ? (
                Array.from({ length: 6 }).map((_, i) => (
                  <div key={i} className="animate-pulse rounded-xl bg-gray-100 h-48" />
                ))
              ) : (
                incidents.map((inc, idx) => (
                  <motion.div
                    key={inc.id}
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: idx * 0.03 }}
                  >
                    <Card className="overflow-hidden">
                      <div className="relative h-36 bg-gray-100">
                        <img
                          src={inc.initial_report_photo}
                          alt=""
                          className="w-full h-full object-cover"
                          onError={(e) => { (e.target as HTMLImageElement).style.display = 'none' }}
                        />
                        <Badge
                          variant={inc.severity === 'CRITICAL' ? 'danger' : inc.severity === 'HIGH' ? 'warning' : inc.severity === 'MEDIUM' ? 'info' : 'success'}
                          size="sm"
                          className="absolute top-2 left-2"
                        >
                          {inc.severity}
                        </Badge>
                        <span className="absolute top-2 right-2 text-[10px] font-mono bg-black/60 text-white px-1.5 py-0.5 rounded">
                          {inc.id}
                        </span>
                      </div>
                      <CardContent className="p-3">
                        <p className="text-sm font-medium text-medid-text">{inc.category}</p>
                        <p className="text-xs text-medid-muted mt-0.5">{inc.neighborhood} • {inc.household_address}</p>
                        <div className="flex items-center gap-2 mt-2">
                          <span className={`text-[10px] px-1.5 py-0.5 rounded-full text-white ${statusConfig[inc.status]?.color}`}>
                            {statusConfig[inc.status]?.label}
                          </span>
                          <span className={`text-[10px] px-1.5 py-0.5 rounded-full ${validationConfig[inc.validation_status]?.color}`}>
                            {validationConfig[inc.validation_status]?.label}
                          </span>
                        </div>
                        <div className="flex items-center justify-between mt-2">
                          <span className="text-[10px] text-medid-muted">{inc.reporter}</span>
                          <span className="text-[10px] text-medid-muted">{inc.inspection_timestamp}</span>
                        </div>
                        {inc.status === 'UNDER_INVESTIGATION' && (
                          <button
                            onClick={() => startInvestigation(inc.id).then((ok) => { if (ok) addToast(`Tekshiruv boshlandi: ${inc.id}`, 'success') })}
                            className="mt-2 w-full flex items-center justify-center gap-1 py-1.5 rounded-lg bg-[#3B82F6]/10 text-[#3B82F6] text-xs font-medium hover:bg-[#3B82F6]/20 transition-colors"
                          >
                            <Play className="h-3 w-3" /> Tekshiruvni boshlash
                          </button>
                        )}
                        {inc.status === 'IN_PROGRESS' && !inc.resolved_photo && (
                          <button
                            onClick={() => {
                              const url = `https://images.unsplash.com/photo-${Math.floor(Math.random() * 1000000000)}?q=80&w=400`
                              resolveIncident(inc.id, url).then((ok) => { if (ok) addToast(`Foto-2 yuklandi: ${inc.id}`, 'success') })
                            }}
                            className="mt-2 w-full flex items-center justify-center gap-1 py-1.5 rounded-lg bg-[#22C55E]/10 text-[#22C55E] text-xs font-medium hover:bg-[#22C55E]/20 transition-colors"
                          >
                            <Image className="h-3 w-3" /> Foto-2 yuklash
                          </button>
                        )}
                      </CardContent>
                    </Card>
                  </motion.div>
                ))
              )}
            </AnimatePresence>
          </div>
        </div>
      </div>

      {/* Create Form Dialog */}
      <AnimatePresence>
        {showForm && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-50 bg-black/40 flex items-center justify-center p-4"
          >
            <motion.div
              initial={{ scale: 0.95, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.95, opacity: 0 }}
              className="bg-medid-card rounded-xl shadow-2xl w-full max-w-lg max-h-[90vh] overflow-y-auto"
            >
              <div className="flex items-center justify-between p-4 border-b border-medid-border">
                <h3 className="text-base font-semibold text-medid-text">Yangi tekshiruv</h3>
                <button onClick={() => setShowForm(false)} className="p-1 rounded hover:bg-medid-surface">
                  <X className="h-5 w-5 text-medid-muted" />
                </button>
              </div>
              <div className="p-4 space-y-3">
                <div>
                  <label className="text-xs font-medium text-medid-text">Mahalla</label>
                  <select
                    value={formData.neighborhood}
                    onChange={(e) => setFormData({ ...formData, neighborhood: e.target.value })}
                    className="w-full mt-1 h-10 rounded-lg border border-medid-border bg-medid-card px-3 text-sm"
                  >
                    <option value="">Tanlang...</option>
                    {uychiMahallalar.map((m) => (
                      <option key={m} value={m}>{m}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="text-xs font-medium text-medid-text">Xonadon manzili</label>
                  <input
                    value={formData.household_address}
                    onChange={(e) => setFormData({ ...formData, household_address: e.target.value })}
                    className="w-full mt-1 h-10 rounded-lg border border-medid-border bg-medid-card px-3 text-sm"
                    placeholder="Ko'cha, uy raqami"
                  />
                </div>
                <div>
                  <label className="text-xs font-medium text-medid-text">Kategoriya</label>
                  <select
                    value={formData.category}
                    onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                    className="w-full mt-1 h-10 rounded-lg border border-medid-border bg-medid-card px-3 text-sm"
                  >
                    {incidentCategories.map((c) => (
                      <option key={c} value={c}>{c}</option>
                    ))}
                  </select>
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="text-xs font-medium text-medid-text">Xavf darajasi</label>
                    <select
                      value={formData.severity}
                      onChange={(e) => setFormData({ ...formData, severity: e.target.value })}
                      className="w-full mt-1 h-10 rounded-lg border border-medid-border bg-medid-card px-3 text-sm"
                    >
                      <option value="LOW">Past</option>
                      <option value="MEDIUM">O'rtacha</option>
                      <option value="HIGH">Yuqori</option>
                      <option value="CRITICAL">Kritik</option>
                    </select>
                  </div>
                  <div>
                    <label className="text-xs font-medium text-medid-text">Muddat</label>
                    <select
                      value={formData.resolution_deadline}
                      onChange={(e) => setFormData({ ...formData, resolution_deadline: e.target.value })}
                      className="w-full mt-1 h-10 rounded-lg border border-medid-border bg-medid-card px-3 text-sm"
                    >
                      <option value="12 soat ichida">12 soat</option>
                      <option value="24 soat ichida">24 soat</option>
                      <option value="3 kun">3 kun</option>
                      <option value="Zudlik bilan">Zudlik bilan</option>
                    </select>
                  </div>
                </div>
                <div>
                  <label className="text-xs font-medium text-medid-text">Xodim FIO</label>
                  <input
                    value={formData.reporter}
                    onChange={(e) => setFormData({ ...formData, reporter: e.target.value })}
                    className="w-full mt-1 h-10 rounded-lg border border-medid-border bg-medid-card px-3 text-sm"
                    placeholder="FVV Xodimi"
                  />
                </div>
                <div>
                  <label className="text-xs font-medium text-medid-text">Foto-1 (Muammo holati)</label>
                  <div
                    onClick={() => setPhoto1Preview(generatePhoto())}
                    className="mt-1 w-full h-24 rounded-lg border-2 border-dashed border-medid-border flex items-center justify-center cursor-pointer hover:bg-medid-surface transition-colors"
                  >
                    {photo1Preview ? (
                      <img src={photo1Preview} alt="" className="h-full rounded object-cover" />
                    ) : (
                      <div className="text-center">
                        <Camera className="h-6 w-6 text-medid-muted mx-auto" />
                        <p className="text-xs text-medid-muted mt-1">Yuklash uchun bosing</p>
                      </div>
                    )}
                  </div>
                </div>
                <div>
                  <label className="text-xs font-medium text-medid-text">Eslatma</label>
                  <textarea
                    value={formData.notes}
                    onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
                    className="w-full mt-1 rounded-lg border border-medid-border bg-medid-card px-3 py-2 text-sm h-20 resize-none"
                    placeholder="Qo'shimcha ma'lumot..."
                  />
                </div>
              </div>
              <div className="flex items-center justify-end gap-2 p-4 border-t border-medid-border">
                <Button variant="outline" size="sm" onClick={() => setShowForm(false)}>Bekor qilish</Button>
                <Button variant="primary" size="sm" onClick={handleCreate}>Saqlash</Button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Validation Panel - Side-by-side comparison */}
      <AnimatePresence>
        {showValidationPanel && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-50 bg-black/50 flex items-center justify-center p-4"
          >
            <motion.div
              initial={{ scale: 0.95 }}
              animate={{ scale: 1 }}
              exit={{ scale: 0.95 }}
              className="bg-medid-card rounded-xl shadow-2xl w-full max-w-5xl max-h-[90vh] overflow-y-auto"
            >
              <div className="flex items-center justify-between p-4 border-b border-medid-border">
                <h3 className="text-base font-semibold text-medid-text">Solishtirish va tasdiqlash</h3>
                <button onClick={() => setShowValidationPanel(false)} className="p-1 rounded hover:bg-medid-surface">
                  <X className="h-5 w-5 text-medid-muted" />
                </button>
              </div>
              <div className="p-4 space-y-4">
                {pendingValidation.map((inc) => (
                  <Card key={inc.id} className="overflow-hidden">
                    <CardContent className="p-4">
                      <div className="flex items-center justify-between mb-3">
                        <div className="flex items-center gap-2">
                          <span className="font-mono text-sm font-bold text-medid-text">{inc.id}</span>
                          <Badge variant={inc.severity === 'CRITICAL' ? 'danger' : 'warning'} size="sm">{inc.severity}</Badge>
                        </div>
                        <span className="text-xs text-medid-muted">{inc.neighborhood}</span>
                      </div>
                      <div className="grid grid-cols-2 gap-4">
                        {/* Photo 1 */}
                        <div>
                          <p className="text-xs font-medium text-medid-muted mb-1">❌ ANIQLANGAN MUAMMO (FOTO-1)</p>
                          <p className="text-[11px] text-medid-muted mb-1">Belgilangan muddat: {inc.resolution_deadline}</p>
                          <img
                            src={inc.initial_report_photo}
                            alt=""
                            className="w-full h-48 rounded-lg object-cover border border-medid-border"
                            onError={(e) => { (e.target as HTMLImageElement).style.display = 'none' }}
                          />
                        </div>
                        {/* Photo 2 */}
                        <div>
                          <p className="text-xs font-medium text-medid-muted mb-1">✅ HAL ETILGAN HOLAT (FOTO-2)</p>
                          {inc.resolved_photo ? (
                            <img
                              src={inc.resolved_photo}
                              alt=""
                              className="w-full h-48 rounded-lg object-cover border border-[#22C55E]"
                              onError={(e) => { (e.target as HTMLImageElement).style.display = 'none' }}
                            />
                          ) : (
                            <div className="w-full h-48 rounded-lg border-2 border-dashed border-medid-border flex items-center justify-center bg-gray-50">
                              <div className="text-center">
                                <Camera className="h-8 w-8 text-medid-muted mx-auto" />
                                <p className="text-xs text-medid-muted mt-1">Xodim tasviri kutilmoqda</p>
                              </div>
                            </div>
                          )}
                        </div>
                      </div>
                      <div className="flex items-center justify-end gap-2 mt-3">
                        <Button
                          variant="danger"
                          size="sm"
                          onClick={() => {
                            setSelectedIncident(inc)
                            setShowRejectDialog(true)
                          }}
                        >
                          <X className="h-4 w-4" /> Rad etish
                        </Button>
                        <Button
                          variant="success"
                          size="sm"
                          onClick={() => {
                            setSelectedIncident(inc)
                            setShowConfirmDialog(true)
                          }}
                        >
                          <CheckCircle className="h-4 w-4" /> Holatni Tasdiqlash
                        </Button>
                      </div>
                    </CardContent>
                  </Card>
                ))}
                {pendingValidation.length === 0 && (
                  <div className="text-center py-12">
                    <CheckCircle className="h-12 w-12 text-[#22C55E] mx-auto" />
                    <p className="text-sm text-medid-text mt-2">Barcha hodisalar tasdiqlangan</p>
                  </div>
                )}
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Confirm Dialog */}
      <AnimatePresence>
        {showConfirmDialog && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-[60] bg-black/40 flex items-center justify-center p-4"
          >
            <motion.div
              initial={{ scale: 0.95 }}
              animate={{ scale: 1 }}
              className="bg-medid-card rounded-xl shadow-2xl w-full max-w-sm p-4"
            >
              <h3 className="text-base font-semibold text-medid-text">Tasdiqlashni tasdiqlaysizmi?</h3>
              <p className="text-sm text-medid-muted mt-1">{selectedIncident?.id} — {selectedIncident?.category}</p>
              <div className="mt-3">
                <label className="text-xs font-medium text-medid-text">Tasdiqlovchi FIO</label>
                <input
                  value={confirmName}
                  onChange={(e) => setConfirmName(e.target.value)}
                  className="w-full mt-1 h-10 rounded-lg border border-medid-border bg-medid-card px-3 text-sm"
                  placeholder="F.I.O."
                />
              </div>
              <div className="flex items-center justify-end gap-2 mt-4">
                <Button variant="outline" size="sm" onClick={() => { setShowConfirmDialog(false); setConfirmName('') }}>Bekor qilish</Button>
                <Button variant="success" size="sm" disabled={!confirmName} onClick={handleApprove}>Tasdiqlash</Button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Reject Dialog */}
      <AnimatePresence>
        {showRejectDialog && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-[60] bg-black/40 flex items-center justify-center p-4"
          >
            <motion.div
              initial={{ scale: 0.95 }}
              animate={{ scale: 1 }}
              className="bg-medid-card rounded-xl shadow-2xl w-full max-w-sm p-4"
            >
              <h3 className="text-base font-semibold text-medid-text">Rad etish sababi</h3>
              <p className="text-sm text-medid-muted mt-1">{selectedIncident?.id} — {selectedIncident?.category}</p>
              <div className="mt-3">
                <textarea
                  value={rejectReason}
                  onChange={(e) => setRejectReason(e.target.value)}
                  className="w-full mt-1 rounded-lg border border-medid-border bg-medid-card px-3 py-2 text-sm h-24 resize-none"
                  placeholder="Rad etish sababini kiriting..."
                />
              </div>
              <div className="flex items-center justify-end gap-2 mt-4">
                <Button variant="outline" size="sm" onClick={() => { setShowRejectDialog(false); setRejectReason('') }}>Bekor qilish</Button>
                <Button variant="danger" size="sm" disabled={!rejectReason} onClick={handleReject}>Rad etish</Button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}
