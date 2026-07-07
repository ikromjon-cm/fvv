'use client'

import { useEffect, useRef } from 'react'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'

interface MarkerData {
  id: string
  coordinates: [number, number]
  severity: string
  label?: string
  radius?: number
  onClick?: () => void
}

interface LeafletMapProps {
  center: [number, number]
  zoom?: number
  markers?: MarkerData[]
  showRadius?: boolean
  className?: string
}

export function LeafletMap({ center, zoom = 14, markers = [], showRadius = true, className = '' }: LeafletMapProps) {
  const mapRef = useRef<HTMLDivElement>(null)
  const mapInstanceRef = useRef<L.Map | null>(null)
  const markersRef = useRef<Map<string, { marker: L.Marker; circle: L.Circle | null }>>(new Map())
  const aliveRef = useRef(true)

  useEffect(() => {
    const el = mapRef.current
    if (!el || mapInstanceRef.current) return

    aliveRef.current = true

    const map = L.map(el, {
      zoomControl: false,
      attributionControl: false,
      zoomAnimation: false,
      fadeAnimation: false,
      markerZoomAnimation: false,
    })

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
    }).addTo(map)

    map.whenReady(() => {
      if (!aliveRef.current) { map.remove(); return }
      map.setView(center, zoom, { animate: false })
      try { map.invalidateSize() } catch {}
    })

    mapInstanceRef.current = map

    return () => {
      aliveRef.current = false
      map.remove()
      mapInstanceRef.current = null
      markersRef.current.clear()
    }
  }, [])

  useEffect(() => {
    const map = mapInstanceRef.current
    if (!map || !aliveRef.current) return
    const timer = setTimeout(() => {
      if (!aliveRef.current) return
      try { map.invalidateSize() } catch {}
    }, 100)
    return () => clearTimeout(timer)
  }, [center, zoom, markers.length])

  useEffect(() => {
    const map = mapInstanceRef.current
    if (!map || !aliveRef.current) return
    const timer = setTimeout(() => {
      if (!aliveRef.current) return
      try { map.invalidateSize() } catch {}
    }, 300)
    return () => clearTimeout(timer)
  }, [])

  useEffect(() => {
    const map = mapInstanceRef.current
    if (!map || !aliveRef.current) return

    const getColor = (severity: string) => {
      switch (severity) {
        case 'CRITICAL': return '#DC2626'
        case 'HIGH': return '#F59E0B'
        case 'MEDIUM': return '#3B82F6'
        case 'LOW': return '#22C55E'
        default: return '#94A3B8'
      }
    }

    const getRadius = (severity: string) => {
      switch (severity) {
        case 'CRITICAL': return 300
        case 'HIGH': return 200
        case 'MEDIUM': return 100
        case 'LOW': return 50
        default: return 75
      }
    }

    const currentIds = new Set(markers.map((m) => m.id))
    const layerMap = markersRef.current

    layerMap.forEach((entry, id) => {
      if (!currentIds.has(id)) {
        if (entry.circle) entry.circle.remove()
        entry.marker.remove()
        layerMap.delete(id)
      }
    })

    markers.forEach((m) => {
      if (!aliveRef.current) return
      const existing = layerMap.get(m.id)
      const color = getColor(m.severity)

      if (!existing) {
        const icon = L.divIcon({
          html: `<div style="
            width:32px;height:32px;border-radius:50%;
            background:${color};border:2px solid white;
            display:flex;align-items:center;justify-content:center;
            box-shadow:0 2px 8px rgba(0,0,0,0.3);
            ${m.severity === 'CRITICAL' ? 'animation:pulse-emergency 1s ease-in-out infinite;' : ''}
          "><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg></div>
          <div style="
            position:absolute;top:100%;left:50%;transform:translateX(-50%);
            margin-top:4px;padding:2px 6px;border-radius:4px;
            background:rgba(0,0,0,0.6);color:white;
            font-size:10px;font-weight:600;white-space:nowrap;
          ">${m.label || m.id}</div>`,
          className: '',
          iconSize: [32, 32],
          iconAnchor: [16, 16],
        })

        const marker = L.marker(m.coordinates, { icon }).addTo(map)
        let circle: L.Circle | null = null
        if (showRadius) {
          circle = L.circle(m.coordinates, {
            radius: m.radius || getRadius(m.severity),
            color,
            fillColor: color,
            fillOpacity: 0.1,
            weight: 1.5,
            opacity: 0.3,
          }).addTo(map)
        }
        if (m.onClick) {
          marker.on('click', m.onClick)
          if (circle) circle.on('click', m.onClick)
        }
        layerMap.set(m.id, { marker, circle })
      } else {
        existing.marker.setLatLng(m.coordinates)
        existing.marker.off('click')
        if (m.onClick) existing.marker.on('click', m.onClick)
        if (existing.circle) {
          existing.circle.setLatLng(m.coordinates)
          existing.circle.setRadius(m.radius || getRadius(m.severity))
          existing.circle.setStyle({ color, fillColor: color })
          existing.circle.off('click')
          if (m.onClick) existing.circle.on('click', m.onClick)
        }
      }
    })
  }, [markers, showRadius])

  return <div ref={mapRef} className={`w-full h-full ${className}`} />
}
