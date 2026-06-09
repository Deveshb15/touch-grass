import Link from "next/link";
import Image from "next/image";
import { ROUTES, GITHUB_URL } from "@/lib/site";

// Slim shared nav — wordmark + a few destinations. Transparent over whatever
// background it sits on; on mobile the text links collapse (footer carries them).
export default function SiteHeader() {
  const navRoutes = ROUTES.filter((r) => r.nav);
  return (
    <header className="relative z-20 mx-auto flex max-w-6xl items-center justify-between gap-4 px-6 pt-7">
      <Link href="/" className="flex items-center gap-2.5">
        <Image src="/shots/icon.png" alt="" width={36} height={36} className="rounded-[9px]" />
        <span className="font-display text-lg font-semibold" style={{ color: "var(--color-accent-deep)" }}>
          touch&nbsp;grass
        </span>
      </Link>
      <nav className="flex items-center gap-5 text-sm font-semibold text-ink-muted">
        {navRoutes.map((r) => (
          <Link key={r.path} href={r.path} className="hidden transition-colors hover:text-ink sm:inline">
            {r.label}
          </Link>
        ))}
        <a href={GITHUB_URL} className="transition-colors hover:text-ink">GitHub&nbsp;↗</a>
      </nav>
    </header>
  );
}
