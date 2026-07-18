"use client";

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
} from "react";
import { api, getAuth, setAuth } from "../lib/api";
import { effectiveMaxQty, CITIES } from "../lib/format";
import { ToastProvider } from "../components/Toast";

/* ================= Auth ================= */

const AuthContext = createContext(null);

export function useAuth() {
  return useContext(AuthContext);
}

function AuthProvider({ children }) {
  const [auth, setAuthState] = useState(null);
  const [ready, setReady] = useState(false);

  useEffect(() => {
    const sync = () => setAuthState(getAuth());
    sync();
    setReady(true);
    window.addEventListener("sarko-auth-changed", sync);
    window.addEventListener("storage", sync);
    return () => {
      window.removeEventListener("sarko-auth-changed", sync);
      window.removeEventListener("storage", sync);
    };
  }, []);

  const login = useCallback(async (email, password) => {
    const data = await api("/auth/email/login", {
      method: "POST",
      body: { email, password },
    });
    setAuth(data);
    return data;
  }, []);

  const register = useCallback(async (email, password, name) => {
    const data = await api("/auth/email/register", {
      method: "POST",
      body: { email, password, ...(name ? { name } : {}) },
    });
    setAuth(data);
    return data;
  }, []);

  const loginWithGoogle = useCallback(async (idToken) => {
    const data = await api("/auth/google", { method: "POST", body: { idToken } });
    setAuth(data);
    return data;
  }, []);

  const logout = useCallback(async () => {
    const current = getAuth();
    setAuth(null);
    if (current?.refreshToken) {
      try {
        await api("/auth/logout", {
          method: "POST",
          body: { refreshToken: current.refreshToken },
        });
      } catch {
        // best effort — local logout already done
      }
    }
  }, []);

  const value = useMemo(
    () => ({
      user: auth?.user || null,
      isLoggedIn: !!auth?.accessToken,
      ready,
      login,
      register,
      loginWithGoogle,
      logout,
    }),
    [auth, ready, login, register, loginWithGoogle, logout]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

/* ================= Cart ================= */

const CART_KEY = "sarko_cart";
const CITY_KEY = "sarko_city";

const CartContext = createContext(null);

export function useCart() {
  return useContext(CartContext);
}

function CartProvider({ children }) {
  const [items, setItems] = useState([]); // [{ product, qty }]
  const [city, setCityState] = useState(CITIES[0]);
  const [hydrated, setHydrated] = useState(false);

  useEffect(() => {
    try {
      const raw = window.localStorage.getItem(CART_KEY);
      if (raw) {
        const parsed = JSON.parse(raw);
        if (Array.isArray(parsed)) setItems(parsed.filter((i) => i?.product?.id));
      }
      const savedCity = window.localStorage.getItem(CITY_KEY);
      if (savedCity && CITIES.includes(savedCity)) setCityState(savedCity);
    } catch {
      // corrupted storage — start fresh
    }
    setHydrated(true);
  }, []);

  useEffect(() => {
    if (!hydrated) return;
    try {
      window.localStorage.setItem(CART_KEY, JSON.stringify(items));
    } catch {}
  }, [items, hydrated]);

  const setCity = useCallback((c) => {
    setCityState(c);
    try {
      window.localStorage.setItem(CITY_KEY, c);
    } catch {}
  }, []);

  const addItem = useCallback((product, qty = 1) => {
    setItems((prev) => {
      const max = effectiveMaxQty(product);
      const existing = prev.find((i) => i.product.id === product.id);
      if (existing) {
        return prev.map((i) =>
          i.product.id === product.id
            ? { ...i, product, qty: Math.min(max, i.qty + qty) }
            : i
        );
      }
      return [...prev, { product, qty: Math.min(max, Math.max(1, qty)) }];
    });
  }, []);

  const setQty = useCallback((productId, qty) => {
    setItems((prev) =>
      prev
        .map((i) =>
          i.product.id === productId
            ? { ...i, qty: Math.min(effectiveMaxQty(i.product), Math.max(0, qty)) }
            : i
        )
        .filter((i) => i.qty > 0)
    );
  }, []);

  const removeItem = useCallback((productId) => {
    setItems((prev) => prev.filter((i) => i.product.id !== productId));
  }, []);

  const clear = useCallback(() => setItems([]), []);

  const count = useMemo(() => items.reduce((s, i) => s + i.qty, 0), [items]);

  const value = useMemo(
    () => ({ items, count, city, setCity, addItem, setQty, removeItem, clear, hydrated }),
    [items, count, city, setCity, addItem, setQty, removeItem, clear, hydrated]
  );

  return <CartContext.Provider value={value}>{children}</CartContext.Provider>;
}

export default function Providers({ children }) {
  return (
    <AuthProvider>
      <CartProvider>
        <ToastProvider>{children}</ToastProvider>
      </CartProvider>
    </AuthProvider>
  );
}
