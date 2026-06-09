// A hand-built, living pink dawn — the app's own backdrop, recreated in CSS/SVG.
// Deliberately a landscape (sky + sun + clouds + birds + grain), not a mesh blob.
// Decorative only; animation pauses under prefers-reduced-motion (see globals.css).

function Bird({ top, left, scale, dur, delay }: { top: string; left: string; scale: number; dur: number; delay: number }) {
  return (
    <svg
      className="bird absolute"
      style={{ top, left, animationDuration: `${dur}s`, animationDelay: `${delay}s`, transform: `scale(${scale})` }}
      width="34" height="12" viewBox="0 0 34 12" fill="none" aria-hidden
    >
      <path d="M1 9C5 2 9 2 12 8C15 2 19 2 23 9" stroke="oklch(64.9% 0.052 312.8)" strokeWidth="1.6"
        strokeLinecap="round" opacity="0.55" />
    </svg>
  );
}

export default function DawnScene() {
  return (
    <div className="dawn-sky absolute inset-0 overflow-hidden" aria-hidden>
      {/* the glowing sun on its arc */}
      <div className="sun absolute rounded-full"
        style={{ width: "min(46vw, 420px)", height: "min(46vw, 420px)", top: "-8%", right: "6%" }} />

      {/* soft drifting clouds */}
      <div className="cloud drift-a absolute rounded-full" style={{ width: "34vw", height: "9vw", top: "20%", left: "-6%" }} />
      <div className="cloud drift-b absolute rounded-full" style={{ width: "26vw", height: "7vw", top: "12%", left: "48%" }} />
      <div className="cloud drift-a absolute rounded-full" style={{ width: "20vw", height: "6vw", top: "34%", left: "22%", opacity: 0.7 }} />

      {/* a loose flock */}
      <Bird top="18%" left="8%" scale={1} dur={38} delay={0} />
      <Bird top="26%" left="0%" scale={0.8} dur={46} delay={6} />
      <Bird top="14%" left="-6%" scale={1.15} dur={32} delay={3} />

      {/* film grain for warmth */}
      <div className="grain absolute inset-0 opacity-[0.06]" />
    </div>
  );
}
