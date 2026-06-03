export const marketplaceCategories = [
  { id: 'units', label: 'Dental Units', labelUz: 'Stomatologik unitlar', icon: 'chair' },
  { id: 'consumables', label: 'Consumables', labelUz: 'Sarflanuvchi materiallar', icon: 'box' },
  { id: 'implants', label: 'Implant Systems', labelUz: 'Implant tizimlari', icon: 'implant' },
  { id: 'digital', label: 'Digital Tech', labelUz: 'Raqamli texnologiya', icon: 'scan' },
  { id: 'used', label: 'Used Equipment', labelUz: 'Ishlatilgan uskunalar', icon: 'recycle' },
];

const PRODUCT_IMAGES = {
  unit: 'https://images.unsplash.com/photo-1629909613654-28e377680a26?w=800&q=80',
  implant: 'https://images.unsplash.com/photo-1606811841107-5c1ac4b4c4e8?w=800&q=80',
  scanner: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800&q=80',
  composite: 'https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?w=800&q=80',
  used: 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=800&q=80',
  itero: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=800&q=80',
};

export const marketplaceProducts = [
  { id: 1, title: 'Sirona C8+ Dental Unit', price: 28500, currency: 'USD', category: 'units', seller: 'MedDental Supply', rating: 4.9, image: 'unit', imageUrl: PRODUCT_IMAGES.unit, featured: true },
  { id: 2, title: 'Straumann BLX Implant Kit', price: 4200, currency: 'USD', category: 'implants', seller: 'ImplantPro UZ', rating: 4.8, image: 'implant', imageUrl: PRODUCT_IMAGES.implant, featured: true },
  { id: 3, title: '3Shape TRIOS 5 Scanner', price: 18900, currency: 'USD', category: 'digital', seller: 'Digital Dental', rating: 4.9, image: 'scanner', imageUrl: PRODUCT_IMAGES.scanner, featured: true },
  { id: 4, title: 'Composite Resin Kit (50 pcs)', price: 340, currency: 'USD', category: 'consumables', seller: 'DentaMart', rating: 4.7, image: 'composite', imageUrl: PRODUCT_IMAGES.composite, featured: false },
  { id: 5, title: 'Used KaVo ESTETICA E70', price: 8900, currency: 'USD', category: 'used', seller: 'Clinic Resale', rating: 4.5, image: 'used', imageUrl: PRODUCT_IMAGES.used, featured: false },
  { id: 6, title: 'iTero Element 5D', price: 22400, currency: 'USD', category: 'digital', seller: 'Align Partner', rating: 4.9, image: 'itero', imageUrl: PRODUCT_IMAGES.itero, featured: true },
];

export const forumAds = [
  { id: 1, title: 'Dentsply Sirona CEREC MC XL', price: 12500, location: 'Toshkent', author: 'Dr. Karimov', date: '2026-05-28', condition: 'Excellent' },
  { id: 2, title: 'Zirconia Blocks (100 units)', price: 890, location: 'Samarqand', author: 'Lab Pro', date: '2026-05-30', condition: 'New' },
  { id: 3, title: 'NSK Ti-Max Z95L Handpiece', price: 420, location: 'Farg\'ona', author: 'Tech Supply', date: '2026-06-01', condition: 'Like New' },
];

export const technicians = [
  { id: 1, name: 'Aziz Rahimov', specialty: 'Zirconia & E-max', rating: 4.9, orders: 1240, priceFrom: 45, availability: 'Available', location: 'Toshkent', portfolio: 28, phone: '+998901234567' },
  { id: 2, name: 'Malika Tosheva', specialty: 'Removable Prosthetics', rating: 4.8, orders: 890, priceFrom: 35, availability: 'Busy', location: 'Samarqand', portfolio: 42, phone: '+998901234568' },
  { id: 3, name: 'Jasur Bekov', specialty: 'CAD/CAM Milling', rating: 5.0, orders: 2100, priceFrom: 55, availability: 'Available', location: 'Toshkent', portfolio: 56, phone: '+998901234569' },
  { id: 4, name: 'Dilnoza Karimova', specialty: 'Implant Abutments', rating: 4.7, orders: 650, priceFrom: 60, availability: 'Available', location: 'Namangan', portfolio: 19, phone: '+998901234570' },
];

export const clinics = [
  { id: 1, name: 'Dentago Premium Clinic', address: 'Mirzo Ulug\'bek ko\'chasi 12, Toshkent 100170', lat: 41.311081, lng: 69.279737, rating: 4.9, distance: 0.8, categories: ['top', 'general'], phone: '+998712000001', open24: false },
  { id: 2, name: 'Smile Kids Dental', address: 'Yunusobod tumani, 45-mavze, Toshkent', lat: 41.354756, lng: 69.286781, rating: 4.8, distance: 2.1, categories: ['pediatric'], phone: '+998712000002', open24: false },
  { id: 3, name: 'Femina Dental Studio', address: 'Chilonzor 8, Toshkent 100115', lat: 41.278526, lng: 69.203682, rating: 4.9, distance: 3.4, categories: ['women', 'top'], phone: '+998712000003', open24: false },
  { id: 4, name: 'Emergency Dental 24/7', address: 'Shota Rustaveli ko\'chasi 1, Toshkent', lat: 41.299496, lng: 69.240074, rating: 4.7, distance: 1.5, categories: ['emergency'], phone: '+998712000004', open24: true },
  { id: 5, name: 'Elite Stomatology Center', address: 'Registon ko\'chasi 22, Samarqand 140104', lat: 39.654191, lng: 66.959724, rating: 5.0, distance: 5.2, categories: ['top', 'general'], phone: '+998662000005', open24: false },
];

export const clinicFilters = [
  { id: 'all', label: 'All Clinics', labelUz: 'Barcha klinikalar' },
  { id: 'pediatric', label: 'Pediatric', labelUz: 'Bolalar stomatologi' },
  { id: 'women', label: 'Women\'s Dentistry', labelUz: 'Ayollar stomatologi' },
  { id: 'emergency', label: '24/7 Emergency', labelUz: '24/7 ishlaydigan' },
  { id: 'top', label: 'Top Rated', labelUz: 'Eng yaxshi stomatolog' },
];

export const courses = [
  { id: 1, title: 'Advanced Implantology Masterclass', instructor: 'Prof. Dr. Alisher Navoiy', category: 'clinical', duration: '24 soat', lessons: 18, progress: 0, rating: 4.9, students: 342, price: 450, level: 'Advanced', youtubeId: 'm1JqhPmhi6s', imageUrl: 'https://images.unsplash.com/photo-1606811971618-4486eb493ec0?w=800&q=80' },
  { id: 2, title: 'Digital Smile Design Workflow', instructor: 'Dr. Elena Volkova', category: 'clinical', duration: '16 soat', lessons: 12, progress: 35, rating: 4.8, students: 218, price: 320, level: 'Intermediate', youtubeId: 'K3V2A_z0Q8E', imageUrl: 'https://images.unsplash.com/photo-1609840114035-3c981b782cad?w=800&q=80' },
  { id: 3, title: 'Zirconia Layering Techniques', instructor: 'Aziz Rahimov, MDT', category: 'technician', duration: '20 soat', lessons: 15, progress: 0, rating: 5.0, students: 156, price: 280, level: 'Expert', youtubeId: '9G6F47rmyUQ', imageUrl: 'https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?w=800&q=80' },
  { id: 4, title: 'CAD/CAM for Dental Technicians', instructor: 'Jasur Bekov, MDT', category: 'technician', duration: '32 soat', lessons: 24, progress: 0, rating: 4.9, students: 89, price: 380, level: 'Intermediate', youtubeId: '5qap5aO4i9A', imageUrl: 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=800&q=80' },
  { id: 5, title: 'Clinic Growth & Patient Acquisition', instructor: 'Marketing Dental UZ', category: 'marketing', duration: '12 soat', lessons: 10, progress: 60, rating: 4.7, students: 512, price: 199, level: 'Beginner', youtubeId: 'jNQXAC9IVRw', imageUrl: 'https://images.unsplash.com/photo-1551836022-d5d88e9218df?w=800&q=80' },
  { id: 6, title: 'Social Media for Dental Practices', instructor: 'Sardor Marketing', category: 'marketing', duration: '8 soat', lessons: 8, progress: 0, rating: 4.6, students: 445, price: 149, level: 'Beginner', youtubeId: 'dQw4w9WgXcQ', imageUrl: 'https://images.unsplash.com/photo-1611162616305-c69b3fa7a0be?w=800&q=80' },
];

export const courseCategories = [
  { id: 'clinical', label: 'Clinical Courses', labelUz: 'Stomatologiya kurslari' },
  { id: 'technician', label: 'Technician Masterclasses', labelUz: 'Tish texniklari kurslari' },
  { id: 'marketing', label: 'Marketing & Management', labelUz: 'Marketing kurslari' },
];

export const dashboardStats = {
  patients: 1248,
  revenue: 89420,
  orders: 156,
  partnerships: 12,
};

export const patients = [
  { id: 1, name: 'Sardor Alimov', lastVisit: '2026-05-28', treatment: 'Crown prep', status: 'Active' },
  { id: 2, name: 'Nilufar Yusupova', lastVisit: '2026-05-25', treatment: 'Implant consult', status: 'Scheduled' },
  { id: 3, name: 'Bobur Rakhimov', lastVisit: '2026-05-20', treatment: 'Orthodontics', status: 'Active' },
];

export const orders = [
  { id: 'ORD-2401', patient: 'Sardor A.', type: 'Zirconia Crown', technician: 'Aziz Rahimov', status: 'In Production', date: '2026-06-01' },
  { id: 'ORD-2402', patient: 'Nilufar Y.', type: 'E-max Veneer', technician: 'Malika Tosheva', status: 'Pending Review', date: '2026-05-30' },
  { id: 'ORD-2403', patient: 'Bobur R.', type: 'Full Denture', technician: 'Jasur Bekov', status: 'Shipped', date: '2026-05-28' },
];

export const roles = [
  { id: 'dentist', label: 'Dentist', labelUz: 'Stomatolog' },
  { id: 'technician', label: 'Dental Technician', labelUz: 'Tish texnik' },
  { id: 'supplier', label: 'Supplier', labelUz: 'Yetkazib beruvchi' },
  { id: 'customer', label: 'General Customer', labelUz: 'Umumiy mijoz' },
];

export const navLinks = [
  { path: '/', key: 'nav.home' },
  { path: '/marketplace', key: 'nav.marketplace' },
  { path: '/technicians', key: 'nav.technicians' },
  { path: '/orders', key: 'nav.orders' },
  { path: '/clinics', key: 'nav.clinics' },
  { path: '/forum', key: 'nav.forum' },
  { path: '/academy', key: 'nav.academy' },
  { path: '/dashboard', key: 'nav.dashboard', premium: true },
];
