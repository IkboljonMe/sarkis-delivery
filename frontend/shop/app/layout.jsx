import "./globals.css";
import { Fraunces, Inter } from "next/font/google";
import Providers from "./providers";
import Header from "../components/Header";
import Footer from "../components/Footer";
import MobileCartBar from "../components/MobileCartBar";

const fraunces = Fraunces({
  subsets: ["latin"],
  weight: ["600", "700", "800"],
  variable: "--font-display",
});
const inter = Inter({ subsets: ["latin"], variable: "--font-body" });

export const metadata = {
  title: "Sarko Delivery Shop — Order fresh traditional breads online",
  description:
    "Order national and traditional breads and baked goods online. Free door delivery in Berlin, Hamburg, Frankfurt and München — pay cash on delivery.",
};

export default function RootLayout({ children }) {
  return (
    <html lang="en" className={`${fraunces.variable} ${inter.variable}`}>
      <body>
        <Providers>
          <Header />
          <main className="page">{children}</main>
          <Footer />
          <MobileCartBar />
        </Providers>
      </body>
    </html>
  );
}
