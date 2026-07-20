"use client";

import { useCallback, useEffect, useState } from "react";
import Link from "next/link";
import { useParams } from "next/navigation";
import { api } from "../../../../lib/api";
import { locName } from "../../../../lib/format";
import ProductCard from "../../../../components/ProductCard";
import { SkeletonProductGrid } from "../../../../components/Skeletons";
import EmptyState from "../../../../components/EmptyState";

export default function CategoryPage() {
  const { id } = useParams();
  const [category, setCategory] = useState(null);
  const [products, setProducts] = useState(null);
  const [error, setError] = useState(false);
  const [attempt, setAttempt] = useState(0);

  useEffect(() => {
    if (!id) return;
    let alive = true;
    Promise.all([
      api("/categories").catch(() => []),
      api(`/products?categoryId=${encodeURIComponent(id)}`),
    ])
      .then(([cats, prods]) => {
        if (!alive) return;
        setCategory((Array.isArray(cats) ? cats : []).find((c) => String(c.id) === String(id)) || null);
        setProducts((Array.isArray(prods) ? prods : []).filter((p) => p.isActive !== false));
      })
      .catch(() => alive && setError(true));
    return () => {
      alive = false;
    };
  }, [id, attempt]);

  const retry = useCallback(() => {
    setError(false);
    setProducts(null);
    setAttempt((a) => a + 1);
  }, []);

  const loading = products === null && !error;

  return (
    <div className="container">
      <Link href="/" className="back-link">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
          <path d="M15 5l-7 7 7 7" />
        </svg>
        Back to shop
      </Link>

      {category ? (
        <h1 className="page-title">{locName(category.name)}</h1>
      ) : loading ? (
        <div className="skeleton skeleton-title" aria-hidden />
      ) : (
        <h1 className="page-title">Category</h1>
      )}

      {error ? (
        <EmptyState
          variant="oven"
          title="Shop is warming up"
          message="We couldn't reach the bakery right now. Please try again in a moment."
          action={
            <button className="btn btn-sm" onClick={retry}>
              Retry
            </button>
          }
        />
      ) : loading ? (
        <SkeletonProductGrid />
      ) : products.length === 0 ? (
        <EmptyState
          title="Nothing here yet"
          message="This category is empty for now."
          action={
            <Link href="/" className="btn btn-sm">
              Back to shop
            </Link>
          }
        />
      ) : (
        <div className="product-grid">
          {products
            .slice()
            .sort((a, b) => (a.sortOrder ?? 0) - (b.sortOrder ?? 0))
            .map((p, i) => (
              <ProductCard product={p} index={i} key={p.id} />
            ))}
        </div>
      )}
    </div>
  );
}
