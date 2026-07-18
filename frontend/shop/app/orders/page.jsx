"use client";

import { useCallback, useEffect, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { api } from "../../lib/api";
import { formatPrice, ORDER_STATUS_LABELS, locName } from "../../lib/format";
import { useAuth } from "../providers";
import { SkeletonOrders } from "../../components/Skeletons";
import EmptyState from "../../components/EmptyState";

export default function OrdersPage() {
  const router = useRouter();
  const { isLoggedIn, ready } = useAuth();
  const [orders, setOrders] = useState(null);
  const [error, setError] = useState(false);
  const [attempt, setAttempt] = useState(0);

  useEffect(() => {
    if (!ready) return;
    if (!isLoggedIn) {
      router.replace("/login?next=/orders");
      return;
    }
    let alive = true;
    api("/orders/mine", { auth: true })
      .then((data) => alive && setOrders(Array.isArray(data) ? data : []))
      .catch((e) => {
        if (!alive) return;
        if (e?.status === 401) router.replace("/login?next=/orders");
        else setError(true);
      });
    return () => {
      alive = false;
    };
  }, [ready, isLoggedIn, router, attempt]);

  const retry = useCallback(() => {
    setError(false);
    setOrders(null);
    setAttempt((a) => a + 1);
  }, []);

  return (
    <div className="container narrow-wide">
      <h1 className="page-title">My orders</h1>

      {error ? (
        <EmptyState
          variant="oven"
          title="Couldn't load your orders"
          message="Please check your connection and try again."
          action={
            <button className="btn btn-sm" onClick={retry}>
              Retry
            </button>
          }
        />
      ) : orders === null ? (
        <SkeletonOrders count={4} />
      ) : orders.length === 0 ? (
        <EmptyState
          variant="orders"
          title="No orders yet"
          message="Your orders will show up here after your first purchase."
          action={
            <Link href="/" className="btn btn-sm">
              Start shopping
            </Link>
          }
        />
      ) : (
        <div className="orders-list">
          {orders.map((o, i) => (
            <div
              className="order-card reveal"
              style={{ animationDelay: `${Math.min(i, 9) * 50}ms` }}
              key={o.id}
            >
              <div className="order-head">
                <div>
                  <span className="order-id">Order #{shortId(o.id)}</span>
                  {o.createdAt && (
                    <span className="order-date">
                      {new Date(o.createdAt).toLocaleDateString("de-DE", {
                        day: "2-digit",
                        month: "short",
                        year: "numeric",
                      })}
                    </span>
                  )}
                </div>
                <StatusChip status={o.status} />
              </div>

              {Array.isArray(o.items) && o.items.length > 0 && (
                <ul className="order-items">
                  {o.items.map((it, idx) => (
                    <li key={idx}>
                      {it.qty ?? it.quantity ?? 1} ×{" "}
                      {locName(it.product?.name) || locName(it.name) || it.productName || "Item"}
                    </li>
                  ))}
                </ul>
              )}

              <div className="order-foot">
                {o.shift?.label || o.shift?.date ? (
                  <span className="order-shift">Delivery: {o.shift.label || o.shift.date}</span>
                ) : (
                  <span />
                )}
                {orderTotal(o) != null && (
                  <span className="order-total">{formatPrice(orderTotal(o))}</span>
                )}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

function shortId(id) {
  const s = String(id ?? "");
  return s.length > 8 ? s.slice(-8) : s;
}

function orderTotal(o) {
  const t = o.total ?? o.totalPrice ?? o.amount;
  return t != null ? Number(t) : null;
}

function StatusChip({ status }) {
  const key = String(status || "pending").toLowerCase();
  const label = ORDER_STATUS_LABELS[key] || status || "Unknown";
  return <span className={`status-chip status-${key}`}>{label}</span>;
}
