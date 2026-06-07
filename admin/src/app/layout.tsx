import type { Metadata } from "next";
import { Cairo } from "next/font/google";

import "./globals.css";

const cairo = Cairo({
  subsets: ["arabic", "latin"],
  variable: "--font-cairo",
  display: "swap",
});

export const metadata: Metadata = {
  title: "لوحة تحكم سوق العراق",
  description: "لوحة تحكم إدارة سوق العراق",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ar" dir="rtl" className={cairo.variable}>
      <body className="font-sans antialiased">{children}</body>
    </html>
  );
}
