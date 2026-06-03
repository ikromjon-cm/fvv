import { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { registerForum } from '../../store/slices/forumSlice';

export default function Registration() {
  const [tab, setTab] = useState('professional');
  const [form, setForm] = useState({
    name: '',
    phone: '',
    org: '',
    position: '',
    type: 'dentist',
  });
  const [investor, setInvestor] = useState({
    company: '',
    email: '',
    phone: '',
    amount: '',
    sector: '',
  });

  const dispatch = useDispatch();
  const submitted = useSelector(state => state.forum.submitted);

  const handleProfessional = (e) => {
    e.preventDefault();
    dispatch(registerForum({ ...form, role: 'professional' }));
    setForm({ name: '', phone: '', org: '', position: '', type: 'dentist' });
  };

  const handleInvestor = (e) => {
    e.preventDefault();
    dispatch(registerForum({ ...investor, role: 'investor' }));
    setInvestor({ company: '', email: '', phone: '', amount: '', sector: '' });
  };

  return (
    <section id="register" className="section register">
      <div className="inner">
        <div className="head">
          <h2 className="title">RO'YXATDAN O'TISH</h2>
          <p className="subtitle">Forumga qo'shilish uchun ma'lumotlaringizni kiriting</p>
        </div>

        <div className="wrapper">
          <div className="tabs">
            <button
              type="button"
              className={`tab${tab === 'professional' ? ' active' : ''}`}
              onClick={() => setTab('professional')}
            >
              Mutaxassis
            </button>
            <button
              type="button"
              className={`tab${tab === 'investor' ? ' active' : ''}`}
              onClick={() => setTab('investor')}
            >
              Investor
            </button>
          </div>

          {tab === 'professional' && (
            <form onSubmit={handleProfessional} className="form">
              {submitted && (
                <div className="message success">
                  ✅ Ro'yxatdan o'tish muvaffaqiyatli yakunlandi!
                </div>
              )}
              <div className="field">
                <label className="label">F.I.O</label>
                <input
                  type="text"
                  className="input"
                  required
                  value={form.name}
                  onChange={(e) => setForm({ ...form, name: e.target.value })}
                  placeholder="To'liq ism-familiyangiz"
                />
              </div>
              <div className="field">
                <label className="label">Telefon</label>
                <input
                  type="tel"
                  className="input"
                  required
                  value={form.phone}
                  onChange={(e) => setForm({ ...form, phone: e.target.value })}
                  placeholder="+998 90 000 00 00"
                />
              </div>
              <div className="field">
                <label className="label">Tashkilot nomi</label>
                <input
                  type="text"
                  className="input"
                  required
                  value={form.org}
                  onChange={(e) => setForm({ ...form, org: e.target.value })}
                  placeholder="Klinika, laboratoriya yoki tashkilot"
                />
              </div>
              <div className="field">
                <label className="label">Lavozim</label>
                <input
                  type="text"
                  className="input"
                  required
                  value={form.position}
                  onChange={(e) => setForm({ ...form, position: e.target.value })}
                  placeholder="Stomatolog, texnik, rahbar va hokazo"
                />
              </div>
              <div className="field">
                <label className="label">Ishtirokchi turi</label>
                <select
                  className="input"
                  value={form.type}
                  onChange={(e) => setForm({ ...form, type: e.target.value })}
                >
                  <option value="dentist">Stomatolog</option>
                  <option value="technician">Tish texnigi</option>
                  <option value="manager">Klinik rahbari</option>
                  <option value="supplier">Mahsulot yetkazib beruvchi</option>
                </select>
              </div>
              <button type="submit" className="primary" style={{ width: '100%' }}>
                RO'YXATDAN O'TISH
              </button>
            </form>
          )}

          {tab === 'investor' && (
            <form onSubmit={handleInvestor} className="form">
              {submitted && (
                <div className="message success">
                  ✅ Investor ma'lumotlaringiz qabul qilindi!
                </div>
              )}
              <div className="message info">
                🔒 Investor portali - Maxfiy va xavfsiz
              </div>
              <div className="field">
                <label className="label">Kompaniya nomi</label>
                <input
                  type="text"
                  className="input"
                  required
                  value={investor.company}
                  onChange={(e) => setInvestor({ ...investor, company: e.target.value })}
                  placeholder="Sizning kompaniyasi"
                />
              </div>
              <div className="field">
                <label className="label">Email</label>
                <input
                  type="email"
                  className="input"
                  required
                  value={investor.email}
                  onChange={(e) => setInvestor({ ...investor, email: e.target.value })}
                  placeholder="info@company.uz"
                />
              </div>
              <div className="field">
                <label className="label">Telefon</label>
                <input
                  type="tel"
                  className="input"
                  required
                  value={investor.phone}
                  onChange={(e) => setInvestor({ ...investor, phone: e.target.value })}
                  placeholder="+998 90 000 00 00"
                />
              </div>
              <div className="field">
                <label className="label">Investitsiya hajmi (USD)</label>
                <input
                  type="number"
                  className="input"
                  required
                  value={investor.amount}
                  onChange={(e) => setInvestor({ ...investor, amount: e.target.value })}
                  placeholder="100000 dan yuqoriga"
                />
              </div>
              <div className="field">
                <label className="label">Sohasi</label>
                <select
                  className="input"
                  value={investor.sector}
                  onChange={(e) => setInvestor({ ...investor, sector: e.target.value })}
                >
                  <option value="">Tanlang...</option>
                  <option value="healthcare">Sog'liqni saqlash</option>
                  <option value="tech">Texnologiya</option>
                  <option value="equipment">Uskunalar</option>
                  <option value="services">Xizmatlar</option>
                </select>
              </div>
              <button type="submit" className="primary" style={{ width: '100%' }}>
                INVESTOR PORTAL'IGA KIRISH
              </button>
            </form>
          )}
        </div>
      </div>
    </section>
  );
}
