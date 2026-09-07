import Link from "next/link";
import Image from "next/image";
import { ROUTES, GITHUB_URL } from "@/lib/site";

// Wordmark plus a few destinations. Sits transparently on whatever is behind it.
export default function SiteHeader() {
  const navRoutes = ROUTES.filter((r) => r.nav);
  return (
    <header className="relative z-20 mx-auto flex w-full max-w-6xl items-center justify-between gap-6 px-6 pt-6 sm:pt-8">
      <Link href="/" aria-label="Homepage" className="flex items-center gap-2.5">
        <Image src="/shots/icon.png" alt="" width={32} height={32} className="size-8 rounded-lg" />
        <span className="font-display text-2xl italic text-accent-deep">touch grass</span>
      </Link>
      <nav aria-label="Main" className="flex items-center gap-x-6 text-base font-medium text-ink-muted sm:text-[0.9375rem]">
        {navRoutes.map((r) => (
          <Link key={r.path} href={r.path} className="hover:text-ink max-sm:hidden">
            {r.label}
          </Link>
        ))}
        <a href={GITHUB_URL} className="hover:text-ink">GitHub</a>
      </nav>
    </header>
  );
}
