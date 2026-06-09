"use client";

import Image from "next/image";
import { motion, useReducedMotion, type Variants } from "framer-motion";
import DawnScene from "./DawnScene";
import BreakScene from "./BreakScene";
import DownloadButton from "./DownloadButton";
import { GITHUB_URL } from "@/lib/site";

export default function Hero() {
  const reduce = useReducedMotion();
  const rise = (y: number): Variants => ({
    hidden: { opacity: 0, y: reduce ? 0 : y },
    show: { opacity: 1, y: 0 },
  });
  const ease: [number, number, number, number] = [0.16, 1, 0.3, 1];

  return (
    <section className="relative isolate overflow-hidden">
      <DawnScene />

      {/* minimal brand bar (N1) — transparent over the dawn, not a sticky hairline bar */}
      <header className="relative z-10 mx-auto flex max-w-6xl items-center justify-between px-6 pt-7">
        <span className="flex items-center gap-2.5">
          <Image src="/shots/icon.png" alt="" width={36} height={36} className="rounded-[9px]" />
          <span className="font-display text-lg font-semibold" style={{ color: "var(--color-accent-deep)" }}>
            touch&nbsp;grass
          </span>
        </span>
        <a href={GITHUB_URL} className="text-sm font-semibold text-ink-muted transition-colors hover:text-ink">
          GitHub&nbsp;↗
        </a>
      </header>

      <div className="relative z-10 mx-auto grid max-w-6xl items-center gap-10 px-6 pb-24 pt-12 md:grid-cols-[1.05fr_0.95fr] md:pb-32 md:pt-20">
        {/* text column */}
        <motion.div
          initial="hidden"
          animate="show"
          transition={{ staggerChildren: reduce ? 0 : 0.09, delayChildren: 0.05 }}
        >
          <motion.h1
            variants={rise(20)}
            transition={{ duration: reduce ? 0.2 : 0.8, ease }}
            className="font-display font-semibold leading-[0.95] tracking-[-0.02em]"
            style={{ color: "var(--color-accent-deep)", fontSize: "clamp(3rem, 10vw, 7rem)" }}
          >
            touch grass
          </motion.h1>

          <motion.p
            variants={rise(16)}
            transition={{ duration: reduce ? 0.2 : 0.8, ease }}
            className="mt-5 max-w-md text-[1.2rem] leading-snug text-ink"
          >
            After too much AI, your Mac gently sends you outside.
          </motion.p>

          <motion.div
            variants={rise(16)}
            transition={{ duration: reduce ? 0.2 : 0.8, ease }}
            className="mt-8 flex flex-wrap items-center gap-x-6 gap-y-3"
          >
            <DownloadButton />
            <a href={GITHUB_URL} className="font-semibold text-ink-muted underline-offset-4 hover:text-ink hover:underline">
              View on GitHub
            </a>
          </motion.div>

          <motion.p
            variants={rise(12)}
            transition={{ duration: reduce ? 0.2 : 0.8, ease }}
            className="mt-4 text-sm text-ink-muted"
          >
            Free &middot; macOS 13+ &middot; Apple Silicon &amp; Intel
          </motion.p>
        </motion.div>

        {/* the break — a live, growing-then-swaying sprout (not a static screenshot) */}
        <motion.div
          initial={{ opacity: 0, y: reduce ? 0 : 30, rotate: reduce ? 0 : -1.5 }}
          animate={{ opacity: 1, y: 0, rotate: reduce ? 0 : -1.5 }}
          transition={{ duration: reduce ? 0.2 : 0.9, ease, delay: reduce ? 0 : 0.25 }}
          className="w-full"
        >
          <BreakScene />
        </motion.div>
      </div>
    </section>
  );
}
