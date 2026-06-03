import { useDispatch, useSelector } from 'react-redux';
import { openRegistration } from '../../store/slices/authSlice';
import { useTranslation } from '../../hooks/useTranslation';
import AppIcon from '../ui/AppIcon';

export default function PremiumGate({ children, message }) {
  const { isRegistered } = useSelector((state) => state.auth);
  const dispatch = useDispatch();
  const { t } = useTranslation();
  const text = message || t('common.registerToAccess');

  if (isRegistered) return children;

  return (
    <div className="premium-gate blurred">
      {children}
      <div className="gate-overlay">
        <div className="gate-icon">
          <AppIcon name="lock" size={24} />
        </div>
        <p className="subtitle" style={{ textAlign: 'center', maxWidth: 280 }}>{text}</p>
        <button type="button" className="btn btn-gold" onClick={() => dispatch(openRegistration())}>
          {t('common.registerNow')}
        </button>
      </div>
    </div>
  );
}
