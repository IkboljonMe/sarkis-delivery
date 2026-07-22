// Animated hero scene: a Sarko delivery van bobbing along a moving road with
// warm bread aboard, loaves & wheat drifting around it, and the word
// "delivery" fading in and out along the road. All motion is CSS
// (transform/opacity only) and honours prefers-reduced-motion. Decorative —
// hidden from assistive tech by the parent's aria-hidden.
export default function DeliveryScene({ caption }) {
  return (
    <div className="delivery-scene">
      <div className="scene-halo" />

      {/* Floating baked goods */}
      <span className="goodie goodie-1"><LoafIcon /></span>
      <span className="goodie goodie-2"><BagelIcon /></span>
      <span className="goodie goodie-3"><WheatSprig /></span>
      <span className="goodie goodie-4"><CroissantIcon /></span>

      {/* The van + road */}
      <div className="scene-stage">
        <div className="van-wrap">
          <VanArt />
          <span className="van-steam s1" />
          <span className="van-steam s2" />
        </div>

        <div className="road">
          <span className="road-dashes" />
          <span className="delivery-word">delivery</span>
        </div>
      </div>

      {caption ? <p className="scene-caption">{caption}</p> : null}
    </div>
  );
}

/* ---------- Van (side view, driving right) ---------- */

function VanArt() {
  return (
    <svg
      className="van-svg"
      viewBox="0 0 240 140"
      role="img"
      aria-hidden
      xmlns="http://www.w3.org/2000/svg"
    >
      <defs>
        <linearGradient id="vanBody" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#f0c559" />
          <stop offset="1" stopColor="#c8972a" />
        </linearGradient>
        <linearGradient id="vanCab" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#ffd873" />
          <stop offset="1" stopColor="#e0a838" />
        </linearGradient>
      </defs>

      {/* soft ground shadow */}
      <ellipse className="van-shadow" cx="118" cy="126" rx="96" ry="9" fill="#000" opacity="0.35" />

      {/* cargo box */}
      <rect x="10" y="30" width="150" height="70" rx="12" fill="url(#vanBody)" />
      {/* cabin + hood */}
      <path d="M160 44 h30 l32 30 v26 h-62 z" fill="url(#vanCab)" />
      {/* windshield */}
      <path d="M166 50 h22 l22 22 h-44 z" fill="#0b0b0b" opacity="0.6" />
      <path d="M166 50 h10 l18 22 h-10 z" fill="#ffffff" opacity="0.12" />
      {/* headlight */}
      <rect x="219" y="82" width="7" height="12" rx="3" fill="#fff4cf" />
      {/* bumper */}
      <rect x="160" y="98" width="66" height="8" rx="4" fill="#0f0f0f" opacity="0.85" />

      {/* rear window showing warm bread inside */}
      <rect x="24" y="42" width="46" height="30" rx="7" fill="#2a1c07" opacity="0.55" />
      <path d="M30 66 q17 -20 34 0z" fill="#e7b25a" />
      <path d="M36 64 q11 -12 22 0z" fill="#f4cd7e" />

      {/* brand wordmark on the flank */}
      <text
        x="112"
        y="86"
        textAnchor="middle"
        fontFamily="var(--font-display, Georgia, serif)"
        fontSize="26"
        fontWeight="800"
        letterSpacing="1.5"
        fill="#0a0a0a"
      >
        SARKO
      </text>
      <rect x="80" y="92" width="64" height="3" rx="1.5" fill="#0a0a0a" opacity="0.45" />

      {/* wheels */}
      <g className="wheel wheel-rear">
        <circle cx="66" cy="106" r="17" fill="#111" />
        <circle cx="66" cy="106" r="8" fill="#333" />
        <rect x="64.5" y="90" width="3" height="32" rx="1.5" fill="#555" />
        <rect x="50" y="104.5" width="32" height="3" rx="1.5" fill="#555" />
      </g>
      <g className="wheel wheel-front">
        <circle cx="182" cy="106" r="17" fill="#111" />
        <circle cx="182" cy="106" r="8" fill="#333" />
        <rect x="180.5" y="90" width="3" height="32" rx="1.5" fill="#555" />
        <rect x="166" y="104.5" width="32" height="3" rx="1.5" fill="#555" />
      </g>
    </svg>
  );
}

/* ---------- Floating goods (simple line/fill icons) ---------- */

function LoafIcon() {
  return (
    <svg width="46" height="46" viewBox="0 0 48 48" fill="none" aria-hidden>
      <path d="M8 30c0-7 5-12 16-12s16 5 16 12c0 3-2 5-5 5H13c-3 0-5-2-5-5z" fill="#e7b25a" stroke="#8a5a12" strokeWidth="2" />
      <path d="M18 20c1 3 1 6 0 9M24 19c1 3 1 7 0 10M30 20c1 3 1 6 0 9" stroke="#8a5a12" strokeWidth="1.6" strokeLinecap="round" />
    </svg>
  );
}

function BagelIcon() {
  return (
    <svg width="38" height="38" viewBox="0 0 48 48" fill="none" aria-hidden>
      <circle cx="24" cy="24" r="15" fill="#e7b25a" stroke="#8a5a12" strokeWidth="2" />
      <circle cx="24" cy="24" r="5.5" fill="#0a0a0a" opacity="0.55" />
      <path d="M14 18l1 1M31 16l1 1M33 29l1 1M16 31l1 1" stroke="#8a5a12" strokeWidth="1.6" strokeLinecap="round" />
    </svg>
  );
}

function CroissantIcon() {
  return (
    <svg width="40" height="40" viewBox="0 0 48 48" fill="none" aria-hidden>
      <path d="M10 32c6-14 22-14 28 0-6-4-10-4-14-4s-8 0-14 4z" fill="#f0c559" stroke="#8a5a12" strokeWidth="2" strokeLinejoin="round" />
      <path d="M18 27c2-4 10-4 12 0M22 24c1-2 3-2 4 0" stroke="#8a5a12" strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}

function WheatSprig() {
  return (
    <svg width="34" height="34" viewBox="0 0 48 48" fill="none" stroke="#c8972a" strokeWidth="2.2" strokeLinecap="round" aria-hidden>
      <path d="M24 44V16" />
      <path d="M24 16c-6 0-9-4-9-10 7 0 9 4 9 10z" fill="#e8b84b" />
      <path d="M24 16c6 0 9-4 9-10-7 0-9 4-9 10z" fill="#e8b84b" />
      <path d="M24 28c-6 0-9-4-9-10 7 0 9 4 9 10z" fill="#e8b84b" />
      <path d="M24 28c6 0 9-4 9-10-7 0-9 4-9 10z" fill="#e8b84b" />
    </svg>
  );
}
