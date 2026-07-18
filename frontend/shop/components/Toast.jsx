"use client";

// Tiny self-made toast system — context + fixed stack, no portals, no deps.
// usage: const toast = useToast(); toast("Added to cart", { tone: "success" })

import { createContext, useCallback, useContext, useEffect, useRef, useState } from "react";

const ToastContext = createContext(() => {});

export function useToast() {
  return useContext(ToastContext);
}

let idSeq = 0;

export function ToastProvider({ children }) {
  const [toasts, setToasts] = useState([]);
  const timers = useRef(new Map());

  useEffect(() => {
    const pending = timers.current;
    return () => pending.forEach((t) => clearTimeout(t));
  }, []);

  const dismiss = useCallback((id) => {
    const pending = timers.current.get(id);
    if (pending) clearTimeout(pending);
    timers.current.delete(id);
    // fade out, then unmount after the exit transition
    setToasts((list) => list.map((t) => (t.id === id ? { ...t, leaving: true } : t)));
    const gone = setTimeout(() => {
      setToasts((list) => list.filter((t) => t.id !== id));
    }, 280);
    timers.current.set(`exit-${id}`, gone);
  }, []);

  const push = useCallback(
    (message, { tone = "success", duration = 3000 } = {}) => {
      const id = ++idSeq;
      setToasts((list) => [...list.slice(-2), { id, message, tone }]);
      timers.current.set(id, setTimeout(() => dismiss(id), duration));
      return id;
    },
    [dismiss]
  );

  return (
    <ToastContext.Provider value={push}>
      {children}
      <div className="toast-stack" role="status" aria-live="polite">
        {toasts.map((t) => (
          <div key={t.id} className={`toast toast-${t.tone}${t.leaving ? " leaving" : ""}`}>
            <span className="toast-icon" aria-hidden>
              {t.tone === "error" ? <AlertIcon /> : <CheckIcon />}
            </span>
            <span>{t.message}</span>
            <button
              type="button"
              className="toast-close"
              aria-label="Dismiss notification"
              onClick={() => dismiss(t.id)}
            >
              ×
            </button>
          </div>
        ))}
      </div>
    </ToastContext.Provider>
  );
}

function CheckIcon() {
  return (
    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3.2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M4.5 12.5l5 5L19.5 7" />
    </svg>
  );
}

function AlertIcon() {
  return (
    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round">
      <path d="M12 5v9" />
      <circle cx="12" cy="18.4" r="0.6" fill="currentColor" />
    </svg>
  );
}
