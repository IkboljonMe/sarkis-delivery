// Small API client every fetch goes through.
// - Prefixes the backend base + /v1
// - Attaches the Bearer token for authed calls
// - Transparently refreshes the access token once on 401 and retries

const RAW_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:3000";
export const API_BASE = RAW_BASE.replace(/\/+$/, "");

const AUTH_KEY = "sarko_auth";

export class ApiError extends Error {
  constructor(message, status, body) {
    super(message);
    this.status = status;
    this.body = body;
  }
}

/* ---------------- auth token storage (localStorage) ---------------- */

export function getAuth() {
  if (typeof window === "undefined") return null;
  try {
    const raw = window.localStorage.getItem(AUTH_KEY);
    return raw ? JSON.parse(raw) : null;
  } catch {
    return null;
  }
}

export function setAuth(auth) {
  if (typeof window === "undefined") return;
  if (auth) window.localStorage.setItem(AUTH_KEY, JSON.stringify(auth));
  else window.localStorage.removeItem(AUTH_KEY);
  window.dispatchEvent(new Event("sarko-auth-changed"));
}

/* ---------------- core fetcher ---------------- */

async function doFetch(path, { method = "GET", body, token } = {}) {
  const headers = {};
  if (body !== undefined) headers["Content-Type"] = "application/json";
  if (token) headers["Authorization"] = `Bearer ${token}`;

  const res = await fetch(`${API_BASE}/v1${path}`, {
    method,
    headers,
    body: body !== undefined ? JSON.stringify(body) : undefined,
  });

  let data = null;
  const text = await res.text();
  if (text) {
    try {
      data = JSON.parse(text);
    } catch {
      data = text;
    }
  }

  if (!res.ok) {
    const msg =
      (data && (Array.isArray(data.message) ? data.message.join(", ") : data.message)) ||
      `Request failed (${res.status})`;
    throw new ApiError(msg, res.status, data);
  }
  return data;
}

let refreshPromise = null;

async function refreshTokens() {
  // Single-flight: concurrent 401s share one refresh call.
  if (!refreshPromise) {
    refreshPromise = (async () => {
      const auth = getAuth();
      if (!auth?.refreshToken) throw new ApiError("Not logged in", 401);
      try {
        const data = await doFetch("/auth/refresh", {
          method: "POST",
          body: { refreshToken: auth.refreshToken },
        });
        const next = { ...auth, ...data };
        setAuth(next);
        return next;
      } catch (e) {
        setAuth(null); // refresh token dead — log out locally
        throw e;
      } finally {
        refreshPromise = null;
      }
    })();
  }
  return refreshPromise;
}

/**
 * api("/products?categoryId=x") — public call
 * api("/orders", { method: "POST", body, auth: true }) — authed call
 */
export async function api(path, { method, body, auth = false } = {}) {
  if (!auth) return doFetch(path, { method, body });

  const stored = getAuth();
  if (!stored?.accessToken) throw new ApiError("Not logged in", 401);

  try {
    return await doFetch(path, { method, body, token: stored.accessToken });
  } catch (e) {
    if (e instanceof ApiError && e.status === 401) {
      const refreshed = await refreshTokens();
      return doFetch(path, { method, body, token: refreshed.accessToken });
    }
    throw e;
  }
}

/* ---------------- helpers ---------------- */

/** API image paths may be relative /uploads/... — prefix with the API base. */
export function imageUrl(path) {
  if (!path) return null;
  if (/^https?:\/\//i.test(path)) return path;
  return `${API_BASE}${path.startsWith("/") ? "" : "/"}${path}`;
}
