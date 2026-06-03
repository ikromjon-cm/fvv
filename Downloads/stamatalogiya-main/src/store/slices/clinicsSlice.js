import { createSlice } from '@reduxjs/toolkit';
import clinics from '../../data/uzClinicsMock';

const initialState = {
  clinics,
  activeFilter: 'all',
  selectedClinic: null,
  booking: null,
};

const clinicsSlice = createSlice({
  name: 'clinics',
  initialState,
  reducers: {
    setFilter: (state, action) => {
      state.activeFilter = action.payload;
    },
    selectClinic: (state, action) => {
      state.selectedClinic = action.payload;
    },
    createBooking: (state, action) => {
      state.booking = action.payload;
    },
    clearBooking: (state) => {
      state.booking = null;
    },
    syncFromConfig: (state, action) => {
      state.clinics = action.payload.clinics;
    },
  },
});

export const { setFilter, selectClinic, createBooking, clearBooking, syncFromConfig } = clinicsSlice.actions;
export default clinicsSlice.reducer;
