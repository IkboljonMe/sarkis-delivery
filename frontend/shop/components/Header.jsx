"use client";

import Link from "next/link";
import { useEffect, useRef, useState } from "react";
import { usePathname } from "next/navigation";
import { useAuth, useCart } from "../app/providers";

export default function Header() {
  const { user, isLoggedIn, ready, logout } = useAuth();
  const { count, hydrated } = useCart();
  const [menuOpen, setMenuOpen] = useState(false);
  const menuRef = useRef(null);
  const pathname = usePathname();

  useEffect(() => setMenuOpen(false), [pathname]);

  useEffect(() => {
    function onDocClick(e) {
      if (menuRef.current && !menuRef.current.contains(e.target)) setMenuOpen(false);
    }
    function onKey(e) {
      if (e.key === "Escape") setMenuOpen(false);
    }
    document.addEventListener("mousedown", onDocClick);
    document.addEventListener("keydown", onKey);
    return () => {
      document.removeEventListener("mousedown", onDocClick);
      document.removeEventListener("keydown", onKey);
    };
  }, []);

  return (
    <header className="site-header">
      <div className="header-inner">
        <Link href="/" className="brand-mark">
          <img src="/logo.png" alt="Sarko Delivery logo" width="36" height="36" />
          <span>
            Sarko <small>DELIVERY</small>
          </span>
        </Link>

        <nav className="site-nav" aria-label="Main">
          <Link href="/">Shop</Link>
          <Link href="/orders">My orders</Link>
        </nav>

        <div className="header-actions">
          <Link
            href="/cart"
            className="cart-btn"
            aria-label={`Cart, ${hydrated ? count : 0} ${count === 1 ? "item" : "items"}`}
          >
            <CartIcon />
            <span className="cart-label">Cart</span>
            {hydrated && count > 0 && (
              /* keyed on count → pop animation re-runs on every change */
              <span className="cart-badge" key={count} aria-hidden>
                {count}
              </span>
            )}
          </Link>

          {!ready ? null : isLoggedIn ? (
            <div className="account-menu" ref={menuRef}>
              <button
                className="account-btn"
                onClick={() => setMenuOpen((v) => !v)}
                aria-expanded={menuOpen}
                aria-haspopup="menu"
                aria-label="Account menu"
              >
                <UserIcon />
                <span className="account-name">{user?.name || user?.email || "Account"}</span>
              </button>
              {menuOpen && (
                <div className="account-dropdown">
                  <div className="account-email">{user?.email}</div>
                  <Link href="/orders">My orders</Link>
                  <button onClick={() => logout()}>Log out</button>
                </div>
              )}
            </div>
          ) : (
            <Link href="/login" className="btn btn-sm">
              Login
            </Link>
          )}
        </div>
      </div>
    </header>
  );
}

function CartIcon() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
      <circle cx="9" cy="20" r="1.4" />
      <circle cx="17.5" cy="20" r="1.4" />
      <path d="M2.5 3.5h2.6l2.3 12h10.4l2.4-8.5H6" />
    </svg>
  );
}

function UserIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" aria-hidden>
      <circle cx="12" cy="8" r="3.6" />
      <path d="M4.5 20.5c1.2-3.6 4-5.4 7.5-5.4s6.3 1.8 7.5 5.4" />
    </svg>
  );
}
