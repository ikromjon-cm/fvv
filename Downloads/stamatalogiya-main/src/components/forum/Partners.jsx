export default function Partners() {
  const logos = [
    'Namangan Viloyati Hokimligi',
    'Sog\'liqni Saqlash Vazirligi',
    'Straumann Implants',
    '3Shape Digital',
    'Dentsply Sirona',
    'Aligner Tech Solutions',
    'Global Dental Supply',
    'Innovation Labs UZ',
  ];

  return (
    <section className="section partners">
      <div className="inner">
        <div className="head">
          <h2 className="title">RASMIY HAMKORLAR</h2>
          <p className="subtitle">O'zbekiston va xalqaro kompaniyalar</p>
        </div>

        <div className="marquee">
          <div className="track">
            {[...logos, ...logos].map((logo, i) => (
              <div key={i} className="slide">
                <div className="badge">{logo}</div>
              </div>
            ))}
          </div>
        </div>

        <div className="grid">
          <div className="partner">
            <div className="head">
              <div className="symbol">🏛️</div>
              <h3 className="title">Hokimlik</h3>
            </div>
            <p className="text">Namangan Viloyati Hokimligi - Forumning rasmiy tashkil etuvchisi</p>
          </div>
          <div className="partner">
            <div className="head">
              <div className="symbol">🏥</div>
              <h3 className="title">Sog'liqni Saqlash</h3>
            </div>
            <p className="text">Sog'liqni Saqlash Vazirligi - Stomatologiya sohasi rahbari</p>
          </div>
          <div className="partner">
            <div className="head">
              <div className="symbol">🏭</div>
              <h3 className="title">Dental Kompaniyalar</h3>
            </div>
            <p className="text">Global stomatologik mahsulot va uskunalar yetkazib beruvchilari</p>
          </div>
          <div className="partner">
            <div className="head">
              <div className="symbol">💡</div>
              <h3 className="title">IT Mutaxassislari</h3>
            </div>
            <p className="text">Raqamli transformatsiya va innovatsion texnologiyalar taqdimotlari</p>
          </div>
        </div>
      </div>
    </section>
  );
}
