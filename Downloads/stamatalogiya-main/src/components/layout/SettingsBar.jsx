import { useDispatch, useSelector } from 'react-redux';
import { languages } from '../../i18n/translations';
import { setLanguage, setTheme } from '../../store/slices/settingsSlice';
import { useTranslation } from '../../hooks/useTranslation';
import AppIcon from '../ui/AppIcon';

export default function SettingsBar({ compact = false }) {
  const dispatch = useDispatch();
  const { theme, language } = useSelector((state) => state.settings);
  const { t } = useTranslation();

  return (
    <div className={`settings${compact ? ' settings-compact' : ''}`}>
      <div className="settings-group" role="group" aria-label={t('common.language')}>
        {!compact && <span className="settings-label">{t('common.language')}</span>}
        <div className="lang-switch">
          {languages.map((lang) => (
            <button
              key={lang.id}
              type="button"
              className={`lang-btn${language === lang.id ? ' active' : ''}`}
              onClick={() => dispatch(setLanguage(lang.id))}
              aria-pressed={language === lang.id}
            >
              {lang.id.toUpperCase()}
            </button>
          ))}
        </div>
      </div>
      <div className="settings-group" role="group" aria-label={t('common.theme')}>
        {!compact && <span className="settings-label">{t('common.theme')}</span>}
        <button
          type="button"
          className="theme-toggle"
          onClick={() => dispatch(setTheme(theme === 'light' ? 'dark' : 'light'))}
          aria-label={theme === 'light' ? t('common.darkMode') : t('common.lightMode')}
        >
          <AppIcon name={theme === 'light' ? 'sun' : 'moon'} size={16} className="theme-icon-svg" />
          <span className="theme-text">{theme === 'light' ? t('common.darkMode') : t('common.lightMode')}</span>
        </button>
      </div>
    </div>
  );
}
