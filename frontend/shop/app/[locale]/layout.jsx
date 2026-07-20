import "../globals.css";
import { Fraunces, Inter } from "next/font/google";
import Providers from "../providers";
import Header from "../../components/Header";
import Footer from "../../components/Footer";
import MobileCartBar from "../../components/MobileCartBar";
import { NextIntlClientProvider } from "next-intl";
import { getMessages, getTranslations } from "next-intl/server";

const fraunces = Fraunces({
  subsets: ["latin"],
  weight: ["600", "700", "800"],
  variable: "--font-display",
});
const inter = Inter({ subsets: ["latin"], variable: "--font-body" });

export async function generateMetadata({ params: { locale } }) {
  const t = await getTranslations({ locale });
  return {
    title: t("meta.title"),
    description: t("meta.description"),
  };
}

export default async function RootLayout({ children, params: { locale } }) {
  const messages = await getMessages();

  return (
    <html lang={locale} className={`${fraunces.variable} ${inter.variable}`}>
      <body>
        <NextIntlClientProvider messages={messages}>
          <Providers>
            <Header />
            <main className="page">{children}</main>
            <Footer />
            <MobileCartBar />
          </Providers>
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
