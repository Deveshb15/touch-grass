import type { Metadata } from "next";
import { SITE_URL, NAME, DESCRIPTION, AUTHOR, AUTHOR_URL, DMG_URL, GITHUB_URL, VERSION } from "./site";

// Branded OG image URL (served by app/og/route.tsx).
export function ogUrl(title: string, eyebrow?: string): string {
  const u = new URL("/og", SITE_URL);
  u.searchParams.set("title", title);
  if (eyebrow) u.searchParams.set("eyebrow", eyebrow);
  return u.toString();
}

// Per-page metadata: canonical + OpenGraph + Twitter, all from one call.
// `title` is the page-specific part; layout's title.template wraps it as "… · Touch Grass".
export function pageMeta(opts: {
  title: string;
  description: string;
  path: string;
  ogTitle?: string;
  ogEyebrow?: string;
}): Metadata {
  const url = new URL(opts.path, SITE_URL).toString();
  const image = ogUrl(opts.ogTitle ?? opts.title, opts.ogEyebrow);
  return {
    title: opts.title,
    description: opts.description,
    alternates: { canonical: opts.path },
    openGraph: {
      title: opts.title,
      description: opts.description,
      url,
      siteName: NAME,
      type: "website",
      images: [{ url: image, width: 1200, height: 630, alt: opts.title }],
    },
    twitter: { card: "summary_large_image", title: opts.title, description: opts.description, images: [image] },
  };
}

// ——— JSON-LD builders (schema.org). No fabricated ratings/reviews/counts. ———

const author = { "@type": "Person", name: AUTHOR, url: AUTHOR_URL };

export function softwareApplicationLd() {
  return {
    "@context": "https://schema.org",
    "@type": "SoftwareApplication",
    name: NAME,
    description: DESCRIPTION,
    applicationCategory: "UtilitiesApplication",
    operatingSystem: "macOS 13.0 or later (Apple Silicon & Intel)",
    url: SITE_URL,
    downloadUrl: DMG_URL,
    softwareVersion: VERSION,
    license: "https://opensource.org/licenses/MIT",
    isAccessibleForFree: true,
    offers: { "@type": "Offer", price: "0", priceCurrency: "USD" },
    author,
    sameAs: [GITHUB_URL],
    screenshot: `${SITE_URL}/shots/block.png`,
  };
}

export function webSiteLd() {
  return {
    "@context": "https://schema.org",
    "@type": "WebSite",
    name: NAME,
    url: SITE_URL,
    description: DESCRIPTION,
    inLanguage: "en",
    publisher: author,
  };
}

export function faqPageLd(qas: { q: string; a: string }[]) {
  return {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: qas.map(({ q, a }) => ({
      "@type": "Question",
      name: q,
      acceptedAnswer: { "@type": "Answer", text: a },
    })),
  };
}

export function breadcrumbLd(items: { name: string; path: string }[]) {
  return {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    itemListElement: items.map((it, i) => ({
      "@type": "ListItem",
      position: i + 1,
      name: it.name,
      item: new URL(it.path, SITE_URL).toString(),
    })),
  };
}

export function definedTermLd(opts: { term: string; definition: string }) {
  return {
    "@context": "https://schema.org",
    "@type": "DefinedTerm",
    name: opts.term,
    description: opts.definition,
    inDefinedTermSet: { "@type": "DefinedTermSet", name: "Internet slang" },
  };
}
