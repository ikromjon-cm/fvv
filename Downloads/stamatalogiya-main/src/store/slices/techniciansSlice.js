import { createSlice } from '@reduxjs/toolkit';
import { technicians } from '../../data/mockData';

const techniciansSlice = createSlice({
  name: 'technicians',
  initialState: { list: technicians },
  reducers: {
    setTechnicians: (state, action) => {
      state.list = action.payload;
    },
  },
});

export const { setTechnicians } = techniciansSlice.actions;
export default techniciansSlice.reducer;
