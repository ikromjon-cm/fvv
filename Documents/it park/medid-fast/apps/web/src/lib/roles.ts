export type Role = 'admin' | 'employee'

export const roleLabels: Record<Role, string> = {
  admin: 'Admin',
  employee: 'Xodim',
}

export const rolePages: Record<Role, string[]> = {
  admin: ['/', '/dashboard', '/map', '/mchs', '/sms', '/sos', '/iot', '/analytics', '/integration', '/demo', '/admin', '/profile', '/incidents', '/employees'],
  employee: ['/', '/dashboard', '/map', '/mchs', '/sms', '/sos', '/iot', '/analytics', '/integration', '/demo', '/profile', '/incidents'],
}

export const roleHome: Record<Role, string> = {
  admin: '/admin',
  employee: '/dashboard',
}

export const navItems: Record<Role, { href: string; label: string; icon: string }[]> = {
  admin: [
    { href: '/dashboard', label: 'Dashboard', icon: 'LayoutDashboard' },
    { href: '/map', label: 'Xarita', icon: 'Map' },
    { href: '/sos', label: 'SOS Murojaatlar', icon: 'AlertTriangle' },
    { href: '/employees', label: 'Xodimlar', icon: 'Users' },
    { href: '/mchs', label: 'MCHS', icon: 'Shield' },
    { href: '/incidents', label: 'Hodisalar', icon: 'Activity' },
    { href: '/sms', label: 'SMS / Telegram', icon: 'MessageSquare' },
    { href: '/iot', label: 'IoT Telemetriya', icon: 'Wifi' },
    { href: '/analytics', label: 'Analitika', icon: 'TrendingUp' },
    { href: '/integration', label: 'Integratsiya', icon: 'Cpu' },
    { href: '/demo', label: 'Demo', icon: 'Play' },
  ],
  employee: [
    { href: '/dashboard', label: 'Dashboard', icon: 'LayoutDashboard' },
    { href: '/map', label: 'Xarita', icon: 'Map' },
    { href: '/mchs', label: 'MCHS Inspeksiya', icon: 'Shield' },
    { href: '/sos', label: 'SOS', icon: 'AlertTriangle' },
    { href: '/sms', label: 'SMS', icon: 'MessageSquare' },
    { href: '/incidents', label: 'Hodisalar', icon: 'Activity' },
    { href: '/profile', label: 'Profil', icon: 'User' },
  ],
}

export function canAccess(role: Role | null, path: string): boolean {
  if (!role) return false
  const pages = rolePages[role]
  return pages.some((p) => path === p || path.startsWith(p + '/'))
}

export function getHomePage(role: Role): string {
  return roleHome[role]
}

export function getUserRole(): Role | null {
  if (typeof window === 'undefined') return null
  try {
    const stored = localStorage.getItem('fvv_user')
    if (!stored) return null
    const u = JSON.parse(stored)
    const roles: Role[] = ['admin', 'employee']
    return roles.includes(u.role) ? u.role : null
  } catch { return null }
}
