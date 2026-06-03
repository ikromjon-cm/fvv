import { Link } from 'react-router-dom';
import { useSelector } from 'react-redux';
import PremiumGate from '../components/layout/PremiumGate';
import { useTranslation } from '../hooks/useTranslation';
import Rating from '../components/ui/Rating';
import AppIcon from '../components/ui/AppIcon';
import { telUrl } from '../utils/maps';

export default function TechniciansHub() {
  const { t } = useTranslation();
  const technicians = useSelector((state) => state.technicians.list);

  return (
    <div className="page">
      <div className="section-header">
        <div>
          <span className="label">{t('technicians.label')}</span>
          <h1 className="title">{t('technicians.title')}</h1>
          <p className="subtitle">{t('technicians.subtitle')}</p>
        </div>
        <PremiumGate message={t('technicians.registerOrder')}>
          <Link to="/orders" className="btn btn-gold">{t('technicians.sendOrder')}</Link>
        </PremiumGate>
      </div>

      <div className="stack">
        {technicians.map((tech) => (
          <article key={tech.id} className="card technician-card">
            <div className="avatar">{tech.name.split(' ').map((n) => n[0]).join('')}</div>
            <div>
              <h3 className="card-title">{tech.name}</h3>
              <p className="card-meta">
                <AppIcon name="default" size={14} />
                {tech.specialty} &middot;
                <AppIcon name="location" size={14} />
                {tech.location}
              </p>
              <div className="tech-meta">
                <Rating value={tech.rating} />
                <span className="card-meta">{tech.orders} {t('common.ordersCompleted')}</span>
                <span className="card-meta">{tech.portfolio} {t('common.portfolioItems')}</span>
              </div>
              {tech.phone && (
                <a href={telUrl(tech.phone)} className="clinic-phone">
                  <AppIcon name="phone" size={14} />
                  {tech.phone}
                </a>
              )}
            </div>
            <div className="tech-side">
              <div className="price">${tech.priceFrom}</div>
              <p className="card-meta">{t('common.from')} / {t('common.perUnit')}</p>
              <span className={`badge ${tech.availability === 'Available' ? 'badge-success' : 'badge-warning'}`}>
                {tech.availability === 'Available' ? t('common.available') : t('common.busy')}
              </span>
              <Link
                to="/orders"
                state={{ technicianId: tech.id, technicianName: tech.name }}
                className="btn btn-primary btn-sm tech-order-btn"
              >
                {t('common.orderNow')}
              </Link>
            </div>
          </article>
        ))}
      </div>
    </div>
  );
}
