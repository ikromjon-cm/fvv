import { useState } from 'react';
import { NavLink, useNavigate } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import { navLinks } from '../../data/mockData';
import { openRegistration, logoutUser } from '../../store/slices/authSlice';
import { useTranslation } from '../../hooks/useTranslation';
import SettingsBar from './SettingsBar';

export default function Header() {
  const [mobileOpen, setMobileOpen] = useState(false);
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const { t } = useTranslation();
  const { isRegistered, user } = useSelector((state) => state.auth);

  const handleNav = (path) => {
    setMobileOpen(false);
    navigate(path);
  };

  const roleLabel = user?.role ? t(`roles.${user.role}`) : '';
  const branding = useSelector((s) => s.siteConfig.config.branding);

  return (
    <header className="header">
      <div className="header-inner">
        <NavLink to="/" className="logo" onClick={() => setMobileOpen(false)}>
          <div className="logo-icon">{branding.logoLetter || 'D'}</div>
          <div className="logo-text">
            <span className="logo-title">{branding.siteName || 'Dentago Market'}</span>
            <span className="logo-sub">{t('common.logoSub')}</span>
          </div>
        </NavLink>

        <nav className="nav" aria-label="Main navigation">
          {navLinks.map((link) => (
            <NavLink
              key={link.path}
              to={link.path}
              className={({ isActive }) => `nav-link${isActive ? ' active' : ''}`}
              end={link.path === '/'}
            >
              {t(link.key)}
            </NavLink>
          ))}
        </nav>

        <div className="header-actions">
          <SettingsBar compact />
          {isRegistered ? (
            <>
              <span className="badge badge-gold">{roleLabel}</span>
              <button type="button" className="btn btn-outline btn-sm" onClick={() => dispatch(logoutUser())}>
                {t('common.logout')}
              </button>
            </>
          ) : (
            <button type="button" className="btn btn-gold btn-sm" onClick={() => dispatch(openRegistration())}>
              {t('common.register')}
            </button>
          )}
          <button
            type="button"
            className="burger"
            aria-label={t('common.menu')}
            aria-expanded={mobileOpen}
            onClick={() => setMobileOpen(!mobileOpen)}
          >
            <span /><span /><span />
          </button>
        </div>
      </div>

      <nav className={`mobile-nav${mobileOpen ? ' open' : ''}`} aria-label="Mobile navigation">
        {navLinks.map((link) => (
          <button
            key={link.path}
            type="button"
            className="nav-link"
            onClick={() => handleNav(link.path)}
          >
            {t(link.key)}
          </button>
        ))}
        <div className="mobile-settings">
          <SettingsBar />
        </div>
      </nav>
    </header>
  );
}
