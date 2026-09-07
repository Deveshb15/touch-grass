"use client";

import { motion, useReducedMotion } from "framer-motion";
import { DMG_URL } from "@/lib/site";

function AppleMark() {
  return (
    <svg className="size-5 shrink-0 fill-current" viewBox="0 0 20 20" aria-hidden="true">
      <path d="M15.6 10.6c0-2.1 1.7-3.1 1.8-3.2-1-1.4-2.5-1.6-3-1.7-1.3-.1-2.5.8-3.2.8-.7 0-1.7-.7-2.7-.7-1.4 0-2.7.8-3.4 2.1-1.5 2.5-.4 6.3 1 8.4.7 1 1.5 2.1 2.6 2.1 1-.1 1.4-.7 2.7-.7 1.3 0 1.6.7 2.7.7 1.1 0 1.8-1 2.5-2 .8-1.2 1.1-2.3 1.1-2.4 0 0-2.2-.9-2.1-3.4ZM13.5 4.4c.6-.7 1-1.7.9-2.6-.8 0-1.8.6-2.4 1.3-.5.6-1 1.6-.9 2.5.9.1 1.8-.5 2.4-1.2Z" />
    </svg>
  );
}

export default function DownloadButton() {
  const reduce = useReducedMotion();
  return (
    <motion.a
      href={DMG_URL}
      className="inline-flex items-center gap-2.5 rounded-full bg-accent-deep py-3.5 pr-6 pl-5 text-lg font-medium text-paper shadow-[0_12px_30px_-12px] shadow-accent-deep/60 focus-visible:outline-accent-deep focus-visible:outline-offset-2 sm:py-3 sm:text-base"
      whileHover={reduce ? undefined : { y: -1.5 }}
      whileTap={reduce ? undefined : { scale: 0.98 }}
      transition={{ type: "spring", stiffness: 420, damping: 24 }}
    >
      <AppleMark />
      Download for Mac
    </motion.a>
  );
}
