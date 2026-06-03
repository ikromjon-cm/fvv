import { useState, useEffect, useMemo } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { clinicFilters } from '../data/mockData';
import { setFilter, selectClinic, createBooking, clearBooking } from '../store/slices/clinicsSlice';
import { useTranslation } from '../hooks/useTranslation';
import AppIcon from '../components/ui/AppIcon';
import Rating from '../components/ui/Rating';
import {
  googleMapsSearchUrl,
  googleMapsDirectionsUrl,
  openStreetMapEmbedUrl,
  telUrl,
} from '../utils/maps';

export default function Clinics() {
  const dispatch = useDispatch();
  const { t } = useTranslation();
  const { clinics, activeFilter, selectedClinic, booking } = useSelector((state) => state.clinics);
  const [bookingForm, setBookingForm] = useState({ name: '', phone: '', date: '', time: '' });
  const [location, setLocation] = useState(null);
  const [locationStatus, setLocationStatus] = useState('');

  const computeDistance = (lat1, lng1, lat2, lng2) => {
    const toRad = (value) => (value * Math.PI) / 180;
    const R = 6371;
    const dLat = toRad(lat2 - lat1);
    const dLng = toRad(lng2 - lng1);
    const a = Math.sin(dLat / 2) ** 2 + Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
    return Number((R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))).toFixed(1));
  };

  const detectLocation = () => {
    if (!navigator.geolocation) {
      setLocationStatus('Brauzeringiz geolokatsiyani qo`llamaydi');
      return;
    }
    setLocationStatus('Joylashuvingiz aniqlanmoqda...');
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        setLocation({ lat: pos.coords.latitude, lng: pos.coords.longitude });
        setLocationStatus('Sizning joylashuvingiz aniqlandi');
      },
      () => {
        setLocationStatus('Joylashuvingizni topib bo`lmadi');
      },
      { enableHighAccuracy: true, timeout: 10000, maximumAge: 60000 },
    );
  };

  useEffect(() => {
    detectLocation();
  }, []);

  const clinicList = useMemo(() => clinics.map((clinic) => {
    const categories = clinic.categories || clinic.types?.map((type) => {
      if (type === 'Pediatric') return 'pediatric';
      if (type === 'Women') return 'women';
      if (type === '24/7' || type === 'Emergency') return 'emergency';
      return 'general';
    }) || [];
    const open24 = (clinic.open24 ?? false) || clinic.hours === '24/7' || clinic.types?.includes('24/7');
    const distance = location
      ? computeDistance(location.lat, location.lng, clinic.lat, clinic.lng)
      : clinic.distance ?? 0;
    return { ...clinic, categories, open24, distance };
  }), [clinics, location]);

  const filtered = clinicList.filter((c) => {
    if (activeFilter === 'all') return true;
    if (activeFilter === 'emergency') return c.open24;
    return c.categories.includes(activeFilter);
  });

  useEffect(() => {
    if (location && !selectedClinic && filtered.length) {
      dispatch(selectClinic(filtered[0]));
    }
  }, [location, selectedClinic, filtered, dispatch]);

  const mapClinic = selectedClinic || filtered[0];
  const mapUrl = mapClinic
    ? openStreetMapEmbedUrl(mapClinic.lat, mapClinic.lng)
    : openStreetMapEmbedUrl(41.2995, 69.2401);

  const handleBooking = (e) => {
    e.preventDefault();
    dispatch(createBooking({ clinic: selectedClinic, ...bookingForm }));
    setBookingForm({ name: '', phone: '', date: '', time: '' });
  };

  return (
    <div className="page">
      <div className="section-header">
        <div>
          <span className="label">{t('clinics.label')}</span>
          <h1 className="title">{t('clinics.title')}</h1>
          <p className="subtitle">{t('clinics.subtitle')}</p>
        </div>
      </div>

      <div className="filter" style={{ marginBottom: '1.5rem' }}>
        {clinicFilters.map((f) => (
          <button
            key={f.id}
            type="button"
            className={`chip${activeFilter === f.id ? ' active' : ''}`}
            onClick={() => dispatch(setFilter(f.id))}
          >
            {t(`clinicFilters.${f.id}`)}
          </button>
        ))}
      </div>

      <div className="grid grid-2" style={{ alignItems: 'start' }}>
        <div>
          <div className="map map-live">
            <iframe
              title={mapClinic?.name || t('clinics.title')}
              src={mapUrl}
              className="map-iframe"
              loading="lazy"
              referrerPolicy="no-referrer-when-downgrade"
            />
            <div className="map-label">
              <span className="badge badge-gold">
                <AppIcon name="map" size={14} />
                {location ? t('common.geolocationActive') : 'Geolokatsiya tayyor emas'}
              </span>
              <button type="button" className="btn btn-ghost btn-sm" onClick={detectLocation} style={{ marginLeft: '12px' }}>
                {location ? 'Joylashuvni yangilash' : 'Mening manzilimni aniqlash'}
              </button>
              {locationStatus && <div className="card-meta" style={{ marginTop: '0.75rem' }}>{locationStatus}</div>}
            </div>
          </div>

          {mapClinic && (
            <div className="map-actions">
              <a
                href={googleMapsSearchUrl(mapClinic.lat, mapClinic.lng, mapClinic.address)}
                target="_blank"
                rel="noopener noreferrer"
                className="btn btn-outline btn-sm"
              >
                <AppIcon name="external" size={16} />
                Google Maps
              </a>
              <a
                href={googleMapsDirectionsUrl(mapClinic.lat, mapClinic.lng)}
                target="_blank"
                rel="noopener noreferrer"
                className="btn btn-primary btn-sm"
              >
                <AppIcon name="directions" size={16} />
                {t('common.getDirections')}
              </a>
            </div>
          )}

          <div className="clinic-list" style={{ marginTop: '1.5rem' }}>
            {filtered.map((clinic) => (
              <article
                key={clinic.id}
                className={`clinic-item${selectedClinic?.id === clinic.id ? ' selected' : ''}`}
                onClick={() => dispatch(selectClinic(clinic))}
                onKeyDown={(e) => e.key === 'Enter' && dispatch(selectClinic(clinic))}
                role="button"
                tabIndex={0}
              >
                <div style={{ flex: 1 }}>
                  <h3 className="card-title">{clinic.name}</h3>
                  <p className="card-meta clinic-address">
                    <AppIcon name="location" size={14} />
                    <a
                      href={googleMapsSearchUrl(clinic.lat, clinic.lng, clinic.address)}
                      target="_blank"
                      rel="noopener noreferrer"
                      onClick={(e) => e.stopPropagation()}
                    >
                      {clinic.address}
                    </a>
                  </p>
                  <div className="tech-meta">
                    <Rating value={clinic.rating} />
                    <span className="card-meta">{clinic.distance} {t('common.kmAway')}</span>
                    {clinic.open24 && <span className="badge badge-warning">{t('common.open24')}</span>}
                  </div>
                  <a
                    href={telUrl(clinic.phone)}
                    className="clinic-phone"
                    onClick={(e) => e.stopPropagation()}
                  >
                    <AppIcon name="phone" size={14} />
                    {clinic.phone}
                  </a>
                </div>
                <button
                  type="button"
                  className="btn btn-primary btn-sm"
                  onClick={(e) => {
                    e.stopPropagation();
                    dispatch(selectClinic(clinic));
                  }}
                >
                  {t('common.book')}
                </button>
              </article>
            ))}
          </div>
        </div>

        <div className="booking-panel">
          <span className="label">{t('common.onlineBooking')}</span>
          <h2 className="title section-title">{t('common.onlineBooking')}</h2>

          {selectedClinic ? (
            <>
              <p className="card-meta" style={{ marginBottom: '1rem' }}>
                {t('common.bookingAt')} <strong>{selectedClinic.name}</strong>
              </p>
              <form className="form" onSubmit={handleBooking}>
                <div className="field">
                  <label>{t('common.fullName')}</label>
                  <input className="input" required value={bookingForm.name} onChange={(e) => setBookingForm({ ...bookingForm, name: e.target.value })} />
                </div>
                <div className="field">
                  <label>{t('common.phone')}</label>
                  <input className="input" type="tel" required value={bookingForm.phone} onChange={(e) => setBookingForm({ ...bookingForm, phone: e.target.value })} />
                </div>
                <div className="grid grid-2">
                  <div className="field">
                    <label>{t('common.date')}</label>
                    <input className="input" type="date" required value={bookingForm.date} onChange={(e) => setBookingForm({ ...bookingForm, date: e.target.value })} />
                  </div>
                  <div className="field">
                    <label>{t('common.time')}</label>
                    <input className="input" type="time" required value={bookingForm.time} onChange={(e) => setBookingForm({ ...bookingForm, time: e.target.value })} />
                  </div>
                </div>
                <button type="submit" className="btn btn-gold" style={{ width: '100%' }}>{t('common.confirmAppointment')}</button>
              </form>
            </>
          ) : (
            <div className="empty">{t('common.selectClinic')}</div>
          )}

          {booking && (
            <div className="card booking-success">
              <p><strong>{t('common.appointmentConfirmed')}</strong></p>
              <p className="card-meta">{booking.clinic?.name} — {booking.date} {t('common.at')} {booking.time}</p>
              <button type="button" className="btn btn-ghost btn-sm" style={{ marginTop: '0.5rem' }} onClick={() => dispatch(clearBooking())}>
                {t('common.dismiss')}
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
