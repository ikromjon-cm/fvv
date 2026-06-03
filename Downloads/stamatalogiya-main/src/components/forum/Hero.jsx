import { useEffect, useRef } from 'react';

export default function Hero() {
  const canvasRef = useRef(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;

    const particles = [];
    for (let i = 0; i < 100; i++) {
      particles.push({
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        r: Math.random() * 2 + 1,
        vx: Math.random() * 2 - 1,
        vy: Math.random() * 2 - 1,
      });
    }

    const animate = () => {
      ctx.fillStyle = 'rgba(13, 148, 136, 0.02)';
      ctx.fillRect(0, 0, canvas.width, canvas.height);

      particles.forEach(p => {
        p.x += p.vx;
        p.y += p.vy;

        if (p.x < 0) p.x = canvas.width;
        if (p.x > canvas.width) p.x = 0;
        if (p.y < 0) p.y = canvas.height;
        if (p.y > canvas.height) p.y = 0;

        ctx.fillStyle = 'rgba(212, 175, 55, 0.6)';
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
        ctx.fill();
      });

      particles.forEach((p1, i) => {
        particles.slice(i + 1).forEach(p2 => {
          const dx = p1.x - p2.x;
          const dy = p1.y - p2.y;
          const dist = Math.sqrt(dx * dx + dy * dy);
          if (dist < 100) {
            ctx.strokeStyle = `rgba(212, 175, 55, ${0.2 * (1 - dist / 100)})`;
            ctx.lineWidth = 0.5;
            ctx.beginPath();
            ctx.moveTo(p1.x, p1.y);
            ctx.lineTo(p2.x, p2.y);
            ctx.stroke();
          }
        });
      });

      requestAnimationFrame(animate);
    };

    animate();

    const handleResize = () => {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
    };

    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  return (
    <section id="hero" className="hero">
      <canvas ref={canvasRef} className="backdrop"></canvas>
      <div className="overlay"></div>
      <div className="inner">
        <div className="content">
          <h1 className="title">DENTAGO FORUM 2026</h1>
          <h2 className="sub">STOMATOLOGIYA SOHASINING RAQAMLI KELAJAGI</h2>
          <p className="desc">Namangan viloyatida stomatologlar, klinikalar, tish texniklari, investorlar va yetkazib beruvchilarni birlashtiruvchi eng yirik stomatologiya forumi</p>
          <div className="actions">
            <button type="button" className="primary">RO'YXATDAN O'TISH</button>
            <button type="button" className="outline">HAMKOR BO'LISH</button>
          </div>
        </div>
        <div className="visual">
          <div className="cube"></div>
          <div className="cube cube2"></div>
          <div className="cube cube3"></div>
        </div>
      </div>
    </section>
  );
}
