import DownloadButton from "./DownloadButton";

const points: { h: string; p: string }[] = [
  {
    h: "It only counts when you mean it.",
    p: "A second counts when you're present at an AI app, or an AI agent is genuinely working on your behalf in the background. Idle time and unrelated apps don't.",
  },
  {
    h: "A minute's warning, every time.",
    p: "Before a break lands, it taps you on the shoulder so nothing yanks the screen out from under you.",
  },
  {
    h: "Everything stays on your Mac.",
    p: "No analytics, no account, no servers. The only thing it ever reads is your browser's active-tab URL — locally — to spot AI sites.",
  },
  {
    h: "Firm, but never a trap.",
    p: "The break always ends on its own timer. There's no anti-tamper daemon; a determined you can always quit. It's a nudge, not a cage.",
  },
];

export default function Ethos() {
  return (
    <section className="mt-16 md:mt-24" style={{ background: "var(--color-paper-2)" }}>
      <div className="mx-auto grid max-w-6xl gap-10 px-6 py-20 md:grid-cols-[0.85fr_1.15fr] md:gap-16 md:py-28">
        <div>
          <h2 className="text-[clamp(2rem,5vw,3rem)] leading-[1.04]" style={{ color: "var(--color-accent-deep)" }}>
            Honest by design.
          </h2>
          <p className="mt-4 max-w-xs text-[1.05rem] text-ink-muted">
            The whole thing is one small, calm idea — held to it carefully.
          </p>
        </div>

        <ul className="grid gap-px overflow-hidden rounded-card" style={{ background: "var(--color-line)" }}>
          {points.map((pt) => (
            <li key={pt.h} className="flex gap-4 p-6 md:p-7" style={{ background: "var(--color-paper)" }}>
              <span aria-hidden className="mt-2 h-3 w-3 shrink-0 rounded-[4px]" style={{ background: "var(--color-sprout)" }} />
              <div>
                <h3 className="text-[1.25rem]" style={{ color: "var(--color-ink)" }}>{pt.h}</h3>
                <p className="mt-1.5 leading-relaxed text-ink-muted">{pt.p}</p>
              </div>
            </li>
          ))}
        </ul>
      </div>

      {/* final CTA */}
      <div className="mx-auto max-w-2xl px-6 pb-24 text-center md:pb-32">
        <h2 className="text-[clamp(2.2rem,6vw,3.6rem)]" style={{ color: "var(--color-accent-deep)" }}>
          Time to touch grass?
        </h2>
        <div className="mt-8 flex flex-col items-center gap-3">
          <DownloadButton />
          <p className="text-sm text-ink-muted">Free &middot; macOS 13+ &middot; Apple Silicon &amp; Intel</p>
        </div>
      </div>
    </section>
  );
}
