export function googleMapsSearchUrl(lat, lng, address) {
  const query = address ? encodeURIComponent(address) : `${lat},${lng}`;
  return `https://www.google.com/maps/search/?api=1&query=${query}`;
}

export function googleMapsDirectionsUrl(lat, lng) {
  return `https://www.google.com/maps/dir/?api=1&destination=${lat},${lng}`;
}

export function openStreetMapEmbedUrl(lat, lng, delta = 0.04) {
  const minLng = lng - delta;
  const minLat = lat - delta;
  const maxLng = lng + delta;
  const maxLat = lat + delta;
  return `https://www.openstreetmap.org/export/embed.html?bbox=${minLng}%2C${minLat}%2C${maxLng}%2C${maxLat}&layer=mapnik&marker=${lat}%2C${lng}`;
}

export function yandexMapsUrl(lat, lng) {
  return `https://yandex.com/maps/?pt=${lng},${lat}&z=15&l=map`;
}

export function telUrl(phone) {
  return `tel:${phone.replace(/\s/g, '')}`;
}
