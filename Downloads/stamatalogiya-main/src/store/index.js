import { configureStore } from '@reduxjs/toolkit';
import authReducer from './slices/authSlice';
import marketplaceReducer from './slices/marketplaceSlice';
import clinicsReducer from './slices/clinicsSlice';
import coursesReducer from './slices/coursesSlice';
import ordersReducer from './slices/ordersSlice';
import dashboardReducer from './slices/dashboardSlice';
import settingsReducer from './slices/settingsSlice';
import siteConfigReducer from './slices/siteConfigSlice';
import techniciansReducer from './slices/techniciansSlice';
import forumReducer from './slices/forumSlice';
import { loadSiteConfig, buildPreloadedState } from '../utils/siteConfigStorage';

const persisted = typeof window !== 'undefined' ? loadSiteConfig() : null;
const preloadedState = persisted ? buildPreloadedState(persisted) : undefined;

export const store = configureStore({
  reducer: {
    auth: authReducer,
    marketplace: marketplaceReducer,
    clinics: clinicsReducer,
    courses: coursesReducer,
    orders: ordersReducer,
    dashboard: dashboardReducer,
    settings: settingsReducer,
    siteConfig: siteConfigReducer,
    technicians: techniciansReducer,
    forum: forumReducer,
  },
  preloadedState,
});

export { applySiteConfigToStore } from './applySiteConfig';
