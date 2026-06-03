import { useDispatch, useSelector } from 'react-redux';
import { setActiveTab, setDateRange } from '../store/slices/dashboardSlice';
import PremiumGate from '../components/layout/PremiumGate';
import { useTranslation } from '../hooks/useTranslation';
import AppIcon from '../components/ui/AppIcon';

const sidebarKeys = [
  { id: 'overview', key: 'dashboard.overview', icon: 'overview' },
  { id: 'patients', key: 'dashboard.patients', icon: 'patients' },
  { id: 'reports', key: 'dashboard.reports', icon: 'reports' },
  { id: 'partnerships', key: 'dashboard.partnerships', icon: 'partnerships' },
];

const chartHeights = [45, 72, 58, 85, 65, 90, 78];

const expenseKeys = [
  { key: 'labOrders', amount: 28400 },
  { key: 'supplies', amount: 18200 },
  { key: 'equipment', amount: 22100 },
  { key: 'staff', amount: 20720 },
];

const statusPatientMap = {
  Active: 'patientStatus.active',
  Scheduled: 'patientStatus.scheduled',
};

export default function Dashboard() {
  const dispatch = useDispatch();
  const { t } = useTranslation();
  const { stats, patients, activeTab, dateRange } = useSelector((state) => state.dashboard);

  const dateOptions = [
    { value: 'week', label: t('common.thisWeek') },
    { value: 'month', label: t('common.thisMonth') },
    { value: 'quarter', label: t('common.thisQuarter') },
    { value: 'year', label: t('common.thisYear') },
  ];

  return (
    <div className="page">
      <PremiumGate message={t('dashboard.registerAccess')}>
        <div className="section-header">
          <div>
            <span className="label">{t('dashboard.label')}</span>
            <h1 className="title">{t('dashboard.title')}</h1>
            <p className="subtitle">{t('dashboard.subtitle')}</p>
          </div>
          <select className="select" value={dateRange} onChange={(e) => dispatch(setDateRange(e.target.value))} style={{ maxWidth: 160 }}>
            {dateOptions.map((opt) => (
              <option key={opt.value} value={opt.value}>{opt.label}</option>
            ))}
          </select>
        </div>

        <div className="dashboard-layout">
          <aside className="sidebar">
            {sidebarKeys.map((item) => (
              <button
                key={item.id}
                type="button"
                className={`sidebar-link${activeTab === item.id ? ' active' : ''}`}
                onClick={() => dispatch(setActiveTab(item.id))}
              >
                <AppIcon name={item.icon} size={18} />
                {t(item.key)}
              </button>
            ))}
          </aside>

          <div>
            {activeTab === 'overview' && (
              <>
                <div className="grid grid-4" style={{ marginBottom: '2rem' }}>
                  <div className="stat">
                    <div className="stat-value">{stats.patients.toLocaleString()}</div>
                    <div className="stat-label">{t('dashboard.patientsStat')}</div>
                  </div>
                  <div className="stat">
                    <div className="stat-value">${(stats.revenue / 1000).toFixed(0)}k</div>
                    <div className="stat-label">{t('dashboard.revenueStat')}</div>
                  </div>
                  <div className="stat">
                    <div className="stat-value">{stats.orders}</div>
                    <div className="stat-label">{t('dashboard.ordersStat')}</div>
                  </div>
                  <div className="stat">
                    <div className="stat-value">{stats.partnerships}</div>
                    <div className="stat-label">{t('dashboard.partnershipsStat')}</div>
                  </div>
                </div>
                <div className="card card-padded">
                  <h3 className="card-title">{t('common.revenueAnalytics')}</h3>
                  <p className="card-meta" style={{ marginBottom: '1rem' }}>{t('common.monthlyOverview')}</p>
                  <div className="chart">
                    {chartHeights.map((h, i) => (
                      <div key={i} className="chart-bar" style={{ height: `${h}%` }} />
                    ))}
                  </div>
                </div>
              </>
            )}

            {activeTab === 'patients' && (
              <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
                <div className="card-header-bar">
                  <h3 className="card-title">{t('dashboard.patients')}</h3>
                </div>
                <div className="table-wrap" tabIndex={0} role="region" aria-label={t('dashboard.patients')}>
                  <table className="table">
                    <thead>
                      <tr>
                        <th>{t('common.name')}</th>
                        <th>{t('common.lastVisit')}</th>
                        <th>{t('common.treatment')}</th>
                        <th>{t('common.status')}</th>
                      </tr>
                    </thead>
                    <tbody>
                      {patients.map((p) => (
                        <tr key={p.id}>
                          <td><strong>{p.name}</strong></td>
                          <td>{p.lastVisit}</td>
                          <td>{p.treatment}</td>
                          <td><span className="badge badge-teal">{t(statusPatientMap[p.status] || 'patientStatus.active')}</span></td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            )}

            {activeTab === 'reports' && (
              <div className="grid grid-2">
                <div className="card card-padded">
                  <h3 className="card-title">{t('common.financialSummary')}</h3>
                  <p className="card-meta" style={{ margin: '1rem 0' }}>{t('common.period')}: {dateRange}</p>
                  <div className="stat-value stat-value-lg">${stats.revenue.toLocaleString()}</div>
                  <p className="card-meta">{t('common.totalRevenue')}</p>
                  <div className="progress" style={{ marginTop: '1.5rem' }}>
                    <div className="progress-bar" style={{ width: '78%' }} />
                  </div>
                  <p className="card-meta" style={{ marginTop: '0.5rem' }}>78% {t('common.quarterlyTarget')}</p>
                </div>
                <div className="card card-padded">
                  <h3 className="card-title">{t('common.expenseBreakdown')}</h3>
                  <ul className="expense-list">
                    {expenseKeys.map((item) => (
                      <li key={item.key}>
                        <span>{t(`common.${item.key}`)}</span>
                        <span className="price price-sm">${item.amount.toLocaleString()}</span>
                      </li>
                    ))}
                  </ul>
                </div>
              </div>
            )}

            {activeTab === 'partnerships' && (
              <div className="grid grid-2">
                {[
                  { clinic: 'Dentago Premium Clinic', lab: 'Aziz Rahimov Lab', orders: 48, since: '2024-03' },
                  { clinic: 'Smile Kids Dental', lab: 'Malika Tosheva Lab', orders: 22, since: '2024-08' },
                  { clinic: 'Femina Dental Studio', lab: 'Jasur Bekov CAD/CAM', orders: 67, since: '2023-11' },
                ].map((p, i) => (
                  <article key={i} className="card card-padded">
                    <h3 className="card-title">{p.clinic}</h3>
                    <p className="card-meta">{t('common.partner')}: {p.lab}</p>
                    <div className="tech-meta">
                      <span className="badge badge-teal">{p.orders} {t('common.ordersCount')}</span>
                      <span className="card-meta">{t('common.since')} {p.since}</span>
                    </div>
                  </article>
                ))}
              </div>
            )}
          </div>
        </div>
      </PremiumGate>
    </div>
  );
}
