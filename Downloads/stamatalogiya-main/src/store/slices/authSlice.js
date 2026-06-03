import { createSlice } from '@reduxjs/toolkit';

const loadUser = () => {
  try {
    const stored = localStorage.getItem('dentago_user');
    return stored ? JSON.parse(stored) : null;
  } catch {
    return null;
  }
};

const initialState = {
  user: loadUser(),
  isRegistered: !!loadUser(),
  showRegistration: !loadUser(),
};

const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    registerUser: (state, action) => {
      state.user = action.payload;
      state.isRegistered = true;
      state.showRegistration = false;
      localStorage.setItem('dentago_user', JSON.stringify(action.payload));
    },
    logoutUser: (state) => {
      state.user = null;
      state.isRegistered = false;
      state.showRegistration = true;
      localStorage.removeItem('dentago_user');
    },
    openRegistration: (state) => {
      state.showRegistration = true;
    },
    closeRegistration: (state) => {
      if (state.isRegistered) {
        state.showRegistration = false;
      }
    },
  },
});

export const { registerUser, logoutUser, openRegistration, closeRegistration } = authSlice.actions;
export default authSlice.reducer;
