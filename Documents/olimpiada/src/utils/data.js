export const regions = [
  "Toshkent shahri", "Toshkent viloyati", "Samarqand", "Buxoro", "Andijon",
  "Namangan", "Farg'ona", "Qoraqalpog'iston", "Xorazm", "Navoiy",
  "Jizzax", "Sirdaryo", "Qashqadaryo", "Surxondaryo"
];

export const grades = [5, 6, 7, 8, 9, 10, 11];

export const subjects = [
  "Matematika", "Fizika", "Kimyo", "Biologiya", "Informatika",
  "Ingliz tili", "Ona tili", "Tarix", "Geografiya", "Astronomiya"
];

export const upcomingOlympiads = [
  { id: 1, title: "Respublika Matematika Olimpiadasi", subject: "Matematika", grade: "9-11", date: "2026-06-20", status: "open", participants: 1250 },
  { id: 2, title: "Fizika Fan Olimpiadasi", subject: "Fizika", grade: "8-11", date: "2026-07-05", status: "open", participants: 980 },
  { id: 3, title: "Kimyo Xalqaro Olimpiadasi", subject: "Kimyo", grade: "10-11", date: "2026-07-15", status: "coming_soon", participants: 560 },
  { id: 4, title: "Informatika Algoritm Olimpiadasi", subject: "Informatika", grade: "7-11", date: "2026-08-01", status: "coming_soon", participants: 720 },
  { id: 5, title: "Biologiya Tanlovi", subject: "Biologiya", grade: "9-11", date: "2026-08-20", status: "coming_soon", participants: 430 },
  { id: 6, title: "Ingliz Tili Olimpiadasi", subject: "Ingliz tili", grade: "5-11", date: "2026-09-01", status: "coming_soon", participants: 2100 },
  { id: 7, title: "Tarix Bilimlar Musobaqasi", subject: "Tarix", grade: "8-11", date: "2026-09-15", status: "closed", participants: 340 },
  { id: 8, title: "Geografiya Olimpiadasi", subject: "Geografiya", grade: "9-11", date: "2026-10-01", status: "closed", participants: 290 },
];

export const olympiadHistory = [
  { id: "OLY-2024-001", title: "Matematika Olimpiadasi", date: "2025-12-10", score: 92, rank: 1, total: 450, grade: 11, certificate: true },
  { id: "OLY-2024-002", title: "Fizika Olimpiadasi", date: "2025-10-15", score: 85, rank: 3, total: 380, grade: 11, certificate: true },
  { id: "OLY-2024-003", title: "Informatika Olimpiadasi", date: "2025-08-20", score: 78, rank: 5, total: 310, grade: 10, certificate: true },
  { id: "OLY-2024-004", title: "Kimyo Olimpiadasi", date: "2025-05-10", score: 65, rank: 12, total: 280, grade: 10, certificate: false },
  { id: "OLY-2024-005", title: "Ingliz Tili Olimpiadasi", date: "2025-03-01", score: 90, rank: 2, total: 520, grade: 9, certificate: true },
];

export const notifications = [
  { id: 1, title: "Yangi olimpiada ochildi", message: "Respublika Matematika Olimpiadasi uchun ro'yxatdan o'tish boshlandi.", time: "2 soat oldin", type: "info" },
  { id: 2, title: "Natijalar e'lon qilindi", message: "Fizika olimpiadasi natijalarini ko'rishingiz mumkin.", time: "1 kun oldin", type: "success" },
  { id: 3, title: "Sertifikat tayyor", message: "Matematika olimpiadasi sertifikatingiz yuklab olishga tayyor.", time: "3 kun oldin", type: "certificate" },
  { id: 4, title: "Eslatma", message: "Informatika olimpiadasiga ro'yxatdan o'tish muddati tugashiga 5 kun qoldi.", time: "5 kun oldin", type: "warning" },
];

export const certificates = [
  { id: "CERT-001", title: "Matematika Olimpiadasi", rank: "1-o'rin", date: "2025-12-10", type: "gold", student: "Ali Karimov" },
  { id: "CERT-002", title: "Fizika Olimpiadasi", rank: "3-o'rin", date: "2025-10-15", type: "bronze", student: "Ali Karimov" },
  { id: "CERT-003", title: "Informatika Olimpiadasi", rank: "Faxriy yorliq", date: "2025-08-20", type: "honorable", student: "Ali Karimov" },
  { id: "CERT-004", title: "Ingliz Tili Olimpiadasi", rank: "2-o'rin", date: "2025-03-01", type: "silver", student: "Ali Karimov" },
];

export const allResults = [
  { id: "OLY-2024-001", student: "Ali Karimov", score: 92, rank: 1, total: 450, subject: "Matematika", date: "2025-12-10", certificate: true },
  { id: "OLY-2024-001", student: "Zarina Ahmedova", score: 88, rank: 2, total: 450, subject: "Matematika", date: "2025-12-10", certificate: true },
  { id: "OLY-2024-001", student: "Bekzod Rahimov", score: 85, rank: 3, total: 450, subject: "Matematika", date: "2025-12-10", certificate: true },
  { id: "OLY-2024-001", student: "Dilnoza Xasanova", score: 82, rank: 4, total: 450, subject: "Matematika", date: "2025-12-10", certificate: true },
  { id: "OLY-2024-001", student: "Javohir Abdullayev", score: 79, rank: 5, total: 450, subject: "Matematika", date: "2025-12-10", certificate: false },
  { id: "OLY-2024-002", student: "Ali Karimov", score: 85, rank: 3, total: 380, subject: "Fizika", date: "2025-10-15", certificate: true },
  { id: "OLY-2024-002", student: "Sarvar Umarov", score: 92, rank: 1, total: 380, subject: "Fizika", date: "2025-10-15", certificate: true },
  { id: "OLY-2024-002", student: "Malika Rashidova", score: 87, rank: 2, total: 380, subject: "Fizika", date: "2025-10-15", certificate: true },
  { id: "OLY-2024-003", student: "Ali Karimov", score: 78, rank: 5, total: 310, subject: "Informatika", date: "2025-08-20", certificate: true },
  { id: "OLY-2024-004", student: "Ali Karimov", score: 65, rank: 12, total: 280, subject: "Kimyo", date: "2025-05-10", certificate: false },
];

export const questions = [
  { q: "Olimpiadada kimlar qatnasha oladi?", a: "Barcha 5-11 sinf o'quvchilari o'z fanlaridan olimpiadalarda qatnashishlari mumkin." },
  { q: "Ro'yxatdan o'tish bepulmi?", a: "Ha, barcha olimpiadalarda qatnashish mutlaqo bepul." },
  { q: "Natijalar qachon e'lon qilinadi?", a: "Olimpiada tugaganidan keyin 7 kun ichida natijalar e'lon qilinadi." },
  { q: "Sertifikatni qanday olaman?", a: "Yuqori natija ko'rsatgan ishtirokchilarga elektron sertifikat beriladi." },
  { q: "Bir nechta fandan qatnasha olamanmi?", a: "Ha, istalgancha fanlardan qatnashishingiz mumkin." },
];

export const testimonials = [
  { name: "Shahzod Aliyev", role: "O'quvchi, 11-sinf", text: "Bu platforma orqali men matematika olimpiadasida 1-o'rinni egalladim. Juda qulay va zamonaviy tizim!", rating: 5 },
  { name: "Gulnora Karimova", role: "O'qituvchi", text: "O'quvchilarimni olimpiadalarga tayyorlashda bu platforma juda katta yordam bermoqda.", rating: 5 },
  { name: "Bobur Raximov", role: "O'quvchi, 9-sinf", text: "Sertifikatlar va natijalarni ko'rish juda oson. Hammasi bir joyda!", rating: 4 },
  { name: "Dilshod Ergashev", role: "Ota-ona", text: "Farzandimning muvaffaqiyatlarini kuzatish juda oson. Tavsiya qilaman!", rating: 5 },
  { name: "Zarnigor Abdullayeva", role: "O'quvchi, 10-sinf", text: "Fizika olimpiadasida qatnashdim, natijalar tez va aniq e'lon qilindi.", rating: 4 },
];

export const stats = {
  totalStudents: 15420,
  totalOlympiads: 48,
  certificatesIssued: 12500,
  activeRegions: 14,
};

export const adminStats = {
  totalStudents: 15420,
  activeOlympiads: 6,
  completedOlympiads: 42,
  totalRegistrations: 28450,
  certificatesIssued: 12500,
  newThisMonth: 1230,
  revenue: 0,
  activeUsers: 3450,
};
