import type { Metadata, Viewport } from "next";
import { Fredoka, Nunito } from "next/font/google";
import "./globals.css";
import { SITE_URL, NAME, DESCRIPTION } from "@/lib/site";
import { ogUrl, webSiteLd, softwareApplicationLd } from "@/lib/seo";
import JsonLd from "@/components/JsonLd";

const fredoka = Fredoka({
  variable: "--font-fredoka",
  subsets: ["latin"],
  weight: ["500", "600", "700"],
});

const nunito = Nunito({
  variable: "--font-nunito",
  subsets: ["latin"],
  weight: ["400", "500", "600", "700"],
});

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: {
    default: "Touch Grass — after too much AI, your Mac sends you outside",
    template: "%s · Touch Grass",
  },
  description: DESCRIPTION,
  applicationName: NAME,
  authors: [{ name: "Devesh Bhimanpelli", url: "https://x.com/Deveshb15" }],
  creator: "Devesh Bhimanpelli",
  keywords: [
    "touch grass app",
    "macOS menu bar app",
    "AI screen time tracker Mac",
    "screen break reminder",
    "reduce AI usage",
    "digital wellbeing Mac",
  ],
  icons: { icon: "/shots/icon.png", apple: "/shots/icon.png" },
  alternates: { canonical: "/" },
  openGraph: {
    title: NAME,
    description: DESCRIPTION,
    url: SITE_URL,
    siteName: NAME,
    type: "website",
    images: [{ url: ogUrl("Touch Grass", "after too much AI, your Mac sends you outside"), width: 1200, height: 630, alt: NAME }],
  },
  twitter: {
    card: "summary_large_image",
    title: NAME,
    description: DESCRIPTION,
    creator: "@Deveshb15",
    images: [ogUrl("Touch Grass", "after too much AI, your Mac sends you outside")],
  },
};

export const viewport: Viewport = {
  themeColor: "#fdf3ea",
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en" className={`${fredoka.variable} ${nunito.variable} h-full antialiased`}>
      <body className="min-h-full flex flex-col">
        <JsonLd data={[webSiteLd(), softwareApplicationLd()]} />
        {children}
      </body>
    </html>
  );
}
