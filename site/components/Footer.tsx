import Link from "next/link";
import { GITHUB_URL, ROUTES, X_URL, VERSION } from "@/lib/site";

export default function Footer() {
  return (
    <footer className="border-t border-line">
      <div className="mx-auto flex max-w-6xl flex-col gap-8 px-6 py-12 sm:flex-row sm:items-start sm:justify-between">
        <div className="max-w-[36ch]">
          <p className="font-display text-2xl italic text-accent-deep">touch grass</p>
          <p className="mt-2 text-base text-pretty text-ink-muted sm:text-[0.9375rem]">
            A small Mac app by{" "}
            <a href={X_URL} className="font-medium text-ink underline decoration-ink/30 underline-offset-3 hover:decoration-ink">Devesh Bhimanpelli</a>.
            Free, MIT licensed, and built in Swift. Version {VERSION}.
          </p>
        </div>
        <nav aria-label="Footer" className="grid grid-cols-2 gap-x-10 gap-y-2 text-base text-ink-muted sm:text-[0.9375rem]">
          {ROUTES.filter((r) => r.path !== "/").map((r) => (
            <Link key={r.path} href={r.path} className="hover:text-ink">
              {r.label}
            </Link>
          ))}
          <a href={GITHUB_URL} className="hover:text-ink">Source on GitHub</a>
        </nav>
      </div>
    </footer>
  );
}
