// Shimmer skeleton family — each mirrors the exact layout it stands in for.

const stagger = (i) => ({ animationDelay: `${Math.min(i, 11) * 45}ms` });

export function SkeletonCategoryGrid({ count = 6 }) {
  return (
    <div className="category-grid" aria-hidden>
      {Array.from({ length: count }).map((_, i) => (
        <div className="category-card skeleton-card reveal" style={stagger(i)} key={i}>
          <div className="skeleton skeleton-circle" />
          <div className="skeleton skeleton-line" style={{ width: "70%" }} />
        </div>
      ))}
    </div>
  );
}

export function SkeletonProductGrid({ count = 8 }) {
  return (
    <div className="product-grid" aria-hidden>
      {Array.from({ length: count }).map((_, i) => (
        <div className="product-card skeleton-card reveal" style={stagger(i)} key={i}>
          <div className="skeleton skeleton-media" />
          <div className="product-body">
            <div className="skeleton skeleton-line" style={{ width: "80%" }} />
            <div className="skeleton skeleton-line" style={{ width: "55%" }} />
            <div className="skeleton skeleton-line" style={{ width: "40%", height: 24, marginTop: 12 }} />
            <div
              className="product-actions skeleton-actions"
              style={{ display: "flex", gap: 10, marginTop: 10 }}
            >
              <div className="skeleton skeleton-stepper" />
              <div className="skeleton skeleton-btn" />
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}

export function SkeletonCartLines({ count = 3 }) {
  return (
    <div className="cart-items" aria-hidden>
      {Array.from({ length: count }).map((_, i) => (
        <div className="cart-item skeleton-card reveal" style={stagger(i)} key={i}>
          <div className="skeleton skeleton-thumb" />
          <div>
            <div className="skeleton skeleton-line" style={{ width: "60%" }} />
            <div className="skeleton skeleton-line" style={{ width: "35%" }} />
          </div>
          <div className="cart-item-controls">
            <div className="skeleton skeleton-stepper" />
            <div className="skeleton skeleton-line" style={{ width: 64 }} />
          </div>
        </div>
      ))}
    </div>
  );
}

export function SkeletonShiftChips({ count = 3 }) {
  return (
    <div className="chip-row" aria-hidden>
      {Array.from({ length: count }).map((_, i) => (
        <div className="skeleton skeleton-chip" key={i} />
      ))}
    </div>
  );
}

export function SkeletonOrders({ count = 3 }) {
  return (
    <div className="orders-list" aria-hidden>
      {Array.from({ length: count }).map((_, i) => (
        <div className="order-card skeleton-card reveal" style={stagger(i)} key={i}>
          <div className="order-head">
            <div style={{ flex: 1 }}>
              <div className="skeleton skeleton-line" style={{ width: "45%" }} />
            </div>
            <div className="skeleton skeleton-status" />
          </div>
          <div className="skeleton skeleton-line" style={{ width: "55%" }} />
          <div className="skeleton skeleton-line" style={{ width: "40%" }} />
          <div className="order-foot">
            <div className="skeleton skeleton-line" style={{ width: 130 }} />
            <div className="skeleton skeleton-line" style={{ width: 70 }} />
          </div>
        </div>
      ))}
    </div>
  );
}
