import Link from "next/link";
import JsonLd from "./JsonLd";
import { breadcrumbLd } from "@/lib/seo";

// Content-page header: a visible breadcrumb, the title, and a lede, plus the
// matching BreadcrumbList structured data.
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
    <div className="mx-auto max-w-3xl px-6 pt-14 pb-10 md:pt-20">
      <JsonLd data={breadcrumbLd([{ name: "Home", path: "/" }, { name: crumb, path }])} />
      <nav className="flex items-center gap-2 text-base text-ink-muted sm:text-[0.9375rem]" aria-label="Breadcrumb">
        <Link href="/" className="hover:text-ink">Home</Link>
        <span aria-hidden="true">/</span>
        <span className="text-ink">{crumb}</span>
      </nav>
      <h1 className="mt-6 max-w-[20ch] font-display text-5xl text-balance text-accent-deep sm:text-6xl">
        {title}
      </h1>
      <p className="mt-5 max-w-[48ch] text-xl/8 text-pretty text-ink-muted">{lede}</p>
    </div>
  );
}
