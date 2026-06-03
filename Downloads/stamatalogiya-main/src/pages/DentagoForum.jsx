import { useEffect } from 'react';
import { useDispatch } from 'react-redux';
import { initSettings } from '../store/slices/settingsSlice';
import Nav from '../components/forum/Nav';
import Hero from '../components/forum/Hero';
import Ecosystem from '../components/forum/Ecosystem';
import Map from '../components/forum/Map';
import Timeline from '../components/forum/Timeline';
import Expo from '../components/forum/Expo';
import Partners from '../components/forum/Partners';
import Registration from '../components/forum/Registration';
import Footer from '../components/forum/Footer';

export default function DentagoForum() {
  const dispatch = useDispatch();

  useEffect(() => {
    dispatch(initSettings());
  }, [dispatch]);

  return (
    <div className="forum">
      <Nav />
      <Hero />
      <Ecosystem />
      <Map />
      <Timeline />
      <Expo />
      <Partners />
      <Registration />
      <Footer />
    </div>
  );
}
