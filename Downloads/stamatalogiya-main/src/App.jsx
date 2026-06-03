import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Layout from './components/layout/Layout';
import Home from './pages/Home';
import Marketplace from './pages/Marketplace';
import TechniciansHub from './pages/TechniciansHub';
import Orders from './pages/Orders';
import Clinics from './pages/Clinics';
import Academy from './pages/Academy';
import Dashboard from './pages/Dashboard';
import CourseDetail from './pages/CourseDetail';
import Admin from './pages/Admin';
import DentagoForum from './pages/DentagoForum';

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
          <Route path="/forum" element={<DentagoForum />} />
        <Route path="/" element={<Layout />}>
          <Route index element={<Home />} />
          <Route path="marketplace" element={<Marketplace />} />
          <Route path="technicians" element={<TechniciansHub />} />
          <Route path="orders" element={<Orders />} />
          <Route path="clinics" element={<Clinics />} />
          <Route path="academy" element={<Academy />} />
          <Route path="academy/:id" element={<CourseDetail />} />
          <Route path="dashboard" element={<Dashboard />} />
          <Route path="admin" element={<Admin />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}
