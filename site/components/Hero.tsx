"use client";

import { motion, useReducedMotion, type Variants } from "framer-motion";
import DawnScene from "./DawnScene";
import DownloadButton from "./DownloadButton";
import SiteHeader from "./SiteHeader";
import { GITHUB_URL } from "@/lib/site";

// Drop a screen recording of a break at public/shots/break.mp4 (and optionally
// break.webm). Until the file exists the poster frame (the real screenshot) shows.
export default function Hero() {
  const reduce = useReducedMotion();
  const rise = (y: number): Variants => ({
    hidden: { opacity: 0, y: reduce ? 0 : y },
    show: { opacity: 1, y: 0 },
  });
  const ease: [number, number, number, number] = [0.16, 1, 0.3, 1];
  const t = { duration: reduce ? 0.2 : 0.8, ease };

  return (
    <section className="relative isolate overflow-hidden">
      <DawnScene />
      <SiteHeader />

      <div className="relative z-10 mx-auto max-w-6xl px-6 pt-16 sm:pt-20 md:pt-24">
        <motion.div
          initial="hidden"
          animate="show"
          transition={{ staggerChildren: reduce ? 0 : 0.09, delayChildren: 0.05 }}
          className="flex flex-col items-center text-center"
        >
          <motion.h1
            variants={rise(20)}
            transition={t}
            className="max-w-[16ch] font-display text-6xl text-balance text-accent-deep sm:text-7xl md:text-8xl"
          >
            The Mac app that sends you <em>outside</em>.
          </motion.h1>

          <motion.p variants={rise(16)} transition={t} className="mt-6 max-w-[44ch] text-xl/8 text-pretty text-ink">
            It keeps count of the time you actually spend with AI. Past your limit, every screen turns into a quiet
            field for a few minutes. Then it gives your Mac back.
          </motion.p>

          <motion.div variants={rise(16)} transition={t} className="mt-8 flex flex-wrap items-center justify-center gap-x-6 gap-y-4">
            <DownloadButton />
            <a
              href={GITHUB_URL}
              className="text-lg font-medium text-ink underline decoration-ink/30 underline-offset-4 hover:decoration-ink sm:text-base"
            >
              Read the source
            </a>
          </motion.div>

          <motion.p variants={rise(12)} transition={t} className="mt-4 text-base text-ink-muted sm:text-[0.9375rem]">
            Free and open source. macOS 13 or later, Apple Silicon and Intel.
          </motion.p>
        </motion.div>

        {/* the break, as it actually looks */}
        <motion.figure
          initial={{ opacity: 0, y: reduce ? 0 : 32 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: reduce ? 0.2 : 1, ease, delay: reduce ? 0 : 0.35 }}
          className="mx-auto mt-14 max-w-5xl pb-20 sm:mt-16 md:mt-20 md:pb-28"
        >
          <video
            className="aspect-[16/10] w-full rounded-[min(2vw,20px)] object-cover shadow-[0_50px_100px_-40px] shadow-accent-deep/60 outline-1 -outline-offset-1 outline-black/10"
            poster="/shots/block.png"
            autoPlay={!reduce}
            muted
            loop
            playsInline
            preload="metadata"
            aria-label="A screen recording of a Touch Grass break: a peach dawn sky, a young plant, and a four minute countdown under the words “the grass misses you, Devesh.”"
          >
            <source src="/shots/break.webm" type="video/webm" />
            <source src="/shots/break.mp4" type="video/mp4" />
          </video>
        </motion.figure>
      </div>
    </section>
  );
}
