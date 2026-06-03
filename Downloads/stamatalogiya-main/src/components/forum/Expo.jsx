export default function Expo() {
  const items = [
    { title: 'Implant tizimlari', icon: '🦷' },
    { title: 'Stomatologik uskunalar', icon: '🪑' },
    { title: 'Sarf materiallari', icon: '🧪' },
    { title: 'CAD/CAM texnologiyalari', icon: '💻' },
    { title: '3D printerlar', icon: '🖨️' },
    { title: 'Raqamli skanerlar', icon: '📡' },
    { title: 'Rentgen tizimlari', icon: '🩻' },
    { title: 'Intraoral kameralar', icon: '📷' },
  ];

  return (
    <section id="expo" className="section expo">
      <div className="inner">
        <div className="head">
          <h2 className="title">DENTAL EXPO 2026</h2>
          <p className="subtitle">Yangi texnologiyalar va mahsulotlarni tanishing</p>
        </div>

        <div className="grid">
          {items.map((item, i) => (
            <div key={i} className="showcase">
              <div className="visual">
                <div className="emoji">{item.icon}</div>
              </div>
              <h3 className="label">{item.title}</h3>
              <button type="button" className="link">
                Batafsil ko'rish
              </button>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
