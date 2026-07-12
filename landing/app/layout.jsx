import "./globals.css";
import { APP_NAME } from "./config";

export const metadata = {
  title: APP_NAME,
  description:
    "Sarkis Delivery — a bridge between our customers, old and new. Get the app.",
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
