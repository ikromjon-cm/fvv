import { createSlice } from '@reduxjs/toolkit';
import { orders as initialOrders } from '../../data/mockData';

const initialState = {
  orders: initialOrders,
  draftOrder: {
    type: '',
    description: '',
    files: [],
    technicianId: null,
    patient: '',
  },
};

const ordersSlice = createSlice({
  name: 'orders',
  initialState,
  reducers: {
    updateDraft: (state, action) => {
      state.draftOrder = { ...state.draftOrder, ...action.payload };
    },
    submitOrder: (state, action) => {
      state.orders.unshift({
        id: `ORD-${Date.now().toString().slice(-4)}`,
        status: 'Pending Review',
        date: new Date().toISOString().split('T')[0],
        ...action.payload,
      });
      state.draftOrder = { type: '', description: '', files: [], technicianId: null, patient: '' };
    },
    updateOrderStatus: (state, action) => {
      const order = state.orders.find((o) => o.id === action.payload.id);
      if (order) order.status = action.payload.status;
    },
  },
});

export const { updateDraft, submitOrder, updateOrderStatus } = ordersSlice.actions;
export default ordersSlice.reducer;
