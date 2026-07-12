import { headers } from "next/headers";
import { redirect } from "next/navigation";
import { APP_NAME, PLAY_URL, APPSTORE_URL } from "./config";

// Smart download link: detect the device from the User-Agent and send the
// visitor straight to the right store. Desktop / unknown UAs see both buttons.
export default function Home() {
  const ua = headers().get("user-agent") || "";
  const isAndroid = /android/i.test(ua);
  const isIOS = /iphone|ipad|ipod/i.test(ua) || (/mac/i.test(ua) && /mobile/i.test(ua));

  if (isAndroid) redirect(PLAY_URL);
  if (isIOS) redirect(APPSTORE_URL);

  return (
    <main className="center">
      <div className="wrap">
        <div className="badge">
          <PinIcon />
        </div>
        <div className="brand">
          Sarkis <small>DELIVERY</small>
        </div>
        <p className="tagline">
          A bridge between our customers — old and new. Get the app:
        </p>
        <div>
          <a className="btn" href={PLAY_URL}>
            Google Play
          </a>
          <a className="btn secondary" href={APPSTORE_URL}>
            App Store
          </a>
        </div>
        <p className="links">
          On your phone this page opens your store automatically.
        </p>
        <footer>
          <a href="/privacy">Privacy Policy</a>
          <a href="/terms">Terms of Service</a>
        </footer>
      </div>
    </main>
  );
}

function PinIcon() {
  return (
    <svg width="44" height="44" viewBox="0 0 24 24" fill="white" aria-hidden>
      <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5A2.5 2.5 0 1 1 12 6a2.5 2.5 0 0 1 0 5.5z" />
    </svg>
  );
}
