import { DEFAULT_SITE_CONFIG } from '../data/defaultSiteConfig';

const STORAGE_KEY = 'dentago_site_config_v1';

export function loadSiteConfig() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw);
    return { ...DEFAULT_SITE_CONFIG, ...parsed };
  } catch {
    return null;
  }
}

export function saveSiteConfig(config) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(config));
}

export function clearSiteConfig() {
  localStorage.removeItem(STORAGE_KEY);
}

export function buildPreloadedState(config) {
  const c = config || DEFAULT_SITE_CONFIG;
  return {
    siteConfig: {
      config: c,
      adminAuthenticated: false,
      draft: null,
    },
    marketplace: {
      products: c.products,
      ads: c.ads,
      activeCategory: 'all',
      searchQuery: '',
      cart: [],
    },
    clinics: {
      clinics: c.clinics,
      activeFilter: 'all',
      selectedClinic: null,
      booking: null,
    },
    courses: {
      courses: c.courses,
      activeCategory: 'all',
      enrolled: [],
    },
    dashboard: {
      stats: c.dashboard?.stats ?? DEFAULT_SITE_CONFIG.dashboard.stats,
      patients: c.dashboard?.patients ?? DEFAULT_SITE_CONFIG.dashboard.patients,
      activeTab: 'overview',
      dateRange: 'month',
    },
    technicians: {
      list: c.technicians ?? DEFAULT_SITE_CONFIG.technicians,
    },
    settings: {
      theme: 'light',
      language: 'uz',
      customColors: c.theme,
    },
  };
}
