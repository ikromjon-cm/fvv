import { useState } from 'react'
import { Link } from 'react-router-dom'
import { motion } from 'framer-motion'
import {
  ArrowRight, Users, Award, BookOpen, Globe, Zap, Shield, TrendingUp,
  GraduationCap, CheckCircle, ChevronRight
} from 'lucide-react'
import { stats, questions, testimonials } from '../../utils/data'
import Accordion from '../../components/ui/Accordion'
import StarRating from '../../components/ui/StarRating'

const fadeUp = {
  initial: { opacity: 0, y: 30 },
  whileInView: { opacity: 1, y: 0 },
  viewport: { once: true, margin: '-50px' },
  transition: { duration: 0.5 },
}

const stagger = {
  initial: { opacity: 0, y: 20 },
  whileInView: { opacity: 1, y: 0 },
  viewport: { once: true },
  transition: { staggerChildren: 0.1, delayChildren: 0.1 },
}

export default function Landing() {
  return (
    <div>
      {/* Hero */}
      <section className="relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-indigo-50 via-violet-50 to-purple-50 dark:from-gray-950 dark:via-indigo-950/20 dark:to-gray-950" />
        <div className="absolute top-0 right-0 w-1/2 h-full bg-gradient-to-bl from-indigo-200/20 to-transparent dark:from-indigo-500/5" />
        <div className="absolute -top-40 -left-40 w-80 h-80 rounded-full bg-indigo-200/20 dark:bg-indigo-500/5 blur-3xl" />
        <div className="absolute -bottom-40 -right-40 w-80 h-80 rounded-full bg-violet-200/20 dark:bg-violet-500/5 blur-3xl" />

        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-20 md:pt-28 pb-16 md:pb-24">
          <div className="grid lg:grid-cols-2 gap-12 items-center">
            <motion.div {...stagger}>
              <motion.div {...fadeUp} className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-indigo-100 dark:bg-indigo-500/10 text-indigo-600 dark:text-indigo-400 text-sm font-medium mb-6">
                <Zap size={14} />
                O'zbekistondagi eng yirik olimpiada platformasi
              </motion.div>
              <motion.h1 {...fadeUp} className="text-4xl sm:text-5xl lg:text-6xl font-extrabold text-gray-900 dark:text-gray-100 leading-tight mb-6">
                Bilim va iste'dodni
                <span className="gradient-text"> rivojlantirish </span>
                platformasi
              </motion.h1>
              <motion.p {...fadeUp} className="text-lg text-gray-600 dark:text-gray-400 mb-8 max-w-lg leading-relaxed">
                O'quvchilar uchun zamonaviy olimpiada tizimi. Turli fanlardan olimpiadalarda qatnashing, bilimingizni sinang va sertifikatlarga ega bo'ling.
              </motion.p>
              <motion.div {...fadeUp} className="flex flex-wrap gap-3">
                <Link to="/register" className="gradient-btn px-6 py-3 text-base flex items-center gap-2">
                  Boshlash <ArrowRight size={18} />
                </Link>
                <Link to="/olimpiadalar" className="px-6 py-3 rounded-xl border border-gray-200 dark:border-gray-700 text-gray-700 dark:text-gray-300 font-medium hover:bg-gray-50 dark:hover:bg-gray-800 transition-all text-base flex items-center gap-2">
                  Olimpiadalarni ko'rish
                </Link>
              </motion.div>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.6, delay: 0.2 }}
              className="hidden lg:block"
            >
              <div className="relative">
                <div className="gradient-card p-8 rounded-3xl">
                  <div className="grid grid-cols-2 gap-6">
                    <div className="text-center p-4">
                      <div className="text-4xl font-bold mb-1">{stats.totalStudents.toLocaleString()}</div>
                      <div className="text-indigo-200 text-sm">O'quvchilar</div>
                    </div>
                    <div className="text-center p-4">
                      <div className="text-4xl font-bold mb-1">{stats.totalOlympiads}</div>
                      <div className="text-indigo-200 text-sm">Olimpiadalar</div>
                    </div>
                    <div className="text-center p-4">
                      <div className="text-4xl font-bold mb-1">{stats.certificatesIssued.toLocaleString()}</div>
                      <div className="text-indigo-200 text-sm">Sertifikatlar</div>
                    </div>
                    <div className="text-center p-4">
                      <div className="text-4xl font-bold mb-1">{stats.activeRegions}</div>
                      <div className="text-indigo-200 text-sm">Viloyatlar</div>
                    </div>
                  </div>
                </div>
                <div className="absolute -bottom-4 -right-4 w-full h-full rounded-3xl border-2 border-indigo-200 dark:border-indigo-800 -z-10" />
              </div>
            </motion.div>
          </div>
        </div>
      </section>

      {/* Features */}
      <section className="py-16 md:py-24">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <motion.div {...fadeUp} className="text-center max-w-2xl mx-auto mb-12 md:mb-16">
            <h2 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-gray-100 mb-4">
              Nega aynan <span className="gradient-text">Olimpiada</span>?
            </h2>
            <p className="text-gray-500 dark:text-gray-400">
              Eng zamonaviy va qulay olimpiada platformasi bilan bilimingizni sinang.
            </p>
          </motion.div>

          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {[
              { icon: BookOpen, title: 'Turli fanlar', text: '10 dan ortiq fanlardan olimpiadalar' },
              { icon: Award, title: 'Sertifikatlar', text: 'Rasmiy elektron sertifikatlar' },
              { icon: Globe, title: 'Barcha hududlar', text: "O'zbekiston bo'ylab 14 ta viloyat" },
              { icon: Shield, title: 'Ishonchli tizim', text: 'Xavfsiz va ishonchli platforma' },
              { icon: Zap, title: 'Tez natijalar', text: '7 kun ichida natijalar e\'lon qilinadi' },
              { icon: TrendingUp, title: 'Reyting tizimi', text: 'Shaffof va adolatli baholash' },
            ].map((feat, i) => (
              <motion.div
                key={i}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: i * 0.05 }}
                className="glass-card p-6 group hover:shadow-xl hover:shadow-indigo-500/5 transition-all duration-300"
              >
                <div className="p-3 rounded-2xl bg-indigo-50 dark:bg-indigo-500/10 text-indigo-600 dark:text-indigo-400 w-fit mb-4 group-hover:scale-110 transition-transform">
                  <feat.icon size={24} />
                </div>
                <h3 className="font-semibold text-gray-900 dark:text-gray-100 mb-1.5">{feat.title}</h3>
                <p className="text-sm text-gray-500 dark:text-gray-400">{feat.text}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Stats */}
      <section className="py-16 md:py-24 bg-indigo-50/50 dark:bg-indigo-950/10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6 md:gap-8">
            {[
              { icon: Users, value: `${(stats.totalStudents / 1000).toFixed(0)}K+`, label: "O'quvchilar" },
              { icon: GraduationCap, value: stats.totalOlympiads, label: 'Olimpiadalar' },
              { icon: Award, value: `${(stats.certificatesIssued / 1000).toFixed(0)}K+`, label: 'Sertifikatlar' },
              { icon: Globe, value: stats.activeRegions, label: 'Viloyatlar' },
            ].map((s, i) => (
              <motion.div
                key={i}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: i * 0.1 }}
                className="text-center"
              >
                <div className="p-3 rounded-2xl bg-indigo-100 dark:bg-indigo-500/10 text-indigo-600 dark:text-indigo-400 w-fit mx-auto mb-3">
                  <s.icon size={24} />
                </div>
                <div className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-gray-100 mb-1">{s.value}</div>
                <div className="text-sm text-gray-500 dark:text-gray-400">{s.label}</div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Benefits */}
      <section className="py-16 md:py-24">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <motion.div {...fadeUp} className="text-center max-w-2xl mx-auto mb-12 md:mb-16">
            <h2 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-gray-100 mb-4">
              Qanday <span className="gradient-text">afzalliklar</span> bor?
            </h2>
            <p className="text-gray-500 dark:text-gray-400">
              Platformamizning asosiy afzalliklari bilan tanishing.
            </p>
          </motion.div>

          <div className="grid lg:grid-cols-2 gap-8">
            {[
              { icon: CheckCircle, title: "Bepul qatnashish", text: "Barcha olimpiadalarda qatnashish mutlaqo bepul. Hech qanday to'lov talab qilinmaydi." },
              { icon: CheckCircle, title: "Elektron sertifikatlar", text: "Yuqori natija ko'rsatgan ishtirokchilarga rasmiy elektron sertifikat beriladi." },
              { icon: CheckCircle, title: "Qulay interfeys", text: "Zamonaviy va intuitiv interfeys orqali olimpiadalarni kuzatib boring." },
              { icon: CheckCircle, title: "Tezkor qo'llab-quvvatlash", text: "24/7 texnik qo'llab-quvvatlash xizmati mavjud." },
            ].map((b, i) => (
              <motion.div
                key={i}
                initial={{ opacity: 0, x: i % 2 === 0 ? -20 : 20 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true }}
                transition={{ delay: i * 0.1 }}
                className="flex gap-4 p-6 rounded-2xl bg-gray-50 dark:bg-gray-900/50"
              >
                <div className="p-2 rounded-xl bg-emerald-100 dark:bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 shrink-0 h-fit">
                  <b.icon size={20} />
                </div>
                <div>
                  <h3 className="font-semibold text-gray-900 dark:text-gray-100 mb-1">{b.title}</h3>
                  <p className="text-sm text-gray-500 dark:text-gray-400">{b.text}</p>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Testimonials */}
      <section className="py-16 md:py-24 bg-indigo-50/50 dark:bg-indigo-950/10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <motion.div {...fadeUp} className="text-center max-w-2xl mx-auto mb-12 md:mb-16">
            <h2 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-gray-100 mb-4">
              Ishtirokchilar <span className="gradient-text">fikrlari</span>
            </h2>
          </motion.div>

          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {testimonials.slice(0, 3).map((t, i) => (
              <motion.div
                key={i}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: i * 0.1 }}
                className="glass-card p-6"
              >
                <StarRating rating={t.rating} />
                <p className="text-gray-600 dark:text-gray-400 text-sm mt-3 mb-4 leading-relaxed">"{t.text}"</p>
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-gradient-to-br from-indigo-500 to-violet-600 flex items-center justify-center text-white text-sm font-semibold">
                    {t.name[0]}
                  </div>
                  <div>
                    <div className="text-sm font-medium text-gray-900 dark:text-gray-100">{t.name}</div>
                    <div className="text-xs text-gray-500 dark:text-gray-400">{t.role}</div>
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* FAQ */}
      <section className="py-16 md:py-24">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
          <motion.div {...fadeUp} className="text-center max-w-2xl mx-auto mb-12">
            <h2 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-gray-100 mb-4">
              Ko'p so'raladigan <span className="gradient-text">savollar</span>
            </h2>
          </motion.div>
          <Accordion items={questions} />
        </div>
      </section>

      {/* CTA */}
      <section className="py-16 md:py-24">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="gradient-card rounded-3xl p-8 md:p-12 text-center"
          >
            <h2 className="text-3xl md:text-4xl font-bold mb-4">Bugunoq boshlang!</h2>
            <p className="text-indigo-200 mb-8 max-w-lg mx-auto">
              O'z bilimingizni sinab ko'ring va eng yaxshi natijalarga erishing.
            </p>
            <Link to="/register" className="inline-flex items-center gap-2 bg-white text-indigo-600 font-semibold px-8 py-3.5 rounded-xl hover:bg-indigo-50 transition-all shadow-xl shadow-black/10">
              Ro'yxatdan o'tish <ChevronRight size={20} />
            </Link>
          </motion.div>
        </div>
      </section>
    </div>
  )
}
