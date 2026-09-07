import type { ReactNode } from "react";
import SiteHeader from "./SiteHeader";
import Footer from "./Footer";

// Wrapper for content pages: shared header, a dawn-tinted top that fades to
// paper, the content, and the shared footer.
export default function PageShell({ children }: { children: ReactNode }) {
  return (
    <div className="flex min-h-full flex-1 flex-col">
      <div className="relative flex-1 overflow-hidden">
        <div aria-hidden="true" className="pointer-events-none absolute inset-x-0 top-0 h-[420px] bg-linear-to-b from-sky-hi to-paper" />
        <SiteHeader />
        <main className="relative z-10">{children}</main>
      </div>
      <Footer />
    </div>
  );
}
