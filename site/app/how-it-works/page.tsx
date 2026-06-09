import type { Metadata } from "next";
import Link from "next/link";
import PageShell from "@/components/PageShell";
import PageHero from "@/components/PageHero";
import CtaStrip from "@/components/CtaStrip";
import { pageMeta } from "@/lib/seo";

export const metadata: Metadata = pageMeta({
  title: "How it works",
  description:
    "How Touch Grass measures active AI time across apps, terminal tools, and AI sites — counting only when you’re engaged — then gives a one-minute warning and a gentle, escapable full-screen break.",
  path: "/how-it-works",
  ogEyebrow: "how it works",
});

export default function HowItWorks() {
  return (
    <PageShell>
      <PageHero
        crumb="How it works"
        path="/how-it-works"
        title="How Touch Grass works"
        lede="It watches one thing — how much active AI time you’re racking up — and turns it into a gentle, unavoidable nudge to step away from the screen."
      />

      <article className="prose-tg mx-auto max-w-3xl px-6 pb-8">
        <h2>What counts as AI time</h2>
        <p>Once a second, Touch Grass looks at what’s frontmost on your Mac and decides whether it’s AI:</p>
        <ul>
          <li><strong>Apps</strong> are matched by bundle id — things like Claude, ChatGPT, and Cursor.</li>
          <li>A frontmost <strong>terminal</strong> is scanned for AI command-line tools — <code>claude</code>, <code>codex</code>, <code>aider</code>, <code>gemini</code> — including interpreter-hosted ones like <code>node …/claude</code>.</li>
          <li>A frontmost <strong>browser</strong> has its active-tab URL read (locally) and matched against AI domains like chatgpt.com, claude.ai, and perplexity.ai.</li>
        </ul>

        <h2>Only when you’re actually engaged</h2>
        <p>
          A second only counts when you’re <strong>present</strong> — recent keyboard or mouse activity — at an AI
          surface, <strong>or</strong> when an AI command-line tool is genuinely working on your behalf in the
          background (using CPU). Idle time and unrelated apps don’t count, so the number reflects real AI use, not just
          a window left open.
        </p>

        <h2>A rolling window you can’t game by quitting</h2>
        <p>
          Counted seconds accumulate in a sliding window, and that progress is saved to disk. Quitting and relaunching
          doesn’t reset it — you pick up where you left off.
        </p>

        <h2>A minute’s warning, first</h2>
        <p>
          Before a break lands, Touch Grass taps you on the shoulder a minute ahead. Nothing yanks the screen out from
          under you mid-sentence — you get time to finish your thought and save your work.
        </p>

        <h2>The break</h2>
        <p>
          When you cross your limit, every display fills with a slow dawn-to-dusk landscape and a countdown. A little
          plant grows while you’re away. For its duration the overlay covers all screens and Cmd-Tab is paused — that’s
          the point. Its end time is saved too, so if you quit mid-break it simply resumes the remaining time when you
          come back.
        </p>

        <h2>Firm, but never a trap</h2>
        <p>
          There’s no anti-tamper daemon and nothing sketchy running in the background. The break always clears itself on
          its own timer, and a determined you can always quit the app. It’s a nudge with a nice view, not a cage.
        </p>

        <p>
          Curious about the details? See the <Link href="/faq">FAQ</Link>, read about{" "}
          <Link href="/privacy">privacy</Link>, or <Link href="/download">download it</Link> and try a tiny limit to
          watch it work.
        </p>
      </article>

      <CtaStrip />
    </PageShell>
  );
}
