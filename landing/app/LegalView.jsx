import { LANGS } from "./legal";

// Shared renderer for the Privacy / Terms pages, with a language switcher
// that preserves the current path via ?lang=xx.
export default function LegalView({ doc, lang, path }) {
  return (
    <main className="wrap">
      <div style={{ marginBottom: 20 }}>
        {LANGS.map((l) => {
          const active = l.code === lang;
          return (
            <a
              key={l.code}
              href={`${path}?lang=${l.code}`}
              style={{
                display: "inline-block",
                marginRight: 10,
                marginBottom: 8,
                padding: "6px 12px",
                borderRadius: 10,
                fontSize: 14,
                textDecoration: "none",
                color: active ? "#0a0a0a" : "var(--muted)",
                background: active ? "var(--gold-light)" : "var(--surface-2)",
                border: "1px solid var(--border)",
              }}
            >
              {l.label}
            </a>
          );
        })}
      </div>

      <h1>{doc.title}</h1>
      <p className="meta">{doc.updated}</p>

      <div className="card">
        {doc.sections.map((s, i) => (
          <section key={i}>
            <h2>{s.h}</h2>
            <p>{s.p}</p>
          </section>
        ))}
      </div>

      <footer>
        <a href="/">Home</a>
        <a href={`/privacy?lang=${lang}`}>Privacy Policy</a>
        <a href={`/terms?lang=${lang}`}>Terms of Service</a>
      </footer>
    </main>
  );
}
