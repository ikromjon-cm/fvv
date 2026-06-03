import { createSlice } from '@reduxjs/toolkit';

const load = (key, fallback) => {
  try {
    const v = localStorage.getItem(key);
    return v ?? fallback;
  } catch {
    return fallback;
  }
};

const initialState = {
  language: load('dentago_lang', 'uz'),
  theme: load('dentago_theme', 'light'),
};

const settingsSlice = createSlice({
  name: 'settings',
  initialState,
  reducers: {
    setLanguage: (state, action) => {
      state.language = action.payload;
      localStorage.setItem('dentago_lang', action.payload);
      document.documentElement.lang = action.payload;
    },
    setTheme: (state, action) => {
      state.theme = action.payload;
      localStorage.setItem('dentago_theme', action.payload);
      document.documentElement.setAttribute('data-theme', action.payload);
    },
    initSettings: (state) => {
      document.documentElement.lang = state.language;
      document.documentElement.setAttribute('data-theme', state.theme);
    },
  },
});

export const { setLanguage, setTheme, initSettings } = settingsSlice.actions;
export default settingsSlice.reducer;
