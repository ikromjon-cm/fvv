'use client'

import { useState, useEffect } from 'react'
import { MapPin, Star, Store } from 'lucide-react'
import dynamic from 'next/dynamic'
import { Navbar } from '@/components/navbar'
import { Footer } from '@/components/footer'
import { MobileBottomNav } from '@/components/mobile-bottom-nav'
import { cn } from '@/lib/utils'
import type { NearbySeller } from '@/types'

const MapContainer = dynamic(() => import('react-leaflet').then((m) => m.MapContainer), { ssr: false })
const TileLayer = dynamic(() => import('react-leaflet').then((m) => m.TileLayer), { ssr: false })
const Marker = dynamic(() => import('react-leaflet').then((m) => m.Marker), { ssr: false })
const Popup = dynamic(() => import('react-leaflet').then((m) => m.Popup), { ssr: false })

const mockSellers: NearbySeller[] = [
  { id: 1, company_name: 'Temur Darvozalar', lat: 41.3111, lng: 69.2797, distance_km: 1.2, rating: 4.8, product_count: 15 },
  { id: 2, company_name: 'Botir Eshiklar', lat: 41.3275, lng: 69.2640, distance_km: 2.5, rating: 4.5, product_count: 8 },
  { id: 3, company_name: 'Jasur Panjaralar', lat: 41.2950, lng: 69.3010, distance_km: 3.1, rating: 4.2, product_count: 12 },
  { id: 4, company_name: 'Akbar Darvoza Usta', lat: 41.3400, lng: 69.2500, distance_km: 4.0, rating: 4.7, product_count: 20 },
  { id: 5, company_name: 'Sardor Avtomatika', lat: 41.2800, lng: 69.3200, distance_km: 5.3, rating: 4.3, product_count: 6 },
  { id: 6, company_name: 'Shoxruh Metall Konstruksiya', lat: 41.3500, lng: 69.2100, distance_km: 6.8, rating: 4.0, product_count: 10 },
  { id: 7, company_name: 'Mirzo Temir Eshiklar', lat: 41.2600, lng: 69.2800, distance_km: 7.2, rating: 4.6, product_count: 18 },
  { id: 8, company_name: 'Bahrom Darvoza Ta\'miri', lat: 41.3700, lng: 69.2900, distance_km: 8.0, rating: 4.1, product_count: 5 },
]

const center: [number, number] = [41.3111, 69.2797]

function createIcon(selected: boolean, L: any) {
  return L.divIcon({
    className: '',
    html: `<div style="
      background: ${selected ? '#f59e0b' : '#fff'};
      color: ${selected ? '#fff' : '#333'};
      border: 2px solid #f59e0b;
      border-radius: 50%;
      width: 36px;
      height: 36px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 700;
      font-size: 12px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.15);
      cursor: pointer;
    ">S</div>`,
    iconSize: [36, 36],
    iconAnchor: [18, 18],
  })
}

function MapContent({ selectedSeller, onSelect }: {
  selectedSeller: NearbySeller | null
  onSelect: (s: NearbySeller) => void
}) {
  const [icons, setIcons] = useState<{ active: any; inactive: any } | null>(null)

  useEffect(() => {
    import('leaflet').then((L) => {
      setIcons({
        active: createIcon(true, L),
        inactive: createIcon(false, L),
      })
    })
  }, [])

  if (!icons) return null

  return (
    <>
      <TileLayer
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      />
      {mockSellers.map((seller) => (
        <Marker
          key={seller.id}
          position={[seller.lat, seller.lng]}
          icon={selectedSeller?.id === seller.id ? icons.active : icons.inactive}
          eventHandlers={{ click: () => onSelect(seller) }}
        >
          <Popup>
            <div className="text-center min-w-[160px]">
              <h3 className="font-semibold text-sm">{seller.company_name}</h3>
              <div className="flex items-center justify-center gap-1 mt-1">
                <Star className="h-3 w-3 fill-amber-400 text-amber-400 inline" />
                <span className="text-xs font-medium">{seller.rating.toFixed(1)}</span>
              </div>
              <p className="text-xs text-gray-500 mt-1">
                {seller.product_count} ta mahsulot · {seller.distance_km} km
              </p>
            </div>
          </Popup>
        </Marker>
      ))}
    </>
  )
}

export default function NearbyPage() {
  const [selectedSeller, setSelectedSeller] = useState<NearbySeller | null>(null)
  const [hoveredId, setHoveredId] = useState<number | null>(null)
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Navbar />
      <main className="flex-1 pb-20 lg:pb-0">
        <div className="mx-auto max-w-7xl">
          <div className="flex flex-col lg:flex-row h-[calc(100vh-8rem)]">
            {/* Sidebar */}
            <div className="lg:w-96 bg-white border-r border-gray-100 flex flex-col shrink-0">
              <div className="p-4 border-b border-gray-100">
                <h1 className="text-lg font-bold text-gray-900">Yaqin atrofdagi sotuvchilar</h1>
                <p className="text-sm text-gray-500 mt-1">{mockSellers.length} ta sotuvchi topildi</p>
              </div>
              <div className="flex-1 overflow-y-auto">
                {mockSellers
                  .sort((a, b) => a.distance_km - b.distance_km)
                  .map((seller) => (
                    <button
                      key={seller.id}
                      onMouseEnter={() => setHoveredId(seller.id)}
                      onMouseLeave={() => setHoveredId(null)}
                      onClick={() => setSelectedSeller(seller)}
                      className={cn(
                        'w-full text-left p-4 border-b border-gray-50 transition-colors hover:bg-gray-50',
                        selectedSeller?.id === seller.id && 'bg-primary/5',
                        hoveredId === seller.id && 'bg-gray-50',
                      )}
                    >
                      <div className="flex items-start gap-3">
                        <div className="shrink-0 w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center">
                          <Store className="h-5 w-5 text-primary" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <h3 className="text-sm font-semibold text-gray-900 truncate">
                            {seller.company_name}
                          </h3>
                          <div className="flex items-center gap-2 mt-1">
                            <div className="flex items-center gap-0.5">
                              <Star className="h-3 w-3 fill-amber-400 text-amber-400" />
                              <span className="text-xs font-medium text-gray-700">{seller.rating.toFixed(1)}</span>
                            </div>
                            <span className="text-xs text-gray-400">|</span>
                            <span className="text-xs text-gray-500">{seller.product_count} ta mahsulot</span>
                          </div>
                          <div className="flex items-center gap-1 mt-1.5">
                            <MapPin className="h-3 w-3 text-gray-400" />
                            <span className="text-xs text-gray-400">{seller.distance_km} km uzoqlikda</span>
                          </div>
                        </div>
                      </div>
                    </button>
                  ))}
              </div>
            </div>

            {/* Map */}
            <div className="flex-1 relative">
              {mounted && (
                <link
                  rel="stylesheet"
                  href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
                  integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
                  crossOrigin=""
                />
              )}
              {mounted ? (
                <MapContainer center={center} zoom={13} className="w-full h-full z-0" scrollWheelZoom={true}>
                  <MapContent selectedSeller={selectedSeller} onSelect={setSelectedSeller} />
                </MapContainer>
              ) : (
                <div className="w-full h-full flex items-center justify-center bg-gray-100">
                  <div className="animate-spin h-8 w-8 border-4 border-primary border-t-transparent rounded-full" />
                </div>
              )}
            </div>
          </div>
        </div>
      </main>
      <Footer />
      <MobileBottomNav />
    </div>
  )
}
