import { createSlice } from '@reduxjs/toolkit';

const initialState = {
  registered: [],
  submitted: false,
};

const forumSlice = createSlice({
  name: 'forum',
  initialState,
  reducers: {
    registerForum: (state, action) => {
      state.registered.push({
        ...action.payload,
        id: Date.now(),
        timestamp: new Date().toISOString(),
      });
      state.submitted = true;
      setTimeout(() => {
        state.submitted = false;
      }, 3000);
    },
  },
});

export const { registerForum } = forumSlice.actions;
export default forumSlice.reducer;
