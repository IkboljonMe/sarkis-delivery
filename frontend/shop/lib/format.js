// Localization + money helpers.

/** Pick a localized name: prefer the active locale, then English, fall back to the first value. */
export function locName(obj, locale = "en") {
  if (!obj) return "";
  if (typeof obj === "string") return obj;
  if (obj[locale]) return obj[locale];
  if (obj.en) return obj.en;
  const first = Object.values(obj).find((v) => typeof v === "string" && v);
  return first || "";
}

const eur = new Intl.NumberFormat("de-DE", {
  style: "currency",
  currency: "EUR",
});

export function formatPrice(value) {
  const n = Number(value);
  return eur.format(Number.isFinite(n) ? n : 0);
}

/** Effective price after the product's own discount. */
export function discountedPrice(product) {
  const price = Number(product?.price) || 0;
  const v = Number(product?.discountValue) || 0;
  if (product?.discountType === "percent") return Math.max(0, price * (1 - v / 100));
  if (product?.discountType === "fixed") return Math.max(0, price - v);
  return price;
}

export function hasDiscount(product) {
  return (
    product?.discountType &&
    product.discountType !== "none" &&
    Number(product.discountValue) > 0
  );
}

export function discountLabel(product) {
  if (!hasDiscount(product)) return "";
  if (product.discountType === "percent") return `−${Number(product.discountValue)}%`;
  return `−${formatPrice(product.discountValue)}`;
}

/** Effective max quantity: 0/undefined = unlimited → default cap of 10. */
export function effectiveMaxQty(product) {
  const m = Number(product?.maxQty) || 0;
  return m > 0 ? m : 10;
}

export const CITIES = ["Berlin", "Hamburg", "Frankfurt", "München"];

export const ORDER_STATUS_LABELS = {
  pending: "Pending",
  confirmed: "Confirmed",
  on_the_way: "On the way",
  delivered: "Delivered",
  cancelled: "Cancelled",
};
