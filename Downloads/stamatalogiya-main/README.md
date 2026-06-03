# Dentago Market

Premium digital ecosystem and marketplace for dentists, dental technicians, clinics, and suppliers.

## Stack

- React 19 + Vite 8
- Redux Toolkit (global state)
- React Router 7
- Modern CSS (semantic single-word classes)

## Features

- **Registration Gateway** — Role-based onboarding (Dentist, Technician, Supplier, Customer)
- **Marketplace** — Product catalog, categories, cart, advertisement board (Elon berish)
- **Technicians Hub** — Portfolios, pricing, availability
- **Orders** — Digital order workflow with file upload UI
- **Clinics** — Geolocation map, filters (pediatric, women's, 24/7, top-rated), online booking
- **Academy** — Video course catalog with enrollment and progress tracking
- **CRM Dashboard** — Patients, financial reports, partnerships

## Commands

```bash
npm install
npm run dev
npm run build
npm run preview
```

## Project Structure

```
src/
  components/layout/   Header, Footer, Layout, RegistrationModal, PremiumGate
  components/ui/       ProductCard
  pages/               Home, Marketplace, TechniciansHub, Orders, Clinics, Academy, Dashboard
  store/slices/        auth, marketplace, clinics, courses, orders, dashboard
  data/mockData.js     Seed data
  styles/              variables, global, components
```

## Internationalization & Theme

- **Languages:** Oʻzbek (UZ), Русский (RU), English (EN) — switch in the header; preference saved to `localStorage`
- **Themes:** Light and dark mode — toggle in the header; no flash on reload (inline boot script in `index.html`)
- **Media:** Responsive `MediaBlock` placeholders (no broken images), `object-fit`, scrollable tables, `prefers-reduced-motion` support

## Design

Deep teals, slate grays, clean whites, gold accents. Glassmorphism header, micro-interactions, fully responsive layout.
