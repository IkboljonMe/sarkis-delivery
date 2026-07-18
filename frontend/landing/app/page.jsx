import { headers } from "next/headers";
import { redirect } from "next/navigation";
import {
  APP_NAME,
  PLAY_URL,
  APPSTORE_URL,
  SHOP_URL,
  SUPPORT_EMAIL,
  CONTACT_WHATSAPP,
} from "./config";
import RevealInit from "./components/RevealInit";
import MobileNav from "./components/MobileNav";
import BackToTop from "./components/BackToTop";

const CITIES = ["Berlin", "Hamburg", "Frankfurt", "München"];

const NAV_LINKS = [
  { href: "#how-it-works", label: "How it works" },
  { href: "#cities", label: "Cities" },
  { href: "#get-the-app", label: "Get the app" },
];

// Smart download link: detect the device from the User-Agent and send the
// visitor straight to the right store. Desktop / unknown UAs see the landing.
export default function Home() {
  const ua = headers().get("user-agent") || "";
  const isAndroid = /android/i.test(ua);
  const isIOS = /iphone|ipad|ipod/i.test(ua) || (/mac/i.test(ua) && /mobile/i.test(ua));

  if (isAndroid) redirect(PLAY_URL);
  if (isIOS) redirect(APPSTORE_URL);

  return (
    <>
      <RevealInit />

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
            <a className="btn btn-nav" href={SHOP_URL}>
              Order online
            </a>
            <MobileNav
              links={NAV_LINKS}
              cta={{ href: SHOP_URL, label: "Order online" }}
              contact={{ href: CONTACT_WHATSAPP, label: "Chat on WhatsApp" }}
            />
          </div>
        </div>
      </header>

      <main>
        {/* ---------- Hero ---------- */}
        <section className="hero">
          <div className="hero-glow" aria-hidden />
          <div className="section-inner hero-inner">
            <div className="hero-copy">
              <p className="eyebrow anim-rise">
                Baked with tradition · Delivered in Germany
              </p>
              <h1 className="hero-title">
                <span className="hero-line anim-rise d-1">
                  Fresh traditional breads,
                </span>
                <span className="hero-line anim-rise d-2">
                  <span className="grad-text">delivered to your door</span>
                </span>
              </h1>
              <p className="hero-sub anim-rise d-3">
                National and traditional breads and baked goods, baked to order
                and brought straight to your home. Free delivery — pay cash when
                it arrives.
              </p>
              <div className="hero-actions anim-rise d-4">
                <a className="btn" href={PLAY_URL} aria-label="Get it on Google Play">
                  <PlayIcon /> Google Play
                </a>
                <a
                  className="btn secondary"
                  href={APPSTORE_URL}
                  aria-label="Download on the App Store"
                >
                  <AppleIcon /> App Store
                </a>
              </div>
              <p className="hero-alt anim-rise d-5">
                No app? <a href={SHOP_URL}>Order in your browser →</a>
              </p>
            </div>
            <div className="hero-visual anim-scale d-2" aria-hidden>
              <div className="logo-halo">
                <img src="/logo.png" alt="" width="220" height="220" />
              </div>
            </div>
          </div>
        </section>

        {/* ---------- Features strip ---------- */}
        <section className="features">
          <div className="section-inner features-grid" data-reveal-group>
            <div className="feature">
              <span className="feature-icon"><TruckIcon /></span>
              <h3>Free delivery</h3>
              <p>No delivery fees, ever. The price you see is the price you pay.</p>
            </div>
            <div className="feature">
              <span className="feature-icon"><CashIcon /></span>
              <h3>Cash on delivery</h3>
              <p>No cards, no prepayment. Pay in cash when your bread arrives.</p>
            </div>
            <div className="feature">
              <span className="feature-icon"><WheatIcon /></span>
              <h3>Fresh &amp; traditional</h3>
              <p>National recipes baked the way they have always been baked.</p>
            </div>
            <div className="feature">
              <span className="feature-icon"><ChatIcon /></span>
              <h3>In-app chat support</h3>
              <p>Questions about an order? Chat with our team right in the app.</p>
            </div>
          </div>
        </section>

        {/* ---------- How it works ---------- */}
        <section className="how" id="how-it-works">
          <div className="section-inner">
            <div className="section-head" data-reveal>
              <p className="section-eyebrow">Simple as it should be</p>
              <h2 className="section-title">How it works</h2>
              <p className="section-sub">
                From our oven to your table in three simple steps.
              </p>
            </div>
            <div className="steps" data-reveal-group>
              <div className="step">
                <span className="step-num">1</span>
                <h3>Browse &amp; order</h3>
                <p>
                  Pick your favourite breads and baked goods in the app or in
                  your browser and place your order in minutes.
                </p>
              </div>
              <div className="step">
                <span className="step-num">2</span>
                <h3>We bake &amp; schedule</h3>
                <p>
                  We bake your order fresh and schedule it for the next delivery
                  day in your city.
                </p>
              </div>
              <div className="step">
                <span className="step-num">3</span>
                <h3>Delivered to your door</h3>
                <p>
                  Your order arrives at your door — pay cash on delivery and
                  enjoy it warm.
                </p>
              </div>
            </div>
          </div>
        </section>

        {/* ---------- Cities ---------- */}
        <section className="cities" id="cities">
          <div className="section-inner">
            <div className="section-head" data-reveal>
              <p className="section-eyebrow">Across Germany</p>
              <h2 className="section-title">Where we deliver</h2>
              <p className="section-sub">
                Door delivery in four German cities — and counting.
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
              <p className="section-eyebrow">Free on Android &amp; iOS</p>
              <h2 className="section-title">Get the {APP_NAME} app</h2>
              <p className="section-sub">
                Order in a couple of taps, chat with our team and track your
                deliveries — free on Android and iOS.
              </p>
            </div>
            <div className="hero-actions center-actions">
              <a className="btn" href={PLAY_URL} aria-label="Get it on Google Play">
                <PlayIcon /> Google Play
              </a>
              <a
                className="btn secondary"
                href={APPSTORE_URL}
                aria-label="Download on the App Store"
              >
                <AppleIcon /> App Store
              </a>
            </div>
            <p className="hero-alt">
              Prefer the web?{" "}
              <a href={SHOP_URL}>Order online at shop.sarko-delivery.de →</a>
            </p>
          </div>
        </section>

        {/* ---------- Final CTA ---------- */}
        <section className="final-cta">
          <div className="section-inner" data-reveal>
            <h2 className="cta-title">Hungry for real bread?</h2>
            <p className="section-sub">
              Fresh, traditional and at your door — with free delivery and cash
              payment on arrival.
            </p>
            <a className="btn btn-lg" href={SHOP_URL}>
              Order online now
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
              Traditional breads and baked goods, baked fresh and delivered to
              your door.
            </p>
          </div>
          <div className="footer-col">
            <h4>Explore</h4>
            {NAV_LINKS.map((link) => (
              <a key={link.href} href={link.href}>
                {link.label}
              </a>
            ))}
          </div>
          <div className="footer-col">
            <h4>Contact</h4>
            <a href={CONTACT_WHATSAPP}>WhatsApp</a>
            <a href={`mailto:${SUPPORT_EMAIL}`}>{SUPPORT_EMAIL}</a>
          </div>
          <div className="footer-col">
            <h4>Legal</h4>
            <a href="/privacy">Privacy Policy</a>
            <a href="/terms">Terms of Service</a>
            <a href="/delete-account">Delete account</a>
          </div>
        </div>
        <div className="section-inner footer-bottom">
          <span>
            © {new Date().getFullYear()} {APP_NAME}. All rights reserved.
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
