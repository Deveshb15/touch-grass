import type { ReactNode } from "react";
import SiteHeader from "./SiteHeader";
import Footer from "./Footer";

// Wrapper for content/landing pages: shared header, a calm dawn-tinted top that
// fades to paper, the content, and the shared footer.
export default function PageShell({ children }: { children: ReactNode }) {
  return (
    <div className="flex min-h-full flex-1 flex-col">
      <div className="relative flex-1 overflow-hidden">
        <div
          aria-hidden
          className="pointer-events-none absolute inset-x-0 top-0 h-[460px]"
          style={{ background: "linear-gradient(to bottom, var(--color-sky-hi), var(--color-paper))" }}
        />
        <SiteHeader />
        <main className="relative z-10">{children}</main>
      </div>
      <Footer />
    </div>
  );
}
