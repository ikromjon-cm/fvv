import { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { setTheme } from '../../store/slices/settingsSlice';
import AppIcon from '../ui/AppIcon';

export default function Nav() {
  const [active, setActive] = useState(false);
  const dispatch = useDispatch();
  const { theme } = useSelector(state => state.settings);

  const scroll = (id) => {
    const el = document.getElementById(id);
    if (el) el.scrollIntoView({ behavior: 'smooth' });
    setActive(false);
  };

  return (
    <nav className="nav">
      <div className="inner">
        <div className="logo">
          <div className="mark">D</div>
          <span>DENTAGO FORUM</span>
        </div>

        <div className={`links${active ? ' active' : ''}`}>
          <button type="button" onClick={() => scroll('hero')}>FORUM</button>
          <button type="button" onClick={() => scroll('ecosystem')}>EKOTIZIM</button>
          <button type="button" onClick={() => scroll('timeline')}>DASTUR</button>
          <button type="button" onClick={() => scroll('expo')}>EXPO</button>
          <button type="button" onClick={() => scroll('register')}>RO'YXATDAN O'TISH</button>
        </div>

        <div className="actions">
          <button 
            type="button" 
            className="theme"
            onClick={() => dispatch(setTheme(theme === 'light' ? 'dark' : 'light'))}
            aria-label="Toggle theme"
          >
            <AppIcon name={theme === 'light' ? 'sun' : 'moon'} size={20} />
          </button>
          <button 
            type="button" 
            className="primary"
            onClick={() => scroll('register')}
          >
            RO'YXATDAN O'TISH
          </button>
          <button 
            type="button" 
            className={`burger${active ? ' active' : ''}`}
            onClick={() => setActive(!active)}
            aria-label="Toggle menu"
          >
            <span></span>
            <span></span>
            <span></span>
          </button>
        </div>
      </div>
    </nav>
  );
}
