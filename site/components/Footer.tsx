"use client";

import { useReducedMotion } from "framer-motion";
import { GITHUB_URL } from "@/lib/site";

// Ft8 — a gentle repeating marquee that closes the page. Collapses to a single
// static line under prefers-reduced-motion.
export default function Footer() {
  const reduce = useReducedMotion();
  const phrase = "go touch some grass";
  const chunk = (
    <span className="flex shrink-0 items-center gap-8 pr-8 font-display text-[clamp(2rem,7vw,4.5rem)]"
      style={{ color: "var(--color-accent-deep)", opacity: 0.85 }}>
      {Array.from({ length: 6 }).map((_, i) => (
        <span key={i} className="flex items-center gap-8">
          {phrase}
          <span aria-hidden className="h-2.5 w-2.5 rounded-full" style={{ background: "var(--color-sprout)" }} />
        </span>
      ))}
    </span>
  );

  return (
    <footer className="overflow-hidden border-t pt-14 pb-10" style={{ borderColor: "var(--color-line)" }}>
      {reduce ? (
        <p className="px-6 text-center font-display text-[clamp(2rem,7vw,4.5rem)]" style={{ color: "var(--color-accent-deep)", opacity: 0.85 }}>
          go touch some grass
        </p>
      ) : (
        <div className="flex w-max">
          <div className="marquee-track flex">{chunk}{chunk}</div>
        </div>
      )}

      <div className="mx-auto mt-12 flex max-w-6xl flex-wrap items-center justify-center gap-x-3 gap-y-1 px-6 text-sm text-ink-muted">
        <span>Touch Grass</span>
        <span aria-hidden>·</span>
        <a href={GITHUB_URL} className="font-semibold underline-offset-4 hover:text-ink hover:underline">open source on GitHub</a>
        <span aria-hidden>·</span>
        <span>macOS 13+</span>
        <span aria-hidden>·</span>
        <span>built for stepping away from the screen 🌿</span>
      </div>
    </footer>
  );
}
