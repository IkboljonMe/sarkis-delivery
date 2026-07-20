import { TERMS, pickLang } from "../../legal";
import LegalView from "../../LegalView";

export const metadata = { title: "Terms of Service — Sarko Delivery" };

export default function TermsPage({ searchParams }) {
  const lang = pickLang(searchParams?.lang);
  return <LegalView doc={TERMS[lang]} lang={lang} path="/terms" />;
}
