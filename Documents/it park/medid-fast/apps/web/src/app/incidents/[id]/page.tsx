import { IncidentDetailClient } from './client'

export async function generateStaticParams() {
  return [
    { id: 'demo-001' }, { id: 'demo-002' }, { id: 'demo-003' },
  ]
}

export default function Page() {
  return <IncidentDetailClient />
}
