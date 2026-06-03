export default function Ecosystem() {
  const features = [
    {
      title: 'CRM TIZIMI',
      desc: 'Klinikani boshqarish, bemorlar bazasi va hisobotlar',
      icon: '📊',
    },
    {
      title: 'MARKETPLACE',
      desc: 'Stomatologik mahsulotlarni sotib olish va sotib yuborish',
      icon: '🛒',
    },
    {
      title: 'TISH TEXNIKLARI',
      desc: 'Buyurtmalarni onlayn boshqarish va hamkorlik',
      icon: '🔧',
    },
    {
      title: 'ANALITIKA',
      desc: 'Daromad, xarajat va samaradorlik hisobotlari',
      icon: '📈',
    },
  ];

  return (
    <section id="ecosystem" className="section ecosystem">
      <div className="inner">
        <div className="head">
          <h2 className="title">DENTAGO EKOTIZIMI</h2>
          <p className="subtitle">Bitta platforma, to'rtta kuch</p>
        </div>
        <div className="grid">
          {features.map((feature, i) => (
            <div key={i} className="card">
              <div className="emoji">{feature.icon}</div>
              <h3 className="name">{feature.title}</h3>
              <p className="text">{feature.desc}</p>
              <div className="glow"></div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
