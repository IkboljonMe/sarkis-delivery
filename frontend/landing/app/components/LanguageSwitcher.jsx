"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { usePathname } from "next/navigation";

// The five supported locales. `short` is the compact code shown in the
// header button; `label` is the language's own endonym shown in the menu.
export const LOCALES = [
  { code: "en", label: "English", short: "EN", flag: "🇬🇧" },
  { code: "hy", label: "Հայերեն", short: "ՀՅ", flag: "🇦🇲" },
  { code: "ru", label: "Русский", short: "RU", flag: "🇷🇺" },
  { code: "tr", label: "Türkçe", short: "TR", flag: "🇹🇷" },
  { code: "de", label: "Deutsch", short: "DE", flag: "🇩🇪" },
];

// Header language dropdown. Renders real <a> links (locale prefix is always
// present), so it degrades gracefully without JS; the button only toggles
// visibility. Closes on outside-click, Escape or selection.
export default function LanguageSwitcher({ locale, label }) {
  const [open, setOpen] = useState(false);
  const ref = useRef(null);
  const pathname = usePathname() || "/";

  const current = LOCALES.find((l) => l.code === locale) ?? LOCALES[0];

  // Swap only the leading locale segment: "/en/privacy" -> "/hy/privacy".
  const hrefFor = useCallback(
    (code) => {
      const segments = pathname.split("/");
      segments[1] = code;
      return segments.join("/") || "/";
    },
    [pathname]
  );

  useEffect(() => {
    if (!open) return;
    const onClick = (e) => {
      if (ref.current && !ref.current.contains(e.target)) setOpen(false);
    };
    const onKey = (e) => {
      if (e.key === "Escape") setOpen(false);
    };
    document.addEventListener("click", onClick);
    document.addEventListener("keydown", onKey);
    return () => {
      document.removeEventListener("click", onClick);
      document.removeEventListener("keydown", onKey);
    };
  }, [open]);

  return (
    <div className="lang" ref={ref}>
      <button
        type="button"
        className="lang-btn"
        aria-haspopup="listbox"
        aria-expanded={open}
        aria-label={label}
        onClick={() => setOpen((v) => !v)}
      >
        <GlobeIcon />
        <span className="lang-code">{current.short}</span>
        <ChevronIcon />
      </button>
      <ul
        className={`lang-menu${open ? " is-open" : ""}`}
        role="listbox"
        aria-label={label}
      >
        {LOCALES.map((l) => (
          <li key={l.code} role="option" aria-selected={l.code === locale}>
            <a
              href={hrefFor(l.code)}
              hrefLang={l.code}
              lang={l.code}
              className={`lang-option${l.code === locale ? " is-active" : ""}`}
              onClick={() => setOpen(false)}
            >
              <span className="lang-flag" aria-hidden>
                {l.flag}
              </span>
              <span>{l.label}</span>
              {l.code === locale ? <CheckIcon /> : null}
            </a>
          </li>
        ))}
      </ul>
    </div>
  );
}

function GlobeIcon() {
  return (
    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7" aria-hidden>
      <circle cx="12" cy="12" r="9" />
      <path d="M3 12h18M12 3c2.5 2.6 2.5 15.4 0 18M12 3c-2.5 2.6-2.5 15.4 0 18" />
    </svg>
  );
}

function ChevronIcon() {
  return (
    <svg className="lang-chevron" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
      <path d="M6 9l6 6 6-6" />
    </svg>
  );
}

function CheckIcon() {
  return (
    <svg className="lang-check" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
      <path d="M5 13l4 4L19 7" />
    </svg>
  );
}
