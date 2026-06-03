import { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { useLocation } from 'react-router-dom';
import { technicians } from '../data/mockData';
import { updateDraft, submitOrder } from '../store/slices/ordersSlice';
import PremiumGate from '../components/layout/PremiumGate';
import { useTranslation } from '../hooks/useTranslation';

const statusMap = {
  'Pending Review': 'orderStatus.pending',
  'In Production': 'orderStatus.production',
  Shipped: 'orderStatus.shipped',
};

const statusClass = {
  'Pending Review': 'status-pending',
  'In Production': 'status-production',
  Shipped: 'status-shipped',
};

const orderTypeKeys = ['zirconia', 'emax', 'bridge', 'denture', 'abutment'];

export default function Orders() {
  const dispatch = useDispatch();
  const location = useLocation();
  const { t } = useTranslation();
  const { orders, draftOrder } = useSelector((state) => state.orders);

  useEffect(() => {
    if (location.state?.technicianId) {
      dispatch(updateDraft({
        technicianId: location.state.technicianId,
        technician: location.state.technicianName,
      }));
    }
  }, [location.state, dispatch]);

  const handleSubmit = (e) => {
    e.preventDefault();
    const tech = technicians.find((item) => item.id === draftOrder.technicianId);
    dispatch(submitOrder({
      patient: draftOrder.patient,
      type: draftOrder.type,
      description: draftOrder.description,
      technician: tech?.name || draftOrder.technician || t('common.unassigned'),
    }));
  };

  return (
    <div className="page">
      <div className="section-header">
        <div>
          <span className="label">{t('orders.label')}</span>
          <h1 className="title">{t('orders.title')}</h1>
          <p className="subtitle">{t('orders.subtitle')}</p>
        </div>
      </div>

      <PremiumGate message={t('orders.registerPlace')}>
        <div className="grid grid-2" style={{ alignItems: 'start' }}>
          <form className="order-form form" onSubmit={handleSubmit}>
            <h2 className="title section-title">{t('common.newOrder')}</h2>
            <div className="field">
              <label>{t('common.patient')}</label>
              <input
                className="input"
                required
                value={draftOrder.patient}
                onChange={(e) => dispatch(updateDraft({ patient: e.target.value }))}
              />
            </div>
            <div className="field">
              <label>{t('common.workType')}</label>
              <select
                className="select"
                required
                value={draftOrder.type}
                onChange={(e) => dispatch(updateDraft({ type: e.target.value }))}
              >
                <option value="">{t('common.selectType')}</option>
                {orderTypeKeys.map((key) => (
                  <option key={key} value={t(`orderTypes.${key}`)}>{t(`orderTypes.${key}`)}</option>
                ))}
              </select>
            </div>
            <div className="field">
              <label>{t('common.technician')}</label>
              <select
                className="select"
                value={draftOrder.technicianId || ''}
                onChange={(e) => {
                  const tech = technicians.find((item) => item.id === Number(e.target.value));
                  dispatch(updateDraft({ technicianId: Number(e.target.value), technician: tech?.name }));
                }}
              >
                <option value="">{t('common.selectTechnician')}</option>
                {technicians.map((item) => (
                  <option key={item.id} value={item.id}>{item.name} — {item.specialty}</option>
                ))}
              </select>
            </div>
            <div className="field">
              <label>{t('common.description')}</label>
              <textarea
                className="textarea"
                required
                value={draftOrder.description}
                onChange={(e) => dispatch(updateDraft({ description: e.target.value }))}
                placeholder={t('common.descPlaceholder')}
              />
            </div>
            <div className="upload">
              <span style={{ fontSize: '1.5rem' }} aria-hidden="true">&#128193;</span>
              <p>{t('common.uploadFiles')}</p>
              <p className="card-meta">{t('common.uploadHint')}</p>
            </div>
            <button type="submit" className="btn btn-primary" style={{ width: '100%' }}>
              {t('common.submitOrder')}
            </button>
          </form>

          <div>
            <h2 className="title section-title">{t('common.activeOrders')}</h2>
            <div className="table-wrap" tabIndex={0} role="region" aria-label={t('common.activeOrders')}>
              <table className="table">
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>{t('common.patient')}</th>
                    <th>{t('common.type')}</th>
                    <th>{t('common.technician')}</th>
                    <th>{t('common.status')}</th>
                  </tr>
                </thead>
                <tbody>
                  {orders.map((order) => (
                    <tr key={order.id}>
                      <td><strong>{order.id}</strong></td>
                      <td>{order.patient}</td>
                      <td>{order.type}</td>
                      <td>{order.technician}</td>
                      <td>
                        <span className={`status ${statusClass[order.status] || 'status-pending'}`}>
                          {t(statusMap[order.status] || 'orderStatus.pending')}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </PremiumGate>
    </div>
  );
}
