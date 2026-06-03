import { useState } from 'react';
import AppIcon from '../ui/AppIcon';
import clinicsData from '../../data/uzClinicsMock';

export default function Map() {
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState('all');

  const regions = Object.values(clinicsData.reduce((acc, clinic) => {
    const region = clinic.region;
    if (!acc[region]) {
      acc[region] = { region, count: 0, types: new Set(), cities: new Set() };
    }
    acc[region].count += 1;
    clinic.types.forEach(type => acc[region].types.add(type));
    acc[region].cities.add(clinic.city);
    return acc;
  }, {})).map(item => ({
    region: item.region,
    count: item.count,
    types: [...item.types],
    cities: [...item.cities],
  }));

  const filterTest = {
    all: () => true,
    pediatric: types => types.includes('Pediatric'),
    women: types => types.includes('Women'),
    '24h': types => types.includes('24/7'),
  };

  const typeText = (types) => types.map((type) => {
    if (type === 'Pediatric') return '👶 Bolalar';
    if (type === 'Women') return '👩 Ayollar';
    if (type === '24/7') return '⏰ 24/7';
    if (type === 'Implantology') return '🦷 Implant';
    if (type === 'Cosmetic') return '✨ Kosmetik';
    if (type === 'Surgery') return '🔧 Jarrohlik';
    if (type === 'Prosthetics') return '🔩 Protez';
    if (type === 'Radiology') return '📡 Radiologiya';
    if (type === 'Endodontics') return '🧬 Endodontiya';
    return type;
  }).join(' · ');

  const filtered = regions.filter(region => {
    const searchText = `${region.region} ${region.cities.join(' ')}`.toLowerCase();
    const matchSearch = searchText.includes(search.toLowerCase());
    const matchFilter = filterTest[filter](region.types);
    return matchSearch && matchFilter;
  });

  return (
    <section className="section map">
      <div className="inner">
        <div className="head">
          <h2 className="title">O'ZBEKISTONNING STOMATOLOGIK XARITASI</h2>
          <p className="subtitle">Real vaqt ma'lumotlar bilan eng yaqin klinikani toping</p>
        </div>

        <div className="controls">
          <div className="search">
            <AppIcon name="search" size={18} className="icon" />
            <input
              type="text"
              placeholder="Viloyat yoki shaharni qidirish..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="field"
            />
          </div>
          <div className="filters">
            <button
              type="button"
              className={`chip${filter === 'all' ? ' active' : ''}`}
              onClick={() => setFilter('all')}
            >
              Barchasi
            </button>
            <button
              type="button"
              className={`chip${filter === 'pediatric' ? ' active' : ''}`}
              onClick={() => setFilter('pediatric')}
            >
              Bolalar
            </button>
            <button
              type="button"
              className={`chip${filter === 'women' ? ' active' : ''}`}
              onClick={() => setFilter('women')}
            >
              Ayollar
            </button>
            <button
              type="button"
              className={`chip${filter === '24h' ? ' active' : ''}`}
              onClick={() => setFilter('24h')}
            >
              24/7
            </button>
          </div>
        </div>

        <div className="grid">
          {filtered.map((clinic, i) => (
            <div key={i} className="place">
              <div className="header">
                <h3 className="place-name">{clinic.region}</h3>
                <span className="count">{clinic.count}</span>
              </div>
              <p className="type">{typeText(clinic.types)}</p>
              <button type="button" className="action">Klinikalarni ko'rish</button>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
