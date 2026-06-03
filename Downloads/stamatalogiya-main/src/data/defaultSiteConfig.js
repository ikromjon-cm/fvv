import {
  marketplaceProducts,
  forumAds,
  courses,
  technicians,
  dashboardStats,
  patients,
  orders,
} from './mockData';
import clinics from './uzClinicsMock';

export const DEFAULT_SITE_CONFIG = {
  version: 1,
  branding: {
    siteName: 'Dentago Market',
    logoLetter: 'D',
    tagline: { uz: 'Stomatologiya ekotizimi', ru: 'Стоматологическая экосистема', en: 'Dental Ecosystem' },
  },
  theme: {
    tealPrimary: '#0d9488',
    goldAccent: '#d4a017',
    heroGradientStart: '#0f766e',
    heroGradientEnd: '#134e4a',
  },
  hero: {
    stats: [
      { value: '2,400+', labelKey: 'home.stat1' },
      { value: '850+', labelKey: 'home.stat2' },
      { value: '120+', labelKey: 'home.stat3' },
    ],
  },
  adminPassword: 'dentago2026',
  products: marketplaceProducts,
  ads: forumAds,
  clinics,
  courses,
  technicians,
  dashboard: { stats: dashboardStats, patients, orders },
};
