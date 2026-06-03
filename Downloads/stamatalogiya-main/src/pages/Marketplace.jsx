import { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { marketplaceCategories } from '../data/mockData';
import { setCategory, setSearchQuery, postAd } from '../store/slices/marketplaceSlice';
import ProductCard from '../components/ui/ProductCard';
import PremiumGate from '../components/layout/PremiumGate';
import { useTranslation } from '../hooks/useTranslation';
import AppIcon from '../components/ui/AppIcon';

const condKeys = ['condNew', 'condExcellent', 'condLikeNew', 'condGood'];

export default function Marketplace() {
  const dispatch = useDispatch();
  const { t } = useTranslation();
  const { products, ads, activeCategory, searchQuery } = useSelector((state) => state.marketplace);
  const [showAdForm, setShowAdForm] = useState(false);
  const [adForm, setAdForm] = useState({ title: '', price: '', location: '', condition: 'New' });

  const filtered = products.filter((p) => {
    const matchCat = activeCategory === 'all' || p.category === activeCategory;
    const matchSearch = !searchQuery || p.title.toLowerCase().includes(searchQuery.toLowerCase());
    return matchCat && matchSearch;
  });

  const handlePostAd = (e) => {
    e.preventDefault();
    dispatch(postAd({
      ...adForm,
      price: Number(adForm.price),
      author: t('common.you'),
      condition: adForm.condition,
    }));
    setAdForm({ title: '', price: '', location: '', condition: 'New' });
    setShowAdForm(false);
  };

  return (
    <div className="page">
      <div className="section-header">
        <div>
          <span className="label">{t('marketplace.label')}</span>
          <h1 className="title">{t('marketplace.title')}</h1>
          <p className="subtitle">{t('marketplace.subtitle')}</p>
        </div>
        <PremiumGate message={t('marketplace.registerPost')}>
          <button type="button" className="btn btn-gold" onClick={() => setShowAdForm(true)}>
            {t('marketplace.postAdBtn')}
          </button>
        </PremiumGate>
      </div>

      <div className="toolbar">
        <div className="search">
          <AppIcon name="search" size={18} className="search-icon" />
          <input
            type="search"
            placeholder={t('common.search')}
            value={searchQuery}
            onChange={(e) => dispatch(setSearchQuery(e.target.value))}
          />
        </div>
        <div className="filter">
          <button
            type="button"
            className={`chip${activeCategory === 'all' ? ' active' : ''}`}
            onClick={() => dispatch(setCategory('all'))}
          >
            {t('common.all')}
          </button>
          {marketplaceCategories.map((cat) => (
            <button
              key={cat.id}
              type="button"
              className={`chip${activeCategory === cat.id ? ' active' : ''}`}
              onClick={() => dispatch(setCategory(cat.id))}
            >
              {t(`categories.${cat.id}`)}
            </button>
          ))}
        </div>
      </div>

      <section className="section">
        <h2 className="title section-title">{t('common.products')}</h2>
        <div className="grid grid-3 grid-products">
          {filtered.map((product) => (
            <ProductCard key={product.id} product={product} />
          ))}
        </div>
        {filtered.length === 0 && <div className="empty">{t('common.noResults')}</div>}
      </section>

      <section className="section">
        <div className="section-header">
          <h2 className="title section-title">{t('common.adBoard')}</h2>
          <span className="badge badge-teal">{ads.length} {t('common.listings')}</span>
        </div>
        <div className="grid grid-2 grid-marketplace-ads">
          {ads.map((ad) => (
            <article key={ad.id} className="card card-padded">
              <h3 className="card-title">{ad.title}</h3>
              <p className="card-meta">{ad.location} &middot; {ad.author} &middot; {ad.date}</p>
              <div className="card-row">
                <span className="price">${ad.price.toLocaleString()}</span>
                <span className="badge badge-success">{ad.condition}</span>
              </div>
            </article>
          ))}
        </div>
      </section>

      {showAdForm && (
        <div className="modal-overlay" onClick={() => setShowAdForm(false)}>
          <div className="modal" onClick={(e) => e.stopPropagation()} role="dialog" aria-modal="true">
            <div className="modal-header">
              <h2 className="title">{t('common.postAdTitle')}</h2>
              <p className="subtitle">{t('marketplace.postAdDesc')}</p>
            </div>
            <div className="modal-body">
              <form className="form" onSubmit={handlePostAd}>
                <div className="field">
                  <label>{t('common.productTitle')}</label>
                  <input className="input" required value={adForm.title} onChange={(e) => setAdForm({ ...adForm, title: e.target.value })} />
                </div>
                <div className="grid grid-2">
                  <div className="field">
                    <label>{t('common.price')}</label>
                    <input className="input" type="number" required value={adForm.price} onChange={(e) => setAdForm({ ...adForm, price: e.target.value })} />
                  </div>
                  <div className="field">
                    <label>{t('common.location')}</label>
                    <input className="input" required value={adForm.location} onChange={(e) => setAdForm({ ...adForm, location: e.target.value })} />
                  </div>
                </div>
                <div className="field">
                  <label>{t('common.condition')}</label>
                  <select className="select" value={adForm.condition} onChange={(e) => setAdForm({ ...adForm, condition: e.target.value })}>
                    {condKeys.map((key, i) => (
                      <option key={key} value={['New', 'Excellent', 'Like New', 'Good'][i]}>{t(`common.${key}`)}</option>
                    ))}
                  </select>
                </div>
                <button type="submit" className="btn btn-primary" style={{ width: '100%' }}>{t('common.publish')}</button>
              </form>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
