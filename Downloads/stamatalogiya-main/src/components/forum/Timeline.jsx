export default function Timeline() {
  const events = [
    { time: '09:00', title: 'Mehmonlarni kutib olish', desc: 'Ro\'y berish va ishtirokchilarni o\'rni berish' },
    { time: '10:00', title: 'Rasmiy ochilish marosimi', desc: 'Hokimlik va SSV vakillari nutqi' },
    { time: '10:30', title: 'Dentago platformasi taqdimoti', desc: 'CRM & Bemorlar bazasi' },
    { time: '11:30', title: 'Dental Expo va mahsulotlar ko\'rgazmasi', desc: 'Yangi texnologiyalar va uskunalar' },
    { time: '13:00', title: 'Coffee Break & Networking', desc: 'Ishtirokchilar o\'rtasida muloqot' },
    { time: '14:00', title: 'Ilmiy-amaliy seminarlar', desc: 'Tish texniklari mahorat darslari' },
    { time: '17:00', title: 'Rasmiy lenta kesish marosimi', desc: 'Forumning e\'tiborli yakuni' },
  ];

  return (
    <section id="timeline" className="section timeline">
      <div className="inner">
        <div className="head">
          <h2 className="title">FORUM DASTURI</h2>
          <p className="subtitle">2026 yil 15 iyun, Namangan</p>
        </div>

        <div className="rail">
          {events.map((event, i) => (
            <div key={i} className="item">
              <div className="dot"></div>
              <div className="block">
                <div className="time">{event.time}</div>
                <h3 className="name">{event.title}</h3>
                <p className="text">{event.desc}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
