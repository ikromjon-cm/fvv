import { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { initSettings } from '../../store/slices/settingsSlice';

function syncViewport() {
  const root = document.documentElement;
  const w = window.innerWidth;
  const h = window.innerHeight;
  root.style.setProperty('--viewport-width', `${w}px`);
  root.style.setProperty('--viewport-height', `${h}px`);
  root.style.setProperty('--viewport-min', `${Math.min(w, h)}px`);
  root.dataset.viewport = w < 360 ? 'xs' : w < 480 ? 'sm' : w < 768 ? 'md' : 'lg';
}

function applyCustomTheme(theme) {
  if (!theme) return;
  const root = document.documentElement;
  if (theme.tealPrimary) {
    root.style.setProperty('--teal-600', theme.tealPrimary);
    root.style.setProperty('--teal-500', theme.tealPrimary);
    root.style.setProperty('--teal-700', theme.tealPrimary);
  }
  if (theme.goldAccent) {
    root.style.setProperty('--gold', theme.goldAccent);
    root.style.setProperty('--gold-light', theme.goldAccent);
  }
  if (theme.heroGradientStart && theme.heroGradientEnd) {
    root.style.setProperty(
      '--hero-gradient',
      `linear-gradient(135deg, ${theme.heroGradientStart} 0%, ${theme.heroGradientEnd} 55%, var(--slate-800) 100%)`,
    );
  }
}

export default function ThemeInit() {
  const dispatch = useDispatch();
  const themeColors = useSelector((s) => s.siteConfig.config.theme);

  useEffect(() => {
    dispatch(initSettings());
    syncViewport();
    applyCustomTheme(themeColors);

    const onResize = () => syncViewport();
    window.addEventListener('resize', onResize, { passive: true });
    window.addEventListener('orientationchange', onResize, { passive: true });
    if (window.visualViewport) {
      window.visualViewport.addEventListener('resize', onResize, { passive: true });
    }

    return () => {
      window.removeEventListener('resize', onResize);
      window.removeEventListener('orientationchange', onResize);
      if (window.visualViewport) {
        window.visualViewport.removeEventListener('resize', onResize);
      }
    };
  }, [dispatch, themeColors]);

  return null;
}
