"use client";

import { useEffect } from "react";

// Scroll-reveal bootstrap. Renders nothing; on mount it flags <html> with
// `rvl` (so CSS may hide not-yet-revealed elements — without JS the page
// stays fully visible) and reveals `[data-reveal]` / `[data-reveal-group]`
// elements as they enter the viewport. Children of a group stagger via
// nth-child animation-delay in CSS.
export default function RevealInit() {
  useEffect(() => {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;

    const els = Array.from(
      document.querySelectorAll("[data-reveal], [data-reveal-group]")
    );
    if (!els.length || !("IntersectionObserver" in window)) return;

    document.documentElement.classList.add("rvl");

    const io = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting) {
            entry.target.classList.add("is-visible");
            io.unobserve(entry.target);
          }
        }
      },
      { rootMargin: "0px 0px -8% 0px", threshold: 0.08 }
    );

    for (const el of els) {
      const rect = el.getBoundingClientRect();
      // Elements already in the first viewport reveal immediately (their
      // entrance plays as part of the page load, never a hidden flash).
      if (rect.top < window.innerHeight * 0.92 && rect.bottom > 0) {
        el.classList.add("is-visible");
      } else {
        io.observe(el);
      }
    }

    return () => {
      io.disconnect();
      document.documentElement.classList.remove("rvl");
    };
  }, []);

  return null;
}
