import { createSlice } from '@reduxjs/toolkit';
import { marketplaceProducts, forumAds } from '../../data/mockData';

const initialState = {
  products: marketplaceProducts,
  ads: forumAds,
  activeCategory: 'all',
  searchQuery: '',
  cart: [],
};

const marketplaceSlice = createSlice({
  name: 'marketplace',
  initialState,
  reducers: {
    setCategory: (state, action) => {
      state.activeCategory = action.payload;
    },
    setSearchQuery: (state, action) => {
      state.searchQuery = action.payload;
    },
    addToCart: (state, action) => {
      const exists = state.cart.find((item) => item.id === action.payload.id);
      if (!exists) state.cart.push(action.payload);
    },
    postAd: (state, action) => {
      state.ads.unshift({ ...action.payload, id: Date.now(), date: new Date().toISOString().split('T')[0] });
    },
    syncFromConfig: (state, action) => {
      state.products = action.payload.products;
      state.ads = action.payload.ads;
    },
  },
});

export const { setCategory, setSearchQuery, addToCart, postAd, syncFromConfig } = marketplaceSlice.actions;
export default marketplaceSlice.reducer;
