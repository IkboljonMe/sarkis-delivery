"use client";

import { useEffect, useRef, useState } from "react";
import { imageUrl } from "../lib/api";
import {
  locName,
  formatPrice,
  discountedPrice,
  hasDiscount,
  discountLabel,
  effectiveMaxQty,
} from "../lib/format";
import { useCart } from "../app/providers";
import { useToast } from "./Toast";
import { useLocale, useTranslations } from "next-intl";
import FadeImg from "./FadeImg";

export default function ProductCard({ product, index = 0 }) {
  const { addItem } = useCart();
  const toast = useToast();
  const locale = useLocale();
  const t = useTranslations("product");
  const [qty, setQty] = useState(1);
  const [added, setAdded] = useState(false);
  const addedTimer = useRef(null);

  useEffect(() => () => clearTimeout(addedTimer.current), []);

  const max = effectiveMaxQty(product);
  const img = imageUrl(product.imageUrl || product.images?.[0] || product.photos?.[0]);
  const discounted = hasDiscount(product);
  const finalPrice = discountedPrice(product);
  const name = locName(product.name, locale);

  function add() {
    addItem(product, qty);
    toast(t("addedToCart", { name }), { tone: "success" });
    setAdded(true);
    clearTimeout(addedTimer.current);
    addedTimer.current = setTimeout(() => setAdded(false), 1400);
  }

  return (
    <article
      className="product-card reveal"
      style={{ animationDelay: `${Math.min(index, 11) * 45}ms` }}
    >
      <div className="product-media">
        {img ? (
          <FadeImg src={img} alt={name} loading="lazy" />
        ) : (
          <div className="product-placeholder" aria-hidden>
            <BreadIcon />
          </div>
        )}
        {discounted && <span className="discount-badge">{discountLabel(product)}</span>}
      </div>

      <div className="product-body">
        <h3 className="product-name">{name}</h3>
        {locName(product.description, locale) && (
          <p className="product-desc">{locName(product.description, locale)}</p>
        )}

        <div className="product-price-row">
          <span className="product-price">{formatPrice(finalPrice)}</span>
          {discounted && (
            <span className="product-price-old">{formatPrice(product.price)}</span>
          )}
          {product.unit && <span className="product-unit">/ {product.unit}</span>}
        </div>

        <div className="product-actions">
          <div className="qty-stepper" role="group" aria-label={`Quantity of ${name}`}>
            <button
              type="button"
              onClick={() => setQty((q) => Math.max(1, q - 1))}
              disabled={qty <= 1}
              aria-label="Decrease quantity"
            >
              −
            </button>
            {/* keyed on qty → quick fade/slide on change */}
            <span className="qty-value" key={qty} aria-live="polite">
              {qty}
            </span>
            <button
              type="button"
              onClick={() => setQty((q) => Math.min(max, q + 1))}
              disabled={qty >= max}
              aria-label="Increase quantity"
            >
              +
            </button>
          </div>
          <button
            type="button"
            className={`btn btn-sm add-btn${added ? " added" : ""}`}
            onClick={add}
            aria-label={`Add ${name} to cart`}
          >
            {added ? t("added") : t("add")}
          </button>
        </div>
      </div>
    </article>
  );
}

function BreadIcon() {
  return (
    <svg width="44" height="44" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" aria-hidden>
      <path d="M4 10c0-2.8 3.6-4.5 8-4.5s8 1.7 8 4.5c0 1.2-.7 2-1.5 2.4V17a1.5 1.5 0 0 1-1.5 1.5H7A1.5 1.5 0 0 1 5.5 17v-4.6C4.7 12 4 11.2 4 10z" />
      <path d="M9.5 9v4M14.5 9v4" />
    </svg>
  );
}
