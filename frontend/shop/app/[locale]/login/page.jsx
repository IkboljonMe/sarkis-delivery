"use client";

import { Suspense, useEffect, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { useAuth } from "../../providers";

const GOOGLE_CLIENT_ID = process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID || "";

export default function LoginPage() {
  return (
    <Suspense fallback={<div className="container narrow" />}>
      <LoginInner />
    </Suspense>
  );
}

function LoginInner() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const { login, register, loginWithGoogle, isLoggedIn, ready } = useAuth();

  const [mode, setMode] = useState("login"); // login | register
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [name, setName] = useState("");
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);

  const rawNext = searchParams.get("next") || "/";
  const next = rawNext.startsWith("/") ? rawNext : "/"; // same-site only

  useEffect(() => {
    if (ready && isLoggedIn) router.replace(next);
  }, [ready, isLoggedIn, next, router]);

  async function submit(e) {
    e.preventDefault();
    setError("");
    setBusy(true);
    try {
      if (mode === "login") await login(email.trim(), password);
      else await register(email.trim(), password, name.trim() || undefined);
      router.replace(next);
    } catch (err) {
      setError(friendlyAuthError(err, mode));
    } finally {
      setBusy(false);
    }
  }

  // Google sign-in: enabled only when a client ID is configured. The actual
  // Google Identity Services wiring plugs in here once the ID exists —
  // the backend endpoint (POST /v1/auth/google { idToken }) is already handled
  // by loginWithGoogle().
  async function googleSignIn() {
    if (!GOOGLE_CLIENT_ID) return;
    setError(
      "Google sign-in is configured but the sign-in flow needs the Google Identity Services script — coming soon."
    );
  }

  return (
    <div className="container narrow">
      <div className="auth-card">
        <h1>{mode === "login" ? "Welcome back" : "Create your account"}</h1>
        <p className="auth-sub">
          {mode === "login"
            ? "Log in to place orders and track deliveries."
            : "Register to order fresh bread to your door."}
        </p>

        <form onSubmit={submit} className="auth-form">
          {mode === "register" && (
            <div className="field">
              <label className="field-label" htmlFor="name">
                Name <span className="optional">(optional)</span>
              </label>
              <input
                id="name"
                className="input"
                value={name}
                onChange={(e) => setName(e.target.value)}
                autoComplete="name"
                placeholder="Your name"
              />
            </div>
          )}

          <div className="field">
            <label className="field-label" htmlFor="email">
              Email
            </label>
            <input
              id="email"
              className="input"
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              autoComplete="email"
              placeholder="you@example.com"
            />
          </div>

          <div className="field">
            <label className="field-label" htmlFor="password">
              Password
            </label>
            <input
              id="password"
              className="input"
              type="password"
              required
              minLength={6}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              autoComplete={mode === "login" ? "current-password" : "new-password"}
              placeholder="••••••••"
            />
          </div>

          {error && <p className="error-text">{error}</p>}

          <button className="btn btn-block" disabled={busy}>
            {busy ? (
              <>
                <span className="spinner" aria-hidden />{" "}
                {mode === "login" ? "Logging in…" : "Creating account…"}
              </>
            ) : mode === "login" ? (
              "Log in"
            ) : (
              "Create account"
            )}
          </button>
        </form>

        <div className="divider">
          <span>or</span>
        </div>

        <div className="google-wrap" title={GOOGLE_CLIENT_ID ? "" : "Google sign-in — coming soon"}>
          <button
            type="button"
            className="btn secondary btn-block google-btn"
            disabled={!GOOGLE_CLIENT_ID}
            onClick={googleSignIn}
          >
            <GoogleIcon /> Continue with Google
          </button>
          {!GOOGLE_CLIENT_ID && <span className="tooltip">Coming soon</span>}
        </div>

        <p className="auth-toggle">
          {mode === "login" ? "New to Sarko?" : "Already have an account?"}{" "}
          <button
            type="button"
            className="link-btn"
            onClick={() => {
              setMode(mode === "login" ? "register" : "login");
              setError("");
            }}
          >
            {mode === "login" ? "Create an account" : "Log in"}
          </button>
        </p>
      </div>
    </div>
  );
}

function friendlyAuthError(err, mode) {
  // Network failure (fetch throws without a status)
  if (!err?.status) return "Can't reach the bakery — check your connection and try again.";
  if (mode === "login" && (err.status === 401 || err.status === 403)) {
    return "Wrong email or password. Please try again.";
  }
  if (mode === "register" && err.status === 409) {
    return "An account with this email already exists — try logging in instead.";
  }
  // Validation messages from the API are usually readable; fall back to a generic line.
  return err.message || "Something went wrong. Please try again.";
}

function GoogleIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" aria-hidden>
      <path fill="#4285F4" d="M23.5 12.3c0-.9-.1-1.5-.3-2.2H12v4.1h6.5c-.1 1.1-.8 2.7-2.4 3.8l-.02.15 3.5 2.7.24.02c2.2-2 3.5-5 3.5-8.6z" />
      <path fill="#34A853" d="M12 24c3.2 0 5.9-1.1 7.9-2.9l-3.8-2.9c-1 .7-2.4 1.2-4.1 1.2-3.2 0-5.8-2.1-6.8-4.9l-.14.01-3.7 2.8-.05.13C3.3 21.3 7.3 24 12 24z" />
      <path fill="#FBBC05" d="M5.2 14.5c-.25-.7-.4-1.6-.4-2.5s.15-1.8.4-2.5l-.01-.16-3.7-2.9-.12.06C.5 8.1 0 10 0 12s.5 3.9 1.4 5.5l3.8-3z" />
      <path fill="#EA4335" d="M12 4.7c2.3 0 3.8 1 4.7 1.8l3.4-3.3C18 1.2 15.2 0 12 0 7.3 0 3.3 2.7 1.4 6.5l3.8 3c1-2.8 3.6-4.8 6.8-4.8z" />
    </svg>
  );
}
