import { createSlice } from '@reduxjs/toolkit';
import { dashboardStats, patients } from '../../data/mockData';

const initialState = {
  stats: dashboardStats,
  patients,
  activeTab: 'overview',
  dateRange: 'month',
};

const dashboardSlice = createSlice({
  name: 'dashboard',
  initialState,
  reducers: {
    setActiveTab: (state, action) => {
      state.activeTab = action.payload;
    },
    setDateRange: (state, action) => {
      state.dateRange = action.payload;
    },
    addPatient: (state, action) => {
      state.patients.unshift({ ...action.payload, id: Date.now() });
      state.stats.patients += 1;
    },
    syncFromConfig: (state, action) => {
      state.stats = action.payload.stats;
      state.patients = action.payload.patients;
    },
  },
});

export const { setActiveTab, setDateRange, addPatient, syncFromConfig } = dashboardSlice.actions;
export default dashboardSlice.reducer;
