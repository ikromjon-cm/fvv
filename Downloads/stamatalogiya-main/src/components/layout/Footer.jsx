import { NavLink } from 'react-router-dom';
import { useSelector } from 'react-redux';
import { useTranslation } from '../../hooks/useTranslation';

export default function Footer() {
  const { t } = useTranslation();
  const branding = useSelector((s) => s.siteConfig.config.branding);

  return (
    <footer className="footer">
      <div className="footer-inner">
        <div className="footer-brand">
          <div className="logo">
            <div className="logo-icon">{branding.logoLetter || 'D'}</div>
            <div className="logo-text">
              <span className="logo-title">{branding.siteName || 'Dentago Market'}</span>
              <span className="logo-sub">{t('common.footerSub')}</span>
            </div>
          </div>
          <p className="footer-desc">{t('common.footerDesc')}</p>
        </div>
        <div>
          <h4 className="footer-title">{t('common.platform')}</h4>
          <div className="footer-links">
            <NavLink to="/marketplace">{t('nav.marketplace')}</NavLink>
            <NavLink to="/technicians">{t('nav.technicians')}</NavLink>
            <NavLink to="/orders">{t('nav.orders')}</NavLink>
            <NavLink to="/clinics">{t('nav.clinics')}</NavLink>
          </div>
        </div>
        <div>
          <h4 className="footer-title">{t('common.learn')}</h4>
          <div className="footer-links">
            <NavLink to="/academy">{t('nav.academy')}</NavLink>
            <NavLink to="/academy">{t('common.clinicalCourses')}</NavLink>
            <NavLink to="/academy">{t('common.masterclasses')}</NavLink>
            <NavLink to="/academy">{t('common.marketingCourses')}</NavLink>
          </div>
        </div>
        <div>
          <h4 className="footer-title">{t('common.business')}</h4>
          <div className="footer-links">
            <NavLink to="/dashboard">{t('nav.dashboard')}</NavLink>
            <NavLink to="/dashboard">{t('common.partnerships')}</NavLink>
            <a href="#support">{t('common.support')}</a>
            <NavLink to="/admin">{t('admin.link')}</NavLink>
          </div>
        </div>
      </div>
      <div className="footer-bottom">
        <span>&copy; 2026 {branding.siteName || 'Dentago Market'}. {t('common.rights')}</span>
        <span>{t('common.footerTag')}</span>
      </div>
    </footer>
  );
}
