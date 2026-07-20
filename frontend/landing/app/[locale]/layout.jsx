import "../globals.css";
import { Fraunces, Inter } from "next/font/google";
import { APP_NAME } from "../config";
import { getTranslations } from "next-intl/server";

const fraunces = Fraunces({
  subsets: ["latin"],
  weight: ["600", "700", "800"],
  variable: "--font-display",
});
const inter = Inter({ subsets: ["latin"], variable: "--font-body" });

export async function generateMetadata({ params: { locale } }) {
  const t = await getTranslations({ locale });
  return {
    title: t("meta.title", { app: APP_NAME }),
    description: t("meta.description"),
    icons: { icon: "/logo.png", apple: "/logo.png" },
  };
}

export const viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: "#0a0a0a",
};

export default function RootLayout({ children, params: { locale } }) {
  return (
    <html lang={locale} className={`${fraunces.variable} ${inter.variable}`}>
      <body>{children}</body>
    </html>
  );
}
