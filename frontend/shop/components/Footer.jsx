export default function Footer() {
  return (
    <footer className="site-footer">
      <div className="footer-inner">
        <div className="footer-brand">
          <img src="/logo.png" alt="" width="28" height="28" />
          <span>
            Sarko <small>DELIVERY</small>
          </span>
        </div>
        <p className="footer-note">
          Traditional breads and baked goods — free delivery, pay cash on arrival.
        </p>
        <div className="footer-links">
          <a href="https://sarko-delivery.de/privacy">Privacy</a>
          <a href="https://sarko-delivery.de/terms">Terms</a>
          <a href="mailto:support@sarko-delivery.de">support@sarko-delivery.de</a>
        </div>
        <div className="footer-copy">© {new Date().getFullYear()} Sarko Delivery</div>
      </div>
    </footer>
  );
}
