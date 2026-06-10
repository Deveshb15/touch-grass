// Single source of truth for the site's identity, links, and route map.
// Change SITE_URL in one place when the domain is pointed/registered.

export const SITE_URL = "https://touchgrass.rest";

export const NAME = "Touch Grass";
export const TAGLINE = "After too much AI, your Mac gently sends you outside.";
export const DESCRIPTION =
  "Touch Grass is a free, open-source macOS menu-bar app that watches how much active AI time you rack up — across apps, terminal tools, and AI sites — and when you cross your limit, gently fills the screen with a calm landscape until you take a break. Everything stays on your Mac.";
export const AUTHOR = "Devesh Bhimanpelli";
export const AUTHOR_URL = "https://github.com/Deveshb15";
export const X_URL = "https://x.com/Deveshb15";

export const VERSION = "0.1.1";
export const GITHUB_URL = "https://github.com/Deveshb15/touch-grass";
export const RELEASES_URL = "https://github.com/Deveshb15/touch-grass/releases/latest";
export const DMG_URL =
  "https://github.com/Deveshb15/touch-grass/releases/download/v0.1.1/TouchGrass-0.1.1.dmg";

export type Route = {
  path: string;
  label: string;
  nav?: boolean; // show in the header nav
  priority: number;
  changeFrequency: "weekly" | "monthly" | "yearly";
};

// Drives the sitemap, header nav (nav: true), and footer link row.
export const ROUTES: Route[] = [
  { path: "/", label: "Home", priority: 1.0, changeFrequency: "monthly" },
  { path: "/how-it-works", label: "How it works", nav: true, priority: 0.8, changeFrequency: "monthly" },
  { path: "/faq", label: "FAQ", nav: true, priority: 0.7, changeFrequency: "monthly" },
  { path: "/download", label: "Download", nav: true, priority: 0.9, changeFrequency: "monthly" },
  { path: "/privacy", label: "Privacy", priority: 0.5, changeFrequency: "yearly" },
  { path: "/ai-screen-time-tracker-mac", label: "AI screen-time tracker", priority: 0.7, changeFrequency: "monthly" },
  { path: "/screen-break-reminder", label: "Screen-break reminder", priority: 0.7, changeFrequency: "monthly" },
  { path: "/touch-grass-meaning", label: "“Touch grass” meaning", priority: 0.6, changeFrequency: "monthly" },
];
