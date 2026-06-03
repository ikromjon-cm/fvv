import { store } from './index';
import { syncFromConfig as syncMarketplace } from './slices/marketplaceSlice';
import { syncFromConfig as syncClinics } from './slices/clinicsSlice';
import { syncFromConfig as syncCourses } from './slices/coursesSlice';
import { syncFromConfig as syncDashboard } from './slices/dashboardSlice';
import { setTechnicians } from './slices/techniciansSlice';
import { syncFromStorage } from './slices/siteConfigSlice';

export function applySiteConfigToStore(config) {
  store.dispatch(syncMarketplace({ products: config.products, ads: config.ads }));
  store.dispatch(syncClinics({ clinics: config.clinics }));
  store.dispatch(syncCourses({ courses: config.courses }));
  store.dispatch(syncDashboard({
    stats: config.dashboard?.stats,
    patients: config.dashboard?.patients,
  }));
  store.dispatch(setTechnicians(config.technicians));
  store.dispatch(syncFromStorage(config));
}
