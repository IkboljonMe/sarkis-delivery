"use client";

// Fixed bottom bar on mobile: item count + total + "View cart".
// Visible only when the cart has items and we're not already on /cart.

import Link from "next/link";
import { useEffect, useMemo } from "react";
import { usePathname } from "next/navigation";
import { useCart } from "../app/providers";
import { discountedPrice, formatPrice } from "../lib/format";

export default function MobileCartBar() {
  const { items, count, hydrated } = useCart();
  const pathname = usePathname();
  const visible = hydrated && count > 0 && pathname !== "/cart";

  const total = useMemo(
    () => items.reduce((s, i) => s + discountedPrice(i.product) * i.qty, 0),
    [items]
  );

  // Lets the footer + toast stack make room while the bar is up.
  useEffect(() => {
    document.body.classList.toggle("has-cartbar", visible);
    return () => document.body.classList.remove("has-cartbar");
  }, [visible]);

  if (!visible) return null;

  return (
    <div className="mobile-cart-bar">
      <div className="cartbar-info">
        <span className="cartbar-count">
          {count} {count === 1 ? "item" : "items"} in cart
        </span>
        <span className="cartbar-total">{formatPrice(total)}</span>
      </div>
      <Link href="/cart" className="btn btn-sm">
        View cart →
      </Link>
    </div>
  );
}
