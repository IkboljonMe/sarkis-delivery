import { getTranslations } from "next-intl/server";
import {
  APP_NAME,
  PLAY_URL,
  APPSTORE_URL,
  SHOP_URL,
  SUPPORT_EMAIL,
  CONTACT_WHATSAPP,
} from "../config";
import RevealInit from "../components/RevealInit";
import MobileNav from "../components/MobileNav";
import BackToTop from "../components/BackToTop";
import LanguageSwitcher from "../components/LanguageSwitcher";
import PromoRibbon from "../components/PromoRibbon";
import DeliveryScene from "../components/DeliveryScene";

const CITIES = ["Berlin", "Hamburg", "Frankfurt", "München"];

export default async function Home({ params: { locale } }) {
  const t = await getTranslations({ locale });

  const NAV_LINKS = [
    { href: "#how-it-works", label: t("nav.howItWorks") },
    { href: "#cities", label: t("nav.cities") },
    { href: "#get-the-app", label: t("nav.getTheApp") },
  ];

  return (
    <>
      <RevealInit />

      <div className="top-stack">
        <PromoRibbon
          text={t("promo.ribbon")}
          cta={t("promo.ribbonCta")}
          href={SHOP_URL}
          dismissLabel={t("promo.dismiss")}
        />

        <header className="site-header">
          <div className="header-inner">
            <a href="/" className="brand-mark">
              <img src="/logo.png" alt={`${APP_NAME} logo`} width="38" height="38" />
              <span>
                Sarko <small>DELIVERY</small>
              </span>
            </a>
            <nav className="site-nav" aria-label="Main">
              {NAV_LINKS.map((link) => (
                <a key={link.href} href={link.href}>
                  {link.label}
                </a>
              ))}
            </nav>
            <div className="header-actions">
              <LanguageSwitcher locale={locale} label={t("nav.language")} />
              <a className="btn btn-nav" href={SHOP_URL}>
                {t("nav.orderOnline")}
              </a>
              <MobileNav
                links={NAV_LINKS}
                cta={{ href: SHOP_URL, label: t("nav.orderOnline") }}
                contact={{ href: CONTACT_WHATSAPP, label: t("nav.chatOnWhatsapp") }}
                locale={locale}
                languageLabel={t("nav.language")}
              />
            </div>
          </div>
        </header>
      </div>

      <main>
        {/* ---------- Hero ---------- */}
        <section className="hero">
          <div className="hero-glow" aria-hidden />
          <div className="section-inner hero-inner">
            <div className="hero-copy">
              <span className="promo-badge anim-rise" aria-label={t("promo.badge")}>
                <span className="promo-badge-pct">−50%</span>
                {t("promo.badge")}
              </span>
              <p className="eyebrow anim-rise d-1">
                {t("hero.eyebrow")}
              </p>
              <h1 className="hero-title">
                <span className="hero-line anim-rise d-1">
                  {t("hero.titleLine1")}
                </span>
                <span className="hero-line anim-rise d-2">
                  <span className="grad-text">{t("hero.titleLine2")}</span>
                </span>
              </h1>
              <p className="hero-sub anim-rise d-3">
                {t("hero.sub")}
              </p>
              <div className="hero-actions anim-rise d-4">
                <a className="btn" href={PLAY_URL} aria-label="Get it on Google Play">
                  <PlayIcon /> {t("hero.googlePlay")}
                </a>
                <a
                  className="btn secondary"
                  href={APPSTORE_URL}
                  aria-label="Download on the App Store"
                >
                  <AppleIcon /> {t("hero.appStore")}
                </a>
              </div>
              <p className="hero-alt anim-rise d-5">
                {t("hero.noApp")} <a href={SHOP_URL}>{t("hero.orderBrowser")}</a>
              </p>
            </div>
            <div className="hero-visual anim-scale d-2" aria-hidden>
              <DeliveryScene caption={t("hero.sceneCaption")} />
            </div>
          </div>
        </section>

        {/* ---------- Features strip ---------- */}
        <section className="features">
          <div className="section-inner features-grid" data-reveal-group>
            <div className="feature">
              <span className="feature-icon"><TruckIcon /></span>
              <h3>{t("features.deliveryTitle")}</h3>
              <p>{t("features.deliverySub")}</p>
            </div>
            <div className="feature">
              <span className="feature-icon"><CashIcon /></span>
              <h3>{t("features.cashTitle")}</h3>
              <p>{t("features.cashSub")}</p>
            </div>
            <div className="feature">
              <span className="feature-icon"><WheatIcon /></span>
              <h3>{t("features.freshTitle")}</h3>
              <p>{t("features.freshSub")}</p>
            </div>
            <div className="feature">
              <span className="feature-icon"><ChatIcon /></span>
              <h3>{t("features.chatTitle")}</h3>
              <p>{t("features.chatSub")}</p>
            </div>
          </div>
        </section>

        {/* ---------- How it works ---------- */}
        <section className="how" id="how-it-works">
          <div className="section-inner">
            <div className="section-head" data-reveal>
              <p className="section-eyebrow">{t("how.eyebrow")}</p>
              <h2 className="section-title">{t("how.title")}</h2>
              <p className="section-sub">
                {t("how.sub")}
              </p>
            </div>
            <div className="steps" data-reveal-group>
              <div className="step">
                <span className="step-num">1</span>
                <h3>{t("how.step1Title")}</h3>
                <p>
                  {t("how.step1Sub")}
                </p>
              </div>
              <div className="step">
                <span className="step-num">2</span>
                <h3>{t("how.step2Title")}</h3>
                <p>
                  {t("how.step2Sub")}
                </p>
              </div>
              <div className="step">
                <span className="step-num">3</span>
                <h3>{t("how.step3Title")}</h3>
                <p>
                  {t("how.step3Sub")}
                </p>
              </div>
            </div>
          </div>
        </section>

        {/* ---------- Cities ---------- */}
        <section className="cities" id="cities">
          <div className="section-inner">
            <div className="section-head" data-reveal>
              <p className="section-eyebrow">{t("cities.eyebrow")}</p>
              <h2 className="section-title">{t("cities.title")}</h2>
              <p className="section-sub">
                {t("cities.sub")}
              </p>
            </div>
            <div className="city-grid" data-reveal-group>
              {CITIES.map((city) => (
                <div className="city-card" key={city}>
                  <PinIcon />
                  <span>{city}</span>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* ---------- Get the app ---------- */}
        <section className="get-app" id="get-the-app">
          <div className="section-inner get-app-card" data-reveal>
            <div className="section-head center">
              <p className="section-eyebrow">{t("getApp.eyebrow")}</p>
              <h2 className="section-title">{t("getApp.title", { app: APP_NAME })}</h2>
              <p className="section-sub">
                {t("getApp.sub")}
              </p>
            </div>
            <div className="hero-actions center-actions">
              <a className="btn" href={PLAY_URL} aria-label="Get it on Google Play">
                <PlayIcon /> {t("hero.googlePlay")}
              </a>
              <a
                className="btn secondary"
                href={APPSTORE_URL}
                aria-label="Download on the App Store"
              >
                <AppleIcon /> {t("hero.appStore")}
              </a>
            </div>
            <p className="hero-alt">
              {t("getApp.preferWeb")}{" "}
              <a href={SHOP_URL}>{t("getApp.orderOnlineFull")}</a>
            </p>
          </div>
        </section>

        {/* ---------- Final CTA ---------- */}
        <section className="final-cta">
          <div className="section-inner" data-reveal>
            <h2 className="cta-title">{t("cta.title")}</h2>
            <p className="section-sub">
              {t("cta.sub")}
            </p>
            <a className="btn btn-lg" href={SHOP_URL}>
              {t("cta.btn")}
            </a>
          </div>
        </section>
      </main>

      <footer className="site-footer">
        <div className="section-inner footer-grid">
          <div className="footer-brand">
            <a href="/" className="brand-mark">
              <img src="/logo.png" alt="" width="32" height="32" />
              <span>
                Sarko <small>DELIVERY</small>
              </span>
            </a>
            <p>
              {t("footer.brandSub")}
            </p>
          </div>
          <div className="footer-col">
            <h4>{t("footer.explore")}</h4>
            {NAV_LINKS.map((link) => (
              <a key={link.href} href={link.href}>
                {link.label}
              </a>
            ))}
          </div>
          <div className="footer-col">
            <h4>{t("footer.contact")}</h4>
            <a href={CONTACT_WHATSAPP}>WhatsApp</a>
            <a href={`mailto:${SUPPORT_EMAIL}`}>{SUPPORT_EMAIL}</a>
          </div>
          <div className="footer-col">
            <h4>{t("footer.legal")}</h4>
            <a href="/privacy">{t("footer.privacy")}</a>
            <a href="/terms">{t("footer.terms")}</a>
            <a href="/delete-account">{t("footer.deleteAccount")}</a>
          </div>
        </div>
        <div className="section-inner footer-bottom">
          <span>
            © {new Date().getFullYear()} {APP_NAME}. {t("footer.allRights")}
          </span>
          <span className="footer-cities">
            Berlin · Hamburg · Frankfurt · München
          </span>
        </div>
      </footer>

      <BackToTop />
    </>
  );
}

/* ---------- Inline SVG icons (hand-drawn, no external assets) ---------- */

function PinIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor" aria-hidden>
      <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5A2.5 2.5 0 1 1 12 6a2.5 2.5 0 0 1 0 5.5z" />
    </svg>
  );
}

function WheatIcon() {
  return (
    <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" aria-hidden>
      <path d="M12 22V8" />
      <path d="M12 8c-3 0-4.5-2-4.5-5C10.5 3 12 5 12 8z" />
      <path d="M12 8c3 0 4.5-2 4.5-5C13.5 3 12 5 12 8z" />
      <path d="M12 14c-3 0-4.5-2-4.5-5 3 0 4.5 2 4.5 5z" />
      <path d="M12 14c3 0 4.5-2 4.5-5-3 0-4.5 2-4.5 5z" />
      <path d="M12 20c-3 0-4.5-2-4.5-5 3 0 4.5 2 4.5 5z" />
      <path d="M12 20c3 0 4.5-2 4.5-5-3 0-4.5 2-4.5 5z" />
    </svg>
  );
}

function TruckIcon() {
  return (
    <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
      <path d="M1 7h13v9H1z" />
      <path d="M14 10h4l3 3v3h-7" />
      <circle cx="6" cy="18.5" r="1.8" />
      <circle cx="17.5" cy="18.5" r="1.8" />
    </svg>
  );
}

function CashIcon() {
  return (
    <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" aria-hidden>
      <rect x="2" y="6" width="20" height="12" rx="2" />
      <circle cx="12" cy="12" r="2.8" />
      <path d="M5.5 9.5h.01M18.5 14.5h.01" />
    </svg>
  );
}

function ChatIcon() {
  return (
    <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
      <path d="M21 12a8 8 0 0 1-8 8H4l1.6-3.2A8 8 0 1 1 21 12z" />
      <path d="M8.5 12h.01M12 12h.01M15.5 12h.01" />
    </svg>
  );
}

function PlayIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden>
      <path d="M4 3.5v17c0 .6.7 1 1.2.7l14.4-8.5c.5-.3.5-1 0-1.3L5.2 2.8C4.7 2.5 4 2.9 4 3.5z" />
    </svg>
  );
}

function AppleIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden>
      <path d="M16.6 12.9c0-2.4 2-3.5 2.1-3.6-1.1-1.7-2.9-1.9-3.5-1.9-1.5-.2-2.9.9-3.7.9-.8 0-1.9-.9-3.2-.8-1.6 0-3.1 1-4 2.4-1.7 2.9-.4 7.3 1.2 9.7.8 1.2 1.8 2.5 3 2.4 1.2 0 1.7-.8 3.2-.8s1.9.8 3.2.8c1.3 0 2.2-1.2 3-2.4.9-1.4 1.3-2.7 1.3-2.8-.1 0-2.6-1-2.6-3.9zM14.2 5.6c.7-.8 1.1-1.9 1-3.1-1 0-2.2.7-2.9 1.5-.6.7-1.2 1.9-1 3 1.1.1 2.2-.6 2.9-1.4z" />
    </svg>
  );
}
