import { Outlet } from 'react-router-dom';
import Header from './Header';
import Footer from './Footer';
import RegistrationModal from './RegistrationModal';
import ThemeInit from './ThemeInit';

export default function Layout() {
  return (
    <>
      <ThemeInit />
      <Header />
      <main className="overflow-guard safe-b">
        <Outlet />
      </main>
      <Footer />
      <RegistrationModal />
    </>
  );
}
