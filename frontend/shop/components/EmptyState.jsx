// Empty / error states with hand-drawn inline SVG illustrations.
// variant: "bread" (default) | "oven" | "cart" | "orders"

export default function EmptyState({ title, message, action, variant = "bread" }) {
  const Art = ART[variant] || ART.bread;
  return (
    <div className="empty-state">
      <div className="empty-icon" aria-hidden>
        <Art />
      </div>
      <h3>{title}</h3>
      {message && <p>{message}</p>}
      {action}
    </div>
  );
}

function BreadArt() {
  return (
    <svg width="52" height="52" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round">
      <path d="M4 10c0-2.8 3.6-4.5 8-4.5s8 1.7 8 4.5c0 1.2-.7 2-1.5 2.4V17a1.5 1.5 0 0 1-1.5 1.5H7A1.5 1.5 0 0 1 5.5 17v-4.6C4.7 12 4 11.2 4 10z" />
      <path d="M9.5 9v4M14.5 9v4" />
    </svg>
  );
}

/* A warm oven with a loaf inside and gently rising steam. */
function OvenArt() {
  return (
    <svg width="56" height="56" viewBox="0 0 48 48" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round">
      {/* steam */}
      <g className="steam" strokeWidth="1.4" opacity="0.85">
        <line x1="18" y1="6.5" x2="18" y2="2.8" />
        <line x1="24" y1="7.5" x2="24" y2="3.4" />
        <line x1="30" y1="6.5" x2="30" y2="2.8" />
      </g>
      {/* oven body */}
      <rect x="8" y="11" width="32" height="30" rx="4" />
      {/* control strip + knobs */}
      <line x1="8" y1="19" x2="40" y2="19" />
      <circle cx="14" cy="15" r="1.3" fill="currentColor" stroke="none" />
      <circle cx="20" cy="15" r="1.3" fill="currentColor" stroke="none" />
      <circle cx="34" cy="15" r="1.3" fill="currentColor" stroke="none" />
      {/* door window */}
      <rect x="13" y="23" width="22" height="13" rx="2.5" />
      {/* loaf inside */}
      <path d="M17.5 32.5c0-2.4 2.9-3.8 6.5-3.8s6.5 1.4 6.5 3.8" strokeWidth="1.4" />
      <path d="M21.5 30.2v2.3M26.5 30.2v2.3" strokeWidth="1.2" />
    </svg>
  );
}

/* A shopping basket with a loaf peeking out. */
function CartArt() {
  return (
    <svg width="56" height="56" viewBox="0 0 48 48" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round">
      {/* loaf peeking above the basket */}
      <path d="M16.5 20c0-3 3.4-4.8 7.5-4.8s7.5 1.8 7.5 4.8" strokeWidth="1.4" />
      <path d="M21 17.2v2.6M27 17.2v2.6" strokeWidth="1.2" />
      {/* basket */}
      <path d="M9 21h30l-3.2 15.2a3 3 0 0 1-2.9 2.3H15.1a3 3 0 0 1-2.9-2.3L9 21z" />
      {/* weave lines */}
      <path d="M17 25.5l1.4 8.5M24 25.5v8.5M31 25.5l-1.4 8.5" strokeWidth="1.3" opacity="0.8" />
      {/* handle */}
      <path d="M17 21c0-4.5 3.1-7.5 7-7.5s7 3 7 7.5" opacity="0.5" strokeDasharray="2 3" />
    </svg>
  );
}

/* A delivery receipt / order slip. */
function OrdersArt() {
  return (
    <svg width="56" height="56" viewBox="0 0 48 48" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round">
      <path d="M13 6h22v34l-3.5-2.5L28 40l-4-2.6L20 40l-3.5-2.5L13 40V6z" />
      <line x1="18" y1="14" x2="30" y2="14" />
      <line x1="18" y1="20" x2="30" y2="20" />
      <line x1="18" y1="26" x2="25" y2="26" />
      <path d="M26.5 30.5l2.2 2.2 4-4.4" strokeWidth="1.8" />
    </svg>
  );
}

const ART = {
  bread: BreadArt,
  oven: OvenArt,
  cart: CartArt,
  orders: OrdersArt,
};
