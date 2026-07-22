"use client";

import { useEffect, useState } from "react";

const STORAGE_KEY = "sarko_promo_dismissed";

// Sticky top ribbon announcing the first-order discount. Dismissible, and the
// dismissal is remembered in localStorage so it does not nag on return visits.
// Rendered only after mount to avoid a hydration flash of a dismissed ribbon.
export default function PromoRibbon({ text, cta, href, dismissLabel }) {
  const [shown, setShown] = useState(false);

  useEffect(() => {
    try {
      if (localStorage.getItem(STORAGE_KEY) !== "1") setShown(true);
    } catch {
      setShown(true);
    }
  }, []);

  if (!shown) return null;

  const dismiss = () => {
    setShown(false);
    try {
      localStorage.setItem(STORAGE_KEY, "1");
    } catch {
      /* ignore — non-critical */
    }
  };

  return (
    <div className="promo-ribbon" role="region" aria-label={text}>
      <a className="promo-ribbon-main" href={href}>
        <span className="promo-chip">−50%</span>
        <span className="promo-ribbon-text">{text}</span>
        <span className="promo-ribbon-cta">{cta}</span>
      </a>
      <button
        type="button"
        className="promo-ribbon-close"
        aria-label={dismissLabel}
        onClick={dismiss}
      >
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" aria-hidden>
          <path d="M6 6l12 12M18 6L6 18" />
        </svg>
      </button>
    </div>
  );
}
