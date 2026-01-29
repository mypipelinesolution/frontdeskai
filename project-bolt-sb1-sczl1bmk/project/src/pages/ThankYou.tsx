import { useEffect } from 'react';
import { Link } from '../lib/router';
import { CheckCircle, ArrowRight } from 'lucide-react';

export function ThankYou() {
  useEffect(() => {
    const confetti = () => {
      const colors = ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6'];
      const canvas = document.createElement('canvas');
      canvas.style.position = 'fixed';
      canvas.style.top = '0';
      canvas.style.left = '0';
      canvas.style.width = '100%';
      canvas.style.height = '100%';
      canvas.style.pointerEvents = 'none';
      canvas.style.zIndex = '9999';
      document.body.appendChild(canvas);

      const ctx = canvas.getContext('2d');
      if (!ctx) return;

      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;

      const pieces: any[] = [];
      const numberOfPieces = 50;

      for (let i = 0; i < numberOfPieces; i++) {
        pieces.push({
          x: Math.random() * canvas.width,
          y: Math.random() * canvas.height - canvas.height,
          r: Math.random() * 6 + 4,
          d: Math.random() * numberOfPieces,
          color: colors[Math.floor(Math.random() * colors.length)],
          tilt: Math.random() * 10 - 10,
          tiltAngleIncremental: Math.random() * 0.07 + 0.05,
          tiltAngle: 0,
        });
      }

      let animationId: number;

      function draw() {
        if (!ctx) return;
        ctx.clearRect(0, 0, canvas.width, canvas.height);

        for (let i = 0; i < pieces.length; i++) {
          const p = pieces[i];
          ctx.beginPath();
          ctx.lineWidth = p.r / 2;
          ctx.strokeStyle = p.color;
          ctx.moveTo(p.x + p.tilt + p.r / 4, p.y);
          ctx.lineTo(p.x + p.tilt, p.y + p.tilt + p.r / 4);
          ctx.stroke();
        }

        update();
      }

      function update() {
        for (let i = 0; i < pieces.length; i++) {
          const p = pieces[i];
          p.tiltAngle += p.tiltAngleIncremental;
          p.y += (Math.cos(p.d) + 3 + p.r / 2) / 2;
          p.tilt = Math.sin(p.tiltAngle) * 15;

          if (p.y > canvas.height) {
            pieces[i] = {
              ...p,
              x: Math.random() * canvas.width,
              y: -10,
            };
          }
        }
        animationId = requestAnimationFrame(draw);
      }

      draw();

      setTimeout(() => {
        cancelAnimationFrame(animationId);
        document.body.removeChild(canvas);
      }, 5000);
    };

    confetti();
  }, []);

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-slate-50 flex items-center justify-center p-4">
      <div className="max-w-2xl w-full bg-white rounded-2xl shadow-2xl p-12 text-center">
        <div className="flex justify-center mb-6">
          <CheckCircle className="w-24 h-24 text-green-500" />
        </div>

        <h1 className="text-4xl md:text-5xl font-bold text-slate-900 mb-4">
          Welcome to FrontDesk AI Pro!
        </h1>

        <p className="text-xl text-slate-600 mb-8">
          Your payment was successful. Let's set up your AI front desk and start capturing leads.
        </p>

        <div className="bg-blue-50 border-2 border-blue-200 rounded-xl p-6 mb-8">
          <h2 className="text-lg font-semibold text-blue-900 mb-3">What happens next:</h2>
          <ul className="text-left space-y-2 text-blue-800">
            <li className="flex items-start gap-3">
              <span className="font-bold text-blue-600">1.</span>
              <span>Complete your business profile setup</span>
            </li>
            <li className="flex items-start gap-3">
              <span className="font-bold text-blue-600">2.</span>
              <span>Connect your phone number and calendar</span>
            </li>
            <li className="flex items-start gap-3">
              <span className="font-bold text-blue-600">3.</span>
              <span>Your AI bots go live automatically</span>
            </li>
            <li className="flex items-start gap-3">
              <span className="font-bold text-blue-600">4.</span>
              <span>Start capturing and converting leads 24/7</span>
            </li>
          </ul>
        </div>

        <Link
          to="/app"
          className="inline-flex items-center gap-2 px-8 py-4 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-semibold text-lg transition shadow-lg"
        >
          Complete Setup <ArrowRight className="w-5 h-5" />
        </Link>

        <p className="text-sm text-slate-500 mt-6">
          A confirmation email has been sent to your inbox
        </p>
      </div>
    </div>
  );
}
