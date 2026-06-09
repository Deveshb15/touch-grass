import type { Metadata } from "next";
import { Fredoka, Nunito } from "next/font/google";
import "./globals.css";

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

const description =
  "A tiny macOS menu-bar app that notices when you've been heads-down with AI for too long — then quietly takes over the screen with a calm little landscape until you go touch some grass.";

export const metadata: Metadata = {
  metadataBase: new URL("https://github.com/Deveshb15/touch-grass"),
  title: "Touch Grass — after too much AI, your Mac sends you outside",
  description,
  icons: { icon: "/shots/icon.png", apple: "/shots/icon.png" },
  openGraph: {
    title: "Touch Grass",
    description,
    images: ["/shots/block.png"],
    type: "website",
  },
  twitter: { card: "summary_large_image", title: "Touch Grass", description, images: ["/shots/block.png"] },
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en" className={`${fredoka.variable} ${nunito.variable} h-full antialiased`}>
      <body className="min-h-full flex flex-col">{children}</body>
    </html>
  );
}
