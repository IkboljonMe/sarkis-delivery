import { APP_NAME, SHOP_URL } from "../config";

export const metadata = {
  title: `Page not found — ${APP_NAME}`,
};

export default function NotFound() {
  return (
        <main className="nf">
          <div className="hero-glow" aria-hidden />
          <a href="/" className="brand-mark anim-rise">
            <img src="/logo.png" alt={`${APP_NAME} logo`} width="38" height="38" />
            <span>
              Sarko <small>DELIVERY</small>
            </span>
          </a>
          <p className="nf-code anim-rise d-1">404</p>
          <h1 className="nf-title anim-rise d-2">This shelf is empty</h1>
          <p className="nf-sub anim-rise d-3">
            The page you are looking for doesn&apos;t exist or has been moved. The
            fresh bread, however, is right where it always is.
          </p>
          <div className="nf-actions anim-rise d-4">
            <a className="btn" href="/">
              Back to home
            </a>
            <a className="btn secondary" href={SHOP_URL}>
              Order online
            </a>
          </div>
        </main>
  );
}
