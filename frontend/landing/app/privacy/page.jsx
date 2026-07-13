import { PRIVACY, pickLang } from "../legal";
import LegalView from "../LegalView";

export const metadata = { title: "Privacy Policy — Sarko Delivery" };

export default function PrivacyPage({ searchParams }) {
  const lang = pickLang(searchParams?.lang);
  return <LegalView doc={PRIVACY[lang]} lang={lang} path="/privacy" />;
}
