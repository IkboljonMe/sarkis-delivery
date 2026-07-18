"use client";

import { useCallback, useEffect, useState } from "react";
import Link from "next/link";
import { api, imageUrl } from "../lib/api";
import { locName } from "../lib/format";
import ProductCard from "../components/ProductCard";
import FadeImg from "../components/FadeImg";
import { SkeletonCategoryGrid, SkeletonProductGrid } from "../components/Skeletons";
import EmptyState from "../components/EmptyState";

export default function ShopHome() {
  const [categories, setCategories] = useState(null);
  const [products, setProducts] = useState(null);
  const [error, setError] = useState(false);
  const [attempt, setAttempt] = useState(0);

  useEffect(() => {
    let alive = true;
    Promise.all([api("/categories"), api("/products")])
      .then(([cats, prods]) => {
        if (!alive) return;
        setCategories((Array.isArray(cats) ? cats : []).filter((c) => c.isActive !== false));
        setProducts((Array.isArray(prods) ? prods : []).filter((p) => p.isActive !== false));
      })
      .catch(() => alive && setError(true));
    return () => {
      alive = false;
    };
  }, [attempt]);

  const retry = useCallback(() => {
    setError(false);
    setCategories(null);
    setProducts(null);
    setAttempt((a) => a + 1);
  }, []);

  if (error) {
    return (
      <div className="container">
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
      </div>
    );
  }

  return (
    <div className="container">
      <section className="shop-hero">
        <h1>
          Fresh traditional breads, <span className="grad-text">to your door</span>
        </h1>
        <p>Free delivery in Berlin, Hamburg, Frankfurt &amp; München — pay cash on arrival.</p>
      </section>

      <section>
        <h2 className="section-heading">Categories</h2>
        {categories === null ? (
          <SkeletonCategoryGrid />
        ) : categories.length === 0 ? (
          <EmptyState title="No categories yet" message="Check back soon — fresh things are coming." />
        ) : (
          <div className="category-grid">
            {categories
              .slice()
              .sort((a, b) => (a.sortOrder ?? 0) - (b.sortOrder ?? 0))
              .map((c, i) => (
                <Link
                  href={`/category/${c.id}`}
                  className="category-card reveal"
                  style={{ animationDelay: `${Math.min(i, 11) * 45}ms` }}
                  key={c.id}
                >
                  {imageUrl(c.imageUrl) ? (
                    <FadeImg src={imageUrl(c.imageUrl)} alt="" loading="lazy" />
                  ) : (
                    <span className="category-fallback" aria-hidden>
                      {locName(c.name).slice(0, 1).toUpperCase()}
                    </span>
                  )}
                  <span className="category-name">{locName(c.name)}</span>
                </Link>
              ))}
          </div>
        )}
      </section>

      <section>
        <h2 className="section-heading">All products</h2>
        {products === null ? (
          <SkeletonProductGrid />
        ) : products.length === 0 ? (
          <EmptyState title="Nothing on the shelves yet" message="Our bakers are preparing the catalog." />
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
      </section>
    </div>
  );
}
