import type { Metadata } from "next";
import Link from "next/link";
import PageShell from "@/components/PageShell";
import PageHero from "@/components/PageHero";
import CtaStrip from "@/components/CtaStrip";
import { pageMeta } from "@/lib/seo";

export const metadata: Metadata = pageMeta({
  title: "Screen break reminder for Mac",
  description:
    "Touch Grass is a screen break reminder for Mac. After too much AI it gives a one minute warning, then fills the screen with a calm landscape and a countdown until the break is over.",
  path: "/screen-break-reminder",
  ogEyebrow: "for macOS",
});

export default function ScreenBreakReminder() {
  return (
    <PageShell>
      <PageHero
        crumb="Screen break reminder"
        path="/screen-break-reminder"
        title="A screen break reminder you cannot dismiss"
        lede="Most break reminders are a notification you swipe away in half a second. This one takes the screen for a few minutes, then gives it back."
      />

      <article className="prose-tg mx-auto max-w-3xl px-6 pb-8">
        <h2>More than a notification</h2>
        <p>
          A toast in the corner is easy to ignore. Touch Grass waits until you have genuinely been heads down with AI
          for a while, and then takes over every display for a few minutes, so the break actually happens.
        </p>

        <h2>What a break is like</h2>
        <ul>
          <li>A <strong>one minute warning</strong> first, so nothing interrupts you mid-thought.</li>
          <li>Every display fades into a slow <strong>dawn to dusk landscape</strong> with a countdown.</li>
          <li>A small <strong>plant grows</strong> while you are away.</li>
          <li>Cmd-Tab is paused until the timer runs out.</li>
        </ul>

        <h2>Firm, but not a trap</h2>
        <p>
          The break ends on its own timer. There is no anti-tamper daemon and nothing locking your machine. You can
          quit the app if you must, and an interrupted break resumes its remaining time next launch.
        </p>

        <h2>On your terms</h2>
        <p>
          You set the rhythm: how long you can go before a break, how long the break lasts, and how far ahead the
          warning arrives. All of it lives in Settings. See <Link href="/how-it-works">how it works</Link> for the
          timing details, or skim the <Link href="/faq">FAQ</Link>.
        </p>
      </article>

      <CtaStrip heading="Give your eyes a real break." />
    </PageShell>
  );
}
