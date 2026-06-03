import { createSlice } from '@reduxjs/toolkit';
import { DEFAULT_SITE_CONFIG } from '../../data/defaultSiteConfig';
import { saveSiteConfig, clearSiteConfig } from '../../utils/siteConfigStorage';

const initialState = {
  config: DEFAULT_SITE_CONFIG,
  adminAuthenticated: false,
};

const siteConfigSlice = createSlice({
  name: 'siteConfig',
  initialState,
  reducers: {
    loginAdmin: (state, action) => {
      if (action.payload === state.config.adminPassword) {
        state.adminAuthenticated = true;
      }
    },
    logoutAdmin: (state) => {
      state.adminAuthenticated = false;
    },
    updateConfig: (state, action) => {
      state.config = { ...state.config, ...action.payload };
    },
    setConfigField: (state, action) => {
      const { path, value } = action.payload;
      const keys = path.split('.');
      let target = state.config;
      for (let i = 0; i < keys.length - 1; i += 1) {
        target[keys[i]] = target[keys[i]] ?? {};
        target = target[keys[i]];
      }
      target[keys[keys.length - 1]] = value;
    },
    replaceList: (state, action) => {
      const { key, list } = action.payload;
      state.config[key] = list;
    },
    saveAndApply: (state) => {
      saveSiteConfig(state.config);
    },
    resetToDefaults: (state) => {
      state.config = DEFAULT_SITE_CONFIG;
      clearSiteConfig();
    },
    syncFromStorage: (state, action) => {
      state.config = action.payload;
    },
  },
});

export const {
  loginAdmin,
  logoutAdmin,
  updateConfig,
  setConfigField,
  replaceList,
  saveAndApply,
  resetToDefaults,
  syncFromStorage,
} = siteConfigSlice.actions;

export default siteConfigSlice.reducer;
