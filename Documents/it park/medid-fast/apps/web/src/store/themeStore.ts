import { create } from 'zustand'

interface ThemeStore {
  dark: boolean
  toggle: () => void
}

export const useThemeStore = create<ThemeStore>((set) => ({
  dark: false,
  toggle: () => set((s) => {
    const next = !s.dark
    if (typeof window !== 'undefined') {
      document.documentElement.classList.toggle('dark', next)
      localStorage.setItem('fvv_theme', next ? 'dark' : 'light')
    }
    return { dark: next }
  }),
}))

export function initTheme() {
  if (typeof window === 'undefined') return
  const saved = localStorage.getItem('fvv_theme')
  const dark = saved === 'dark'
  document.documentElement.classList.toggle('dark', dark)
  useThemeStore.setState({ dark })
}
