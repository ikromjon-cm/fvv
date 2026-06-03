import { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { registerUser, closeRegistration } from '../../store/slices/authSlice';
import { roles } from '../../data/mockData';
import { useTranslation } from '../../hooks/useTranslation';

const initialForm = {
  firstName: '',
  lastName: '',
  phone: '',
  clinicName: '',
  address: '',
  role: '',
};

export default function RegistrationModal() {
  const dispatch = useDispatch();
  const { t } = useTranslation();
  const { showRegistration, isRegistered } = useSelector((state) => state.auth);
  const [form, setForm] = useState(initialForm);
  const [errors, setErrors] = useState({});

  if (!showRegistration) return null;

  const update = (field, value) => {
    setForm((prev) => ({ ...prev, [field]: value }));
    setErrors((prev) => ({ ...prev, [field]: '' }));
  };

  const validate = () => {
    const next = {};
    if (!form.firstName.trim()) next.firstName = t('common.required');
    if (!form.lastName.trim()) next.lastName = t('common.required');
    if (!form.phone.trim()) next.phone = t('common.required');
    if (!form.clinicName.trim()) next.clinicName = t('common.required');
    if (!form.address.trim()) next.address = t('common.required');
    if (!form.role) next.role = t('common.selectRole');
    setErrors(next);
    return Object.keys(next).length === 0;
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!validate()) return;
    dispatch(registerUser({
      ...form,
      registeredAt: new Date().toISOString(),
    }));
    setForm(initialForm);
  };

  const handleClose = () => {
    if (isRegistered) dispatch(closeRegistration());
  };

  return (
    <div className="modal-overlay" role="dialog" aria-modal="true" aria-labelledby="register-title">
      <div className="modal-wrap">
        {isRegistered && (
          <button type="button" className="modal-close" onClick={handleClose} aria-label={t('common.close')}>
            &times;
          </button>
        )}
        <div className="modal">
          <div className="modal-header">
            <span className="label">{t('common.welcome')}</span>
            <h2 id="register-title" className="title">{t('common.completeProfile')}</h2>
            <p className="subtitle">{t('common.registerDesc')}</p>
          </div>
          <div className="modal-body">
            <form className="form" onSubmit={handleSubmit}>
              <div className="grid grid-2">
                <div className="field">
                  <label htmlFor="firstName">{t('common.firstName')}</label>
                  <input
                    id="firstName"
                    className="input"
                    value={form.firstName}
                    onChange={(e) => update('firstName', e.target.value)}
                  />
                  {errors.firstName && <span className="field-error">{errors.firstName}</span>}
                </div>
                <div className="field">
                  <label htmlFor="lastName">{t('common.lastName')}</label>
                  <input
                    id="lastName"
                    className="input"
                    value={form.lastName}
                    onChange={(e) => update('lastName', e.target.value)}
                  />
                  {errors.lastName && <span className="field-error">{errors.lastName}</span>}
                </div>
              </div>
              <div className="field">
                <label htmlFor="phone">{t('common.phoneNumber')}</label>
                <input
                  id="phone"
                  className="input"
                  type="tel"
                  value={form.phone}
                  onChange={(e) => update('phone', e.target.value)}
                  placeholder="+998 90 000 00 00"
                />
                {errors.phone && <span className="field-error">{errors.phone}</span>}
              </div>
              <div className="field">
                <label htmlFor="clinicName">{t('common.clinicName')}</label>
                <input
                  id="clinicName"
                  className="input"
                  value={form.clinicName}
                  onChange={(e) => update('clinicName', e.target.value)}
                />
                {errors.clinicName && <span className="field-error">{errors.clinicName}</span>}
              </div>
              <div className="field">
                <label htmlFor="address">{t('common.address')}</label>
                <input
                  id="address"
                  className="input"
                  value={form.address}
                  onChange={(e) => update('address', e.target.value)}
                />
                {errors.address && <span className="field-error">{errors.address}</span>}
              </div>
              <div className="field">
                <label>{t('common.roleSelection')}</label>
                <div className="roles">
                  {roles.map((role) => (
                    <button
                      key={role.id}
                      type="button"
                      className={`role${form.role === role.id ? ' selected' : ''}`}
                      onClick={() => update('role', role.id)}
                    >
                      <div className="role-name">{t(`roles.${role.id}`)}</div>
                    </button>
                  ))}
                </div>
                {errors.role && <span className="field-error">{errors.role}</span>}
              </div>
              <button type="submit" className="btn btn-gold" style={{ width: '100%' }}>
                {t('common.unlock')}
              </button>
            </form>
          </div>
        </div>
      </div>
    </div>
  );
}
