"use client";

import { useCallback, useEffect, useState } from "react";

// Mobile hamburger + full-screen slide-in menu. Locks body scroll while
// open, closes on link tap / Escape / resize back to desktop.
export default function MobileNav({ links, cta, contact }) {
  const [open, setOpen] = useState(false);
  const close = useCallback(() => setOpen(false), []);

  useEffect(() => {
    document.body.classList.toggle("nav-locked", open);
    return () => document.body.classList.remove("nav-locked");
  }, [open]);

  useEffect(() => {
    if (!open) return;
    const onKey = (e) => {
      if (e.key === "Escape") close();
    };
    const mq = window.matchMedia("(min-width: 721px)");
    const onDesktop = () => mq.matches && close();
    window.addEventListener("keydown", onKey);
    mq.addEventListener("change", onDesktop);
    return () => {
      window.removeEventListener("keydown", onKey);
      mq.removeEventListener("change", onDesktop);
    };
  }, [open, close]);

  return (
    <>
      <button
        type="button"
        className={`nav-toggle${open ? " is-open" : ""}`}
        aria-expanded={open}
        aria-controls="mobile-menu"
        aria-label={open ? "Close menu" : "Open menu"}
        onClick={() => setOpen((v) => !v)}
      >
        <span />
        <span />
        <span />
      </button>

      <div
        id="mobile-menu"
        className={`mobile-menu${open ? " is-open" : ""}`}
        aria-hidden={!open}
      >
        <nav className="mobile-menu-links" aria-label="Mobile">
          {links.map((link, i) => (
            <a
              key={link.href}
              href={link.href}
              tabIndex={open ? 0 : -1}
              style={{ transitionDelay: open ? `${60 + i * 60}ms` : "0ms" }}
              onClick={close}
            >
              {link.label}
            </a>
          ))}
        </nav>
        <a
          className="btn mobile-menu-cta"
          href={cta.href}
          tabIndex={open ? 0 : -1}
          onClick={close}
        >
          {cta.label}
        </a>
        {contact ? (
          <p className="mobile-menu-contact">
            Questions?{" "}
            <a href={contact.href} tabIndex={open ? 0 : -1} onClick={close}>
              {contact.label}
            </a>
          </p>
        ) : null}
      </div>
    </>
  );
}
