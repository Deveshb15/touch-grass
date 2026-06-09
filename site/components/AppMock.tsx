// Crisp, code-built recreations of the app's onboarding + settings screens — no
// screenshots, no fake OS chrome. They reuse the site's DawnTheme tokens + fonts so
// they read as the real app. Display-only (not interactive). aria-labelled figures.

import type { ReactNode } from "react";

const CTA = "linear-gradient(100deg, var(--color-cta), var(--color-cta-b))";
const SELECTED = "linear-gradient(100deg, var(--color-accent), var(--color-cta-b))";

function Panel({ label, children }: { label: string; children: ReactNode }) {
  // The dawn "window" the card sits in (mirrors the real onboarding/settings windows).
  return (
    <figure
      aria-label={label}
      className="relative overflow-hidden rounded-[22px] p-5 sm:p-6"
      style={{
        background: "linear-gradient(to bottom, var(--color-sky-top), var(--color-sky-hi) 46%, var(--color-paper))",
        boxShadow: "0 40px 80px -34px oklch(44.9% 0.087 354.4 / 0.5)",
        outline: "1px solid oklch(100% 0 0 / 0.5)",
      }}
    >
      <div
        aria-hidden
        className="pointer-events-none absolute rounded-full"
        style={{ width: "55%", aspectRatio: "1/1", top: "-14%", left: "8%", background: "radial-gradient(closest-side, oklch(100% 0 0 / 0.6), transparent)" }}
      />
      <div
        className="relative rounded-[18px] p-5"
        style={{
          background: "linear-gradient(to bottom, oklch(100% 0 0 / 0.94), oklch(96.5% 0.012 350 / 0.94))",
          boxShadow: "0 1px 0 oklch(100% 0 0 / 0.7) inset, 0 10px 30px -18px oklch(44.9% 0.087 354.4 / 0.35)",
        }}
      >
        {children}
      </div>
    </figure>
  );
}

function Label({ children }: { children: ReactNode }) {
  return <p className="font-semibold text-ink-muted" style={{ fontSize: "0.78rem" }}>{children}</p>;
}

function Chip({ children, on }: { children: ReactNode; on?: boolean }) {
  return (
    <span
      className="flex-1 rounded-full py-1.5 text-center text-[0.8rem] font-semibold"
      style={
        on
          ? { background: SELECTED, color: "#fff", boxShadow: "0 6px 14px -8px var(--color-accent)" }
          : { background: "oklch(100% 0 0 / 0.6)", color: "var(--color-ink-muted)", boxShadow: "inset 0 0 0 1px oklch(100% 0 0 / 0.9)" }
      }
    >
      {children}
    </span>
  );
}

export function OnboardingMock() {
  return (
    <Panel label="The Touch Grass onboarding — set your name, your pace, and your break length">
      <h3 className="font-display text-[1.45rem] font-semibold" style={{ color: "var(--color-ink)" }}>let&rsquo;s set your pace</h3>
      <p className="mt-1 text-[0.82rem] text-ink-muted">three quick things, then we touch grass.</p>

      <div className="mt-4 space-y-1.5">
        <Label>what do we call you?</Label>
        <div className="rounded-[12px] px-3 py-2 text-[0.9rem]" style={{ background: "oklch(100% 0 0 / 0.7)", boxShadow: "inset 0 0 0 1.5px var(--color-accent)", color: "var(--color-ink)" }}>
          Devesh
        </div>
      </div>

      <div className="mt-4 space-y-1.5">
        <Label>nudge me to touch grass after</Label>
        <div className="flex gap-1.5">
          <Chip>30m</Chip><Chip on>1h</Chip><Chip>2h</Chip><Chip>3h</Chip>
        </div>
      </div>

      <div className="mt-4 space-y-1.5">
        <Label>&hellip;and keep me out for</Label>
        <div className="flex gap-1.5">
          <Chip>5m</Chip><Chip on>10m</Chip><Chip>15m</Chip><Chip>20m</Chip><Chip>30m</Chip>
        </div>
      </div>

      <div className="mt-4 space-y-1.5">
        <Label>a gentle heads-up before each break</Label>
        <div className="flex items-center gap-2 rounded-full px-3 py-2 text-[0.82rem] font-semibold" style={{ background: "oklch(100% 0 0 / 0.7)", boxShadow: "inset 0 0 0 1.5px oklch(81.2% 0.091 2.7 / 0.5)", color: "var(--color-accent-deep)" }}>
          <Bell />
          turn on touch-grass reminders
        </div>
      </div>

      <div className="mt-5 rounded-full py-2.5 text-center text-[0.9rem] font-semibold" style={{ background: CTA, color: "var(--color-accent-deep)", boxShadow: "inset 0 0 0 1px oklch(100% 0 0 / 0.7), 0 12px 26px -14px var(--color-accent)" }}>
        start touching grass
      </div>
      <p className="mt-3 text-center text-[0.7rem] text-ink-muted">you can change any of this later in settings.</p>
    </Panel>
  );
}

function SliderRow({ label, value, fill }: { label: string; value: string; fill: number }) {
  return (
    <div>
      <div className="flex items-baseline justify-between">
        <span className="text-[0.82rem] font-semibold" style={{ color: "var(--color-ink)" }}>{label}</span>
        <span className="text-[0.74rem] tabular-nums text-ink-muted">{value}</span>
      </div>
      <div className="relative mt-2 h-1.5 rounded-full" style={{ background: "var(--color-line)" }}>
        <div className="absolute inset-y-0 left-0 rounded-full" style={{ width: `${fill}%`, background: "var(--color-accent)" }} />
        <div className="absolute h-3.5 w-3.5 rounded-full bg-white" style={{ left: `calc(${fill}% - 7px)`, top: "50%", transform: "translateY(-50%)", boxShadow: "0 1px 4px oklch(44.9% 0.087 354.4 / 0.4)" }} />
      </div>
    </div>
  );
}

export function SettingsMock() {
  return (
    <Panel label="The Touch Grass settings — tune your pace, AI targets, and permissions">
      <h3 className="font-display text-[1.35rem] font-semibold" style={{ color: "var(--color-ink)" }}>settings</h3>
      <p className="mt-1 text-[0.8rem] text-ink-muted">tune your pace, targets, and permissions.</p>

      <div className="mt-3 flex gap-1.5">
        <Chip on>general</Chip><Chip>targets</Chip><Chip>permissions</Chip>
      </div>

      <div className="mt-4 space-y-1.5">
        <Label>you</Label>
        <div className="rounded-[12px] px-3 py-2 text-[0.9rem]" style={{ background: "oklch(100% 0 0 / 0.7)", boxShadow: "inset 0 0 0 1.5px oklch(100% 0 0 / 0.9)", color: "var(--color-ink-muted)" }}>
          your name
        </div>
      </div>

      <div className="mt-4 space-y-3.5">
        <Label>limits</Label>
        <SliderRow label="block after" value="30 min of AI use" fill={50} />
        <SliderRow label="block duration" value="10 min" fill={17} />
        <SliderRow label="rolling window" value="60 min" fill={40} />
        <SliderRow label="warn" value="1 min before block" fill={6} />
      </div>
    </Panel>
  );
}

function Bell() {
  return (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor" aria-hidden>
      <path d="M12 2a6 6 0 0 0-6 6v3.6l-1.4 2.8A1 1 0 0 0 5.5 16h13a1 1 0 0 0 .9-1.6L18 11.6V8a6 6 0 0 0-6-6Zm0 20a3 3 0 0 0 2.8-2H9.2A3 3 0 0 0 12 22Z" />
    </svg>
  );
}
