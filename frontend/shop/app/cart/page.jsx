"use client";

import { useEffect, useMemo, useRef, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { api, imageUrl } from "../../lib/api";
import {
  locName,
  formatPrice,
  discountedPrice,
  hasDiscount,
  effectiveMaxQty,
  CITIES,
} from "../../lib/format";
import { useAuth, useCart } from "../providers";
import { useToast } from "../../components/Toast";
import FadeImg from "../../components/FadeImg";
import EmptyState from "../../components/EmptyState";
import { SkeletonCartLines, SkeletonShiftChips } from "../../components/Skeletons";

export default function CartPage() {
  const router = useRouter();
  const { items, count, setQty, removeItem, clear, city, setCity, hydrated } = useCart();
  const { isLoggedIn, ready } = useAuth();
  const toast = useToast();

  // Coupon
  const [couponInput, setCouponInput] = useState("");
  const [coupon, setCoupon] = useState(null);
  const [couponError, setCouponError] = useState("");
  const [couponLoading, setCouponLoading] = useState(false);

  // Shifts (delivery days)
  const [shifts, setShifts] = useState(null);
  const [shiftId, setShiftId] = useState("");
  const [shiftsError, setShiftsError] = useState(false);

  // Order
  const [placing, setPlacing] = useState(false);
  const [placeError, setPlaceError] = useState("");
  const [placedOrder, setPlacedOrder] = useState(null);

  // Line removal animation
  const [removingIds, setRemovingIds] = useState([]);
  const removalTimers = useRef(new Map());
  useEffect(() => {
    const timers = removalTimers.current;
    return () => timers.forEach((t) => clearTimeout(t));
  }, []);

  useEffect(() => {
    let alive = true;
    setShifts(null);
    setShiftsError(false);
    setShiftId("");
    api(`/shifts?group=${encodeURIComponent(city)}&open=true`)
      .then((data) => {
        if (!alive) return;
        const list = Array.isArray(data) ? data : [];
        setShifts(list);
        if (list.length > 0) setShiftId(String(list[0].id));
      })
      .catch(() => {
        if (!alive) return;
        setShifts([]);
        setShiftsError(true);
      });
    return () => {
      alive = false;
    };
  }, [city]);

  const subtotal = useMemo(
    () => items.reduce((s, i) => s + discountedPrice(i.product) * i.qty, 0),
    [items]
  );

  const couponDiscount = useMemo(() => {
    if (!coupon) return 0;
    const v = Number(coupon.discountValue ?? coupon.value ?? coupon.amount) || 0;
    const type = coupon.discountType ?? coupon.type;
    if (type === "percent") return Math.min(subtotal, (subtotal * v) / 100);
    return Math.min(subtotal, v);
  }, [coupon, subtotal]);

  const total = Math.max(0, subtotal - couponDiscount);

  function removeWithAnim(productId) {
    if (removingIds.includes(productId)) return;
    setRemovingIds((prev) => [...prev, productId]);
    const t = setTimeout(() => {
      removeItem(productId);
      setRemovingIds((prev) => prev.filter((id) => id !== productId));
      removalTimers.current.delete(productId);
    }, 230);
    removalTimers.current.set(productId, t);
  }

  function stepQty(productId, currentQty, delta) {
    const next = currentQty + delta;
    if (next <= 0) removeWithAnim(productId);
    else setQty(productId, next);
  }

  async function applyCoupon(e) {
    e.preventDefault();
    const code = couponInput.trim();
    if (!code) return;
    setCouponLoading(true);
    setCouponError("");
    try {
      const data = await api(`/coupons/${encodeURIComponent(code)}`);
      setCoupon({ ...data, code: data?.code || code });
      toast("Coupon applied", { tone: "success" });
    } catch (err) {
      setCoupon(null);
      setCouponError(err?.status === 404 ? "Coupon not found." : "Couldn't check the coupon. Try again.");
    } finally {
      setCouponLoading(false);
    }
  }

  async function placeOrder() {
    setPlaceError("");
    if (!isLoggedIn) {
      router.push("/login?next=/cart");
      return;
    }
    setPlacing(true);
    try {
      const body = {
        items: items.map((i) => ({ productId: i.product.id, qty: i.qty })),
        ...(shiftId ? { shiftId } : {}),
        ...(coupon?.code ? { couponCode: coupon.code } : {}),
      };
      const order = await api("/orders", { method: "POST", body, auth: true });
      setPlacedOrder({
        order,
        summary: {
          items: items.map((i) => ({
            name: locName(i.product.name),
            qty: i.qty,
            lineTotal: discountedPrice(i.product) * i.qty,
          })),
          subtotal,
          couponDiscount,
          total,
          city,
          shift: (shifts || []).find((s) => String(s.id) === String(shiftId)) || null,
        },
      });
      clear();
      setCoupon(null);
      setCouponInput("");
      toast("Order placed — thank you!", { tone: "success" });
      window.scrollTo({ top: 0 });
    } catch (err) {
      if (err?.status === 401) {
        router.push("/login?next=/cart");
      } else {
        const msg = err?.message || "Couldn't place the order. Please try again.";
        setPlaceError(msg);
        toast(msg, { tone: "error" });
      }
    } finally {
      setPlacing(false);
    }
  }

  /* ---------------- success screen ---------------- */
  if (placedOrder) {
    const s = placedOrder.summary;
    let revealIdx = 0;
    const revealStyle = () => ({ animationDelay: `${0.25 + revealIdx++ * 0.09}s` });
    return (
      <div className="container narrow">
        <div className="success-card">
          <div className="success-icon" aria-hidden>
            <svg className="check-svg" width="34" height="34" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round">
              <path className="check-path" d="M4 12.5l5 5L20 6.5" />
            </svg>
          </div>
          <h1>Order placed!</h1>
          <p className="success-note">
            Thank you — your bread is on its way to the oven.{" "}
            <strong>Pay cash on delivery.</strong>
          </p>

          <div className="summary-box">
            {s.items.map((i, idx) => (
              <div className="summary-row" style={revealStyle()} key={idx}>
                <span>
                  {i.qty} × {i.name}
                </span>
                <span>{formatPrice(i.lineTotal)}</span>
              </div>
            ))}
            {s.couponDiscount > 0 && (
              <div className="summary-row discount-row" style={revealStyle()}>
                <span>Coupon discount</span>
                <span>−{formatPrice(s.couponDiscount)}</span>
              </div>
            )}
            <div className="summary-row total-row" style={revealStyle()}>
              <span>Total (cash on delivery)</span>
              <span>{formatPrice(s.total)}</span>
            </div>
            <div className="summary-meta" style={revealStyle()}>
              Delivery: {s.city}
              {s.shift ? ` — ${s.shift.label || s.shift.date}` : ""}
            </div>
          </div>

          <div className="success-actions">
            <Link href="/orders" className="btn">
              View my orders
            </Link>
            <Link href="/" className="btn secondary">
              Keep shopping
            </Link>
          </div>
        </div>
      </div>
    );
  }

  /* ---------------- restoring from storage ---------------- */
  if (!hydrated) {
    return (
      <div className="container">
        <h1 className="page-title">Your cart</h1>
        <SkeletonCartLines count={3} />
      </div>
    );
  }

  /* ---------------- empty cart ---------------- */
  if (items.length === 0) {
    return (
      <div className="container">
        <h1 className="page-title">Your cart</h1>
        <EmptyState
          variant="cart"
          title="Your cart is empty"
          message="Add some fresh bread and come back."
          action={
            <Link href="/" className="btn btn-sm">
              Browse products
            </Link>
          }
        />
      </div>
    );
  }

  return (
    <div className="container">
      <h1 className="page-title">Your cart</h1>

      <div className="cart-layout">
        {/* ------- line items ------- */}
        <div className="cart-items">
          {items.map(({ product, qty }, idx) => {
            const img = imageUrl(product.imageUrl || product.images?.[0] || product.photos?.[0]);
            const max = effectiveMaxQty(product);
            const unitPrice = discountedPrice(product);
            const removing = removingIds.includes(product.id);
            return (
              <div
                className={`cart-item reveal${removing ? " removing" : ""}`}
                style={{ animationDelay: `${Math.min(idx, 8) * 40}ms` }}
                key={product.id}
              >
                <div className="cart-item-media">
                  {img ? (
                    <FadeImg src={img} alt="" />
                  ) : (
                    <div className="product-placeholder small" />
                  )}
                </div>
                <div className="cart-item-info">
                  <div className="cart-item-name">{locName(product.name)}</div>
                  <div className="cart-item-price">
                    {formatPrice(unitPrice)}
                    {hasDiscount(product) && (
                      <span className="product-price-old">{formatPrice(product.price)}</span>
                    )}
                    {product.unit ? <span className="product-unit"> / {product.unit}</span> : null}
                  </div>
                </div>
                <div className="cart-item-controls">
                  <div className="qty-stepper" role="group" aria-label={`Quantity of ${locName(product.name)}`}>
                    <button
                      onClick={() => stepQty(product.id, qty, -1)}
                      aria-label="Decrease quantity"
                    >
                      −
                    </button>
                    <span className="qty-value" key={qty}>
                      {qty}
                    </span>
                    <button
                      onClick={() => stepQty(product.id, qty, 1)}
                      disabled={qty >= max}
                      aria-label="Increase quantity"
                    >
                      +
                    </button>
                  </div>
                  <div className="cart-line-total">{formatPrice(unitPrice * qty)}</div>
                  <button className="remove-btn" onClick={() => removeWithAnim(product.id)}>
                    Remove
                  </button>
                </div>
              </div>
            );
          })}
        </div>

        {/* ------- checkout panel ------- */}
        <aside className="checkout-panel">
          <h2>Delivery</h2>
          <label className="field-label" id="city-label">
            Your city
          </label>
          <div className="chip-row" role="radiogroup" aria-labelledby="city-label">
            {CITIES.map((c) => (
              <button
                key={c}
                className={`chip${city === c ? " active" : ""}`}
                onClick={() => setCity(c)}
                type="button"
                role="radio"
                aria-checked={city === c}
              >
                {c}
              </button>
            ))}
          </div>

          <label className="field-label" id="day-label">
            Delivery day
          </label>
          {shifts === null ? (
            <SkeletonShiftChips count={3} />
          ) : shifts.length === 0 ? (
            <p className="hint">
              {shiftsError
                ? "Couldn't load delivery days — you can still place the order."
                : `No open delivery days for ${city} right now. You can still place the order and we'll schedule it.`}
            </p>
          ) : (
            <div className="chip-row" role="radiogroup" aria-labelledby="day-label">
              {shifts.map((s) => (
                <button
                  key={s.id}
                  type="button"
                  role="radio"
                  aria-checked={String(s.id) === String(shiftId)}
                  className={`chip${String(s.id) === String(shiftId) ? " active" : ""}`}
                  onClick={() => setShiftId(String(s.id))}
                >
                  {s.label || s.date}
                </button>
              ))}
            </div>
          )}

          <h2>Coupon</h2>
          {coupon ? (
            <div className="coupon-applied">
              <span>
                Code <strong>{coupon.code}</strong> applied
              </span>
              <button
                className="remove-btn"
                onClick={() => {
                  setCoupon(null);
                  setCouponInput("");
                }}
              >
                Remove
              </button>
            </div>
          ) : (
            <form className="coupon-form" onSubmit={applyCoupon}>
              <label className="field-label" htmlFor="coupon" style={{ position: "absolute", width: 1, height: 1, overflow: "hidden", clip: "rect(0 0 0 0)" }}>
                Coupon code
              </label>
              <input
                id="coupon"
                className="input"
                placeholder="Coupon code"
                value={couponInput}
                onChange={(e) => setCouponInput(e.target.value)}
                autoComplete="off"
              />
              <button className="btn btn-sm secondary" disabled={couponLoading || !couponInput.trim()}>
                {couponLoading ? (
                  <>
                    <span className="spinner" aria-hidden /> Checking…
                  </>
                ) : (
                  "Apply"
                )}
              </button>
            </form>
          )}
          {couponError && <p className="error-text">{couponError}</p>}

          <div className="summary-box">
            <div className="summary-row">
              <span>Subtotal</span>
              <span>{formatPrice(subtotal)}</span>
            </div>
            {couponDiscount > 0 && (
              <div className="summary-row discount-row">
                <span>Coupon</span>
                <span>−{formatPrice(couponDiscount)}</span>
              </div>
            )}
            <div className="summary-row">
              <span>Delivery</span>
              <span className="free-tag">Free</span>
            </div>
            <div className="summary-row total-row">
              <span>Total</span>
              <span>{formatPrice(total)}</span>
            </div>
          </div>

          {placeError && <p className="error-text">{placeError}</p>}

          <button className="btn btn-block" onClick={placeOrder} disabled={placing || items.length === 0}>
            {placing ? (
              <>
                <span className="spinner" aria-hidden /> Placing order…
              </>
            ) : ready && !isLoggedIn ? (
              "Log in to checkout"
            ) : (
              "Place order"
            )}
          </button>
          <p className="hint center">Pay cash when your order arrives.</p>
        </aside>
      </div>

      {/* ------- sticky place-order bar (mobile only, via CSS) ------- */}
      <div className="cart-mobile-bar">
        <div className="cartbar-info">
          <span className="cartbar-count">
            {count} {count === 1 ? "item" : "items"} · {city}
          </span>
          <span className="cartbar-total">{formatPrice(total)}</span>
        </div>
        <button className="btn btn-sm" onClick={placeOrder} disabled={placing}>
          {placing ? (
            <>
              <span className="spinner" aria-hidden /> Placing…
            </>
          ) : ready && !isLoggedIn ? (
            "Log in to order"
          ) : (
            "Place order"
          )}
        </button>
      </div>
    </div>
  );
}
