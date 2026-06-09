"use client";

import { motion, useReducedMotion } from "framer-motion";
import { DMG_URL } from "@/lib/site";

function Apple() {
  return (
    <svg width="17" height="20" viewBox="0 0 17 20" fill="currentColor" aria-hidden>
      <path d="M14.05 10.6c-.02-2.05 1.67-3.03 1.75-3.08-.95-1.4-2.44-1.59-2.97-1.61-1.26-.13-2.46.74-3.1.74-.64 0-1.63-.72-2.68-.7-1.38.02-2.65.8-3.36 2.03-1.43 2.49-.37 6.17 1.03 8.19.68.99 1.5 2.1 2.56 2.06 1.03-.04 1.42-.66 2.66-.66 1.24 0 1.59.66 2.68.64 1.1-.02 1.8-1.01 2.48-2 .78-1.15 1.1-2.26 1.12-2.32-.02-.01-2.15-.83-2.17-3.28zM12.0 4.3c.56-.69.95-1.63.84-2.59-.81.03-1.8.54-2.39 1.22-.52.6-.98 1.57-.86 2.5.9.07 1.84-.46 2.41-1.13z" />
    </svg>
  );
}

export default function DownloadButton({ size = "lg" }: { size?: "lg" | "md" }) {
  const reduce = useReducedMotion();
  const pad = size === "lg" ? "px-7 py-4 text-[1.05rem]" : "px-6 py-3 text-base";
  return (
    <motion.a
      href={DMG_URL}
      className={`group inline-flex items-center gap-2.5 rounded-full font-semibold ${pad}`}
      style={{
        background: "linear-gradient(100deg, var(--color-cta), var(--color-cta-b))",
        color: "var(--color-accent-deep)",
        boxShadow: "0 14px 34px -14px oklch(81.2% 0.091 2.7 / 0.85), inset 0 0 0 1px oklch(100% 0 0 / 0.6)",
      }}
      whileHover={reduce ? undefined : { y: -2 }}
      whileTap={reduce ? undefined : { scale: 0.97 }}
      transition={{ type: "spring", stiffness: 420, damping: 22 }}
    >
      <Apple />
      Download for Mac
    </motion.a>
  );
}
