import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  ...(process.env.EXPORT ? { output: 'export' as const, images: { unoptimized: true } } : {}),
  transpilePackages: [
    '@medid/types', '@medid/constants', '@medid/config',
    '@medid/validators', '@medid/api', '@medid/ui', '@medid/utils'
  ],
}

export default nextConfig
