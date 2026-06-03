import { createSlice } from '@reduxjs/toolkit';
import { courses } from '../../data/mockData';

const initialState = {
  courses,
  activeCategory: 'all',
  enrolled: [],
};

const coursesSlice = createSlice({
  name: 'courses',
  initialState,
  reducers: {
    setCourseCategory: (state, action) => {
      state.activeCategory = action.payload;
    },
    enrollCourse: (state, action) => {
      if (!state.enrolled.includes(action.payload)) {
        state.enrolled.push(action.payload);
      }
    },
    updateProgress: (state, action) => {
      const course = state.courses.find((c) => c.id === action.payload.id);
      if (course) course.progress = action.payload.progress;
    },
    syncFromConfig: (state, action) => {
      state.courses = action.payload.courses;
    },
  },
});

export const { setCourseCategory, enrollCourse, updateProgress, syncFromConfig } = coursesSlice.actions;
export default coursesSlice.reducer;
