import type { Metadata } from "next";
import Link from "next/link";
import PageShell from "@/components/PageShell";
import PageHero from "@/components/PageHero";
import CtaStrip from "@/components/CtaStrip";
import { pageMeta } from "@/lib/seo";

export const metadata: Metadata = pageMeta({
  title: "Screen-break reminder for Mac",
  description:
    "Touch Grass is a gentle screen-break reminder for Mac. After too much AI it gives a one-minute warning, then fills the screen with a calm landscape and a countdown until you step away — firm, but never a trap.",
  path: "/screen-break-reminder",
  ogEyebrow: "for macOS",
});

export default function ScreenBreakReminder() {
  return (
    <PageShell>
      <PageHero
        crumb="Screen-break reminder"
        path="/screen-break-reminder"
        title="A screen-break reminder you won’t scroll past"
        lede="Most break reminders are a notification you dismiss in half a second. This one gently clears the screen — then gives it right back."
      />

      <article className="prose-tg mx-auto max-w-3xl px-6 pb-8">
        <h2>More than a notification</h2>
        <p>
          A toast in the corner is easy to swipe away and forget. Touch Grass waits until you’ve genuinely been
          heads-down — specifically with AI — and then takes over the whole screen for a few minutes, so the break
          actually happens instead of getting dismissed.
        </p>

        <h2>How a break feels</h2>
        <ul>
          <li>A <strong>one-minute warning</strong> first, so nothing interrupts you mid-thought.</li>
          <li>Every display fades into a slow <strong>dawn-to-dusk landscape</strong> with a countdown.</li>
          <li>A little <strong>plant grows</strong> while you’re away — a quiet reward for stepping back.</li>
          <li>Cmd-Tab is paused for the break’s duration — that’s the point of a break.</li>
        </ul>

        <h2>Firm, but never a trap</h2>
        <p>
          The break always ends on its own timer. There’s no anti-tamper daemon and nothing locking your machine — a
          determined you can always quit, and a break interrupted mid-way simply resumes the remaining time next launch.
          It’s a nudge with a nice view, not a cage.
        </p>

        <h2>On your terms</h2>
        <p>
          You set the rhythm: how long you can go before a break, how long the break lasts, and how far ahead the
          warning lands — all in Settings. See exactly how the timing works on{" "}
          <Link href="/how-it-works">how it works</Link>, or skim the <Link href="/faq">FAQ</Link>.
        </p>
      </article>

      <CtaStrip heading="Give your eyes a real break" />
    </PageShell>
  );
}
