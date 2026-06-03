import { useDispatch, useSelector } from 'react-redux';
import { Link } from 'react-router-dom';
import { openRegistration } from '../store/slices/authSlice';
import { useTranslation } from '../hooks/useTranslation';
import AppIcon from '../components/ui/AppIcon';

const featureKeys = [
  { icon: 'marketplace', title: 'home.f1title', desc: 'home.f1desc', path: '/marketplace' },
  { icon: 'technicians', title: 'home.f2title', desc: 'home.f2desc', path: '/technicians' },
  { icon: 'clinics', title: 'home.f3title', desc: 'home.f3desc', path: '/clinics' },
  { icon: 'academy', title: 'home.f4title', desc: 'home.f4desc', path: '/academy' },
  { icon: 'dashboard', title: 'home.f5title', desc: 'home.f5desc', path: '/dashboard' },
  { icon: 'forum', title: 'home.f6title', desc: 'home.f6desc', path: '/marketplace' },
];

const defaultStats = [
  { value: '2,400+', labelKey: 'home.stat1' },
  { value: '850+', labelKey: 'home.stat2' },
  { value: '120+', labelKey: 'home.stat3' },
];

export default function Home() {
  const dispatch = useDispatch();
  const { t } = useTranslation();
  const heroStats = useSelector((s) => s.siteConfig.config.hero?.stats) || defaultStats;

  return (
    <div className="page">
      <section className="hero">
        <div className="hero-content">
          <span className="label">{t('home.label')}</span>
          <h1 className="title title-lg serif">{t('home.title')}</h1>
          <p className="subtitle">{t('home.subtitle')}</p>
          <div className="hero-actions">
            <button type="button" className="btn btn-gold btn-lg" onClick={() => dispatch(openRegistration())}>
              {t('home.cta')}
            </button>
            <Link to="/marketplace" className="btn btn-outline btn-lg">
              {t('home.explore')}
            </Link>
          </div>
          <div className="hero-stats">
            {heroStats.map((stat) => (
              <div key={stat.labelKey}>
                <div className="hero-stat-value">{stat.value}</div>
                <div className="hero-stat-label">{t(stat.labelKey)}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="section">
        <div className="section-header">
          <div>
            <span className="label">{t('home.featuresLabel')}</span>
            <h2 className="title">{t('home.featuresTitle')}</h2>
          </div>
        </div>
        <div className="features">
          {featureKeys.map((f) => (
            <Link key={f.title} to={f.path} className="feature">
              <div className="feature-icon" aria-hidden="true">
                <AppIcon name={f.icon} size={26} className="feature-icon-svg" />
              </div>
              <h3 className="feature-title">{t(f.title)}</h3>
              <p className="feature-desc">{t(f.desc)}</p>
            </Link>
          ))}
        </div>
      </section>

      <section className="section">
        <div className="card-glass forum-banner">
          <div className="grid grid-2" style={{ alignItems: 'center', gap: '2rem' }}>
            <div>
              <span className="label forum-label">{t('home.forumLabel')}</span>
              <h2 className="title forum-title">{t('home.forumTitle')}</h2>
              <p className="subtitle forum-desc">{t('home.forumDesc')}</p>
            </div>
            <div className="forum-cta">
              <Link to="/marketplace" className="btn btn-gold btn-lg">{t('home.forumCta')}</Link>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
