import "./globals.css";
import { Fraunces, Inter } from "next/font/google";
import { APP_NAME } from "./config";

const fraunces = Fraunces({
  subsets: ["latin"],
  weight: ["600", "700", "800"],
  variable: "--font-display",
});
const inter = Inter({ subsets: ["latin"], variable: "--font-body" });

export const metadata = {
  title: `${APP_NAME} — Fresh traditional breads, delivered to your door`,
  description:
    "Sarko Delivery bakes national and traditional breads and delivers them to your door in Berlin, Hamburg, Frankfurt and München. Free delivery, pay cash on arrival.",
  icons: { icon: "/logo.png", apple: "/logo.png" },
};

export const viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: "#0a0a0a",
};

export default function RootLayout({ children }) {
  return (
    <html lang="en" className={`${fraunces.variable} ${inter.variable}`}>
      <body>{children}</body>
    </html>
  );
}
