import type { Metadata, Viewport } from "next";
import { Instrument_Serif, Figtree } from "next/font/google";
import "./globals.css";
import { SITE_URL, NAME, DESCRIPTION, TAGLINE } from "@/lib/site";
import { ogUrl, webSiteLd, softwareApplicationLd } from "@/lib/seo";
import JsonLd from "@/components/JsonLd";

const instrumentSerif = Instrument_Serif({
  variable: "--font-instrument-serif",
  subsets: ["latin"],
  weight: "400",
  style: ["normal", "italic"],
  display: "swap",
});

const figtree = Figtree({
  variable: "--font-figtree",
  subsets: ["latin"],
  display: "swap",
});

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: {
    default: `Touch Grass: ${TAGLINE}`,
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
    images: [{ url: ogUrl("The Mac app that sends you outside.", "A small, free Mac app"), width: 1200, height: 630, alt: NAME }],
  },
  twitter: {
    card: "summary_large_image",
    title: NAME,
    description: DESCRIPTION,
    creator: "@Deveshb15",
    images: [ogUrl("The Mac app that sends you outside.", "A small, free Mac app")],
  },
};

export const viewport: Viewport = {
  themeColor: "#fdf3ea",
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en" className={`${instrumentSerif.variable} ${figtree.variable} h-full antialiased`}>
      <body className="isolate flex min-h-full flex-col">
        <JsonLd data={[webSiteLd(), softwareApplicationLd()]} />
        {children}
      </body>
    </html>
  );
}
