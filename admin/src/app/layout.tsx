import type { Metadata } from "next";
import localFont from "next/font/local";
import { Inter } from "next/font/google";

import "./globals.css";

const thmanyahSans = localFont({
  src: [
    {
      path: "../../../assets/fonts/thmanyahsans/thmanyahsans-Regular.otf",
      weight: "400",
    },
    {
      path: "../../../assets/fonts/thmanyahsans/thmanyahsans-Medium.otf",
      weight: "500",
    },
    {
      path: "../../../assets/fonts/thmanyahsans/thmanyahsans-Bold.otf",
      weight: "700",
    },
    {
      path: "../../../assets/fonts/thmanyahsans/thmanyahsans-Black.otf",
      weight: "900",
    },
  ],
  variable: "--font-sans",
  display: "swap",
});

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
  display: "swap",
});

export const metadata: Metadata = {
  title: "لوحة تحكم Sello",
  description: "لوحة تحكم إدارة Sello",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ar" dir="rtl" className={`${thmanyahSans.variable} ${inter.variable}`}>
      <body className="font-sans antialiased bg-canvas text-foreground">{children}</body>
    </html>
  );
}
