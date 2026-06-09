import Link from "next/link";
import JsonLd from "./JsonLd";
import { breadcrumbLd } from "@/lib/seo";

// Content-page header: a visible breadcrumb + title + lede, plus the matching
// BreadcrumbList structured data.
export default function PageHero({
  title,
  lede,
  crumb,
  path,
}: {
  title: string;
  lede: string;
  crumb: string;
  path: string;
}) {
  return (
    <div className="mx-auto max-w-3xl px-6 pt-14 pb-8 md:pt-16">
      <JsonLd data={breadcrumbLd([{ name: "Home", path: "/" }, { name: crumb, path }])} />
      <nav className="flex items-center gap-2 text-sm text-ink-muted" aria-label="Breadcrumb">
        <Link href="/" className="hover:text-ink">Home</Link>
        <span aria-hidden>›</span>
        <span style={{ color: "var(--color-ink)" }}>{crumb}</span>
      </nav>
      <h1
        className="mt-5 font-display font-semibold leading-[1.05] tracking-[-0.01em]"
        style={{ color: "var(--color-accent-deep)", fontSize: "clamp(2.3rem, 5.5vw, 3.6rem)" }}
      >
        {title}
      </h1>
      <p className="mt-5 max-w-2xl text-[1.2rem] leading-snug text-ink-muted">{lede}</p>
    </div>
  );
}
