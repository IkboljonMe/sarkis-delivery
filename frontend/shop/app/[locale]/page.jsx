"use client";

import { useCallback, useEffect, useState } from "react";
import Link from "next/link";
import { useTranslations, useLocale } from "next-intl";
import { api, imageUrl } from "../../lib/api";
import { locName } from "../../lib/format";
import ProductCard from "../../components/ProductCard";
import FadeImg from "../../components/FadeImg";
import { SkeletonCategoryGrid, SkeletonProductGrid } from "../../components/Skeletons";
import EmptyState from "../../components/EmptyState";

export default function ShopHome() {
  const [categories, setCategories] = useState(null);
  const [products, setProducts] = useState(null);
  const [error, setError] = useState(false);
  const [attempt, setAttempt] = useState(0);
  const t = useTranslations("home");
  const locale = useLocale();

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
          title={t("errorTitle")}
          message={t("errorMessage")}
          action={
            <button className="btn btn-sm" onClick={retry}>
              {t("retry")}
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
          {t("heroTitleLine1")}
          <span className="grad-text">{t("heroTitleLine2")}</span>
        </h1>
        <p>{t("heroSub")}</p>
      </section>

      <section>
        <h2 className="section-heading">{t("categories")}</h2>
        {categories === null ? (
          <SkeletonCategoryGrid />
        ) : categories.length === 0 ? (
          <EmptyState title={t("noCategoriesTitle")} message={t("noCategoriesMessage")} />
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
                      {locName(c.name, locale).slice(0, 1).toUpperCase()}
                    </span>
                  )}
                  <span className="category-name">{locName(c.name, locale)}</span>
                </Link>
              ))}
          </div>
        )}
      </section>

      <section>
        <h2 className="section-heading">{t("allProducts")}</h2>
        {products === null ? (
          <SkeletonProductGrid />
        ) : products.length === 0 ? (
          <EmptyState title={t("noProductsTitle")} message={t("noProductsMessage")} />
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
