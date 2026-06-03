import { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import {
  loginAdmin,
  logoutAdmin,
  updateConfig,
  replaceList,
  saveAndApply,
  resetToDefaults,
} from '../store/slices/siteConfigSlice';
import { applySiteConfigToStore } from '../store/applySiteConfig';
import { useTranslation } from '../hooks/useTranslation';
import AppIcon from '../components/ui/AppIcon';

const TABS = [
  { id: 'branding', label: 'admin.tabs.branding', icon: 'default' },
  { id: 'theme', label: 'admin.tabs.theme', icon: 'dashboard' },
  { id: 'hero', label: 'admin.tabs.hero', icon: 'overview' },
  { id: 'products', label: 'admin.tabs.products', icon: 'marketplace' },
  { id: 'clinics', label: 'admin.tabs.clinics', icon: 'clinics' },
  { id: 'courses', label: 'admin.tabs.courses', icon: 'academy' },
  { id: 'technicians', label: 'admin.tabs.technicians', icon: 'technicians' },
  { id: 'security', label: 'admin.tabs.security', icon: 'lock' },
];

function ListEditor({ items, onChange, fields }) {
  const updateItem = (index, key, value) => {
    const next = items.map((item, i) => (i === index ? { ...item, [key]: value } : item));
    onChange(next);
  };

  const addItem = () => {
    const template = fields.reduce((acc, f) => ({ ...acc, [f.key]: f.default ?? '' }), { id: Date.now() });
    onChange([...items, template]);
  };

  const removeItem = (index) => onChange(items.filter((_, i) => i !== index));

  return (
    <div className="admin-list">
      {items.map((item, index) => (
        <div key={item.id ?? index} className="admin-list-item card card-padded">
          {fields.map((field) => (
            <div key={field.key} className="field">
              <label>{field.label}</label>
              {field.type === 'textarea' ? (
                <textarea
                  className="input"
                  rows={2}
                  value={Array.isArray(item[field.key]) ? item[field.key].join(', ') : (item[field.key] ?? '')}
                  onChange={(e) => {
                    const val = field.array
                      ? e.target.value.split(',').map((s) => s.trim()).filter(Boolean)
                      : e.target.value;
                    updateItem(index, field.key, val);
                  }}
                />
              ) : (
                <input
                  className="input"
                  type={field.type || 'text'}
                  value={item[field.key] ?? ''}
                  onChange={(e) => updateItem(index, field.key, field.type === 'number' ? Number(e.target.value) : e.target.value)}
                />
              )}
            </div>
          ))}
          <button type="button" className="btn btn-ghost btn-sm" onClick={() => removeItem(index)}>×</button>
        </div>
      ))}
      <button type="button" className="btn btn-outline btn-sm" onClick={addItem}>+</button>
    </div>
  );
}

export default function Admin() {
  const dispatch = useDispatch();
  const { t } = useTranslation();
  const { config, adminAuthenticated } = useSelector((s) => s.siteConfig);
  const [tab, setTab] = useState('branding');
  const [password, setPassword] = useState('');
  const [saved, setSaved] = useState(false);

  const [loginError, setLoginError] = useState(false);

  const handleLogin = (e) => {
    e.preventDefault();
    if (password === config.adminPassword) {
      dispatch(loginAdmin(password));
      setLoginError(false);
    } else {
      setLoginError(true);
    }
  };

  const handleSave = () => {
    dispatch(saveAndApply());
    applySiteConfigToStore(config);
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  };

  if (!adminAuthenticated) {
    return (
      <div className="page admin-page">
        <div className="admin-login card card-padded">
          <AppIcon name="admin" size={40} />
          <h1 className="title">{t('admin.title')}</h1>
          <p className="subtitle">{t('admin.loginHint')}</p>
          <form className="form" onSubmit={handleLogin}>
            <div className="field">
              <label>{t('admin.password')}</label>
              <input
                className="input"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="dentago2026"
                autoComplete="current-password"
              />
            </div>
            {loginError && <p className="card-meta" style={{ color: 'var(--danger)' }}>{t('admin.wrongPassword')}</p>}
            <button type="submit" className="btn btn-gold" style={{ width: '100%' }}>{t('admin.login')}</button>
          </form>
        </div>
      </div>
    );
  }

  return (
    <div className="page admin-page">
      <div className="section-header">
        <div>
          <span className="label">{t('admin.label')}</span>
          <h1 className="title">{t('admin.panelTitle')}</h1>
          <p className="subtitle">{t('admin.subtitle')}</p>
        </div>
        <div className="admin-header-actions">
          {saved && <span className="badge badge-success">{t('admin.saved')}</span>}
          <button type="button" className="btn btn-gold" onClick={handleSave}>{t('admin.save')}</button>
          <button
            type="button"
            className="btn btn-outline btn-sm"
            onClick={() => {
              dispatch(resetToDefaults());
              window.location.reload();
            }}
          >
            {t('admin.reset')}
          </button>
          <button type="button" className="btn btn-ghost btn-sm" onClick={() => dispatch(logoutAdmin())}>
            {t('common.logout')}
          </button>
        </div>
      </div>

      <div className="admin-layout">
        <aside className="admin-tabs">
          {TABS.map((item) => (
            <button
              key={item.id}
              type="button"
              className={`sidebar-link${tab === item.id ? ' active' : ''}`}
              onClick={() => setTab(item.id)}
            >
              <AppIcon name={item.icon} size={18} />
              {t(item.label)}
            </button>
          ))}
        </aside>

        <div className="admin-content card card-padded">
          {tab === 'branding' && (
            <div className="form">
              <div className="field">
                <label>{t('admin.siteName')}</label>
                <input
                  className="input"
                  value={config.branding.siteName}
                  onChange={(e) => dispatch(updateConfig({ branding: { ...config.branding, siteName: e.target.value } }))}
                />
              </div>
              <div className="field">
                <label>{t('admin.logoLetter')}</label>
                <input
                  className="input"
                  maxLength={2}
                  value={config.branding.logoLetter}
                  onChange={(e) => dispatch(updateConfig({ branding: { ...config.branding, logoLetter: e.target.value } }))}
                />
              </div>
            </div>
          )}

          {tab === 'theme' && (
            <div className="form grid grid-2">
              {['tealPrimary', 'goldAccent', 'heroGradientStart', 'heroGradientEnd'].map((key) => (
                <div key={key} className="field">
                  <label>{key}</label>
                  <input
                    className="input"
                    type="color"
                    value={config.theme[key]}
                    onChange={(e) => dispatch(updateConfig({ theme: { ...config.theme, [key]: e.target.value } }))}
                  />
                </div>
              ))}
            </div>
          )}

          {tab === 'hero' && (
            <ListEditor
              items={config.hero.stats}
              onChange={(stats) => dispatch(updateConfig({ hero: { stats } }))}
              fields={[
                { key: 'value', label: t('admin.statValue'), default: '100+' },
                { key: 'labelKey', label: 'labelKey (home.stat1)', default: 'home.stat1' },
              ]}
            />
          )}

          {tab === 'products' && (
            <ListEditor
              items={config.products}
              onChange={(products) => dispatch(replaceList({ key: 'products', list: products }))}
              fields={[
                { key: 'title', label: t('common.productTitle') },
                { key: 'price', label: t('common.price'), type: 'number' },
                { key: 'category', label: 'category' },
                { key: 'seller', label: 'seller' },
                { key: 'imageUrl', label: 'imageUrl' },
                { key: 'rating', label: 'rating', type: 'number', default: 4.5 },
              ]}
            />
          )}

          {tab === 'clinics' && (
            <ListEditor
              items={config.clinics}
              onChange={(clinics) => dispatch(replaceList({ key: 'clinics', list: clinics }))}
              fields={[
                { key: 'name', label: t('common.name') },
                { key: 'address', label: t('common.address'), type: 'textarea' },
                { key: 'lat', label: 'lat', type: 'number' },
                { key: 'lng', label: 'lng', type: 'number' },
                { key: 'phone', label: t('common.phone') },
                { key: 'rating', label: 'rating', type: 'number' },
                { key: 'categories', label: 'categories (top,general)', array: true },
              ]}
            />
          )}

          {tab === 'courses' && (
            <ListEditor
              items={config.courses}
              onChange={(courses) => dispatch(replaceList({ key: 'courses', list: courses }))}
              fields={[
                { key: 'title', label: t('common.productTitle') },
                { key: 'instructor', label: 'instructor' },
                { key: 'youtubeId', label: 'YouTube ID' },
                { key: 'imageUrl', label: 'imageUrl' },
                { key: 'price', label: t('common.price'), type: 'number' },
                { key: 'lessons', label: t('common.lessons'), type: 'number' },
                { key: 'duration', label: t('common.hours') },
              ]}
            />
          )}

          {tab === 'technicians' && (
            <ListEditor
              items={config.technicians}
              onChange={(technicians) => dispatch(replaceList({ key: 'technicians', list: technicians }))}
              fields={[
                { key: 'name', label: t('common.name') },
                { key: 'specialty', label: 'specialty' },
                { key: 'location', label: t('common.location') },
                { key: 'phone', label: t('common.phone') },
                { key: 'priceFrom', label: t('common.price'), type: 'number' },
                { key: 'rating', label: 'rating', type: 'number' },
              ]}
            />
          )}

          {tab === 'security' && (
            <div className="form">
              <div className="field">
                <label>{t('admin.newPassword')}</label>
                <input
                  className="input"
                  type="password"
                  value={config.adminPassword}
                  onChange={(e) => dispatch(updateConfig({ adminPassword: e.target.value }))}
                />
              </div>
              <p className="card-meta">{t('admin.passwordHint')}</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
