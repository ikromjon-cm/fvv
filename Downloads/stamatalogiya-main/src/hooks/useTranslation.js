import { useCallback } from 'react';
import { useSelector } from 'react-redux';
import { locales } from '../i18n/translations';

export function useTranslation() {
  const language = useSelector((state) => state.settings.language);

  const t = useCallback(
    (key, fallback) => {
      const dict = locales[language] || locales.uz;
      return dict[key] ?? fallback ?? key;
    },
    [language],
  );

  return { t, language };
}
