import type { Metadata } from "next";
import Link from "next/link";
import PageShell from "@/components/PageShell";
import PageHero from "@/components/PageHero";
import CtaStrip from "@/components/CtaStrip";
import { pageMeta } from "@/lib/seo";

export const metadata: Metadata = pageMeta({
  title: "How it works",
  description:
    "How Touch Grass measures active AI time in apps, the terminal, and the browser, counts only the seconds you are engaged, warns you a minute ahead, and then takes over the screen for a short break.",
  path: "/how-it-works",
  ogTitle: "It counts your AI time. Then it takes the screen.",
  ogEyebrow: "How Touch Grass works",
});

export default function HowItWorks() {
  return (
    <PageShell>
      <PageHero
        crumb="How it works"
        path="/how-it-works"
        title="How Touch Grass works"
        lede="It watches one number, the time you spend with AI, and turns it into a break you cannot scroll past."
      />

      <article className="prose-tg mx-auto max-w-3xl px-6 pb-8">
        <h2>What counts as AI time</h2>
        <p>Once a second, Touch Grass looks at whatever is frontmost on your Mac and asks whether it is AI.</p>
        <ul>
          <li><strong>Apps</strong> are matched by bundle id. Claude, ChatGPT, Cursor, and so on.</li>
          <li>A frontmost <strong>terminal</strong> is checked for AI command line tools such as <code>claude</code>, <code>codex</code>, <code>aider</code>, and <code>gemini</code>. That includes ones running under an interpreter, like <code>node …/claude</code>.</li>
          <li>A frontmost <strong>browser</strong> has the address of its current tab read locally and compared against a list of AI domains like chatgpt.com, claude.ai, and perplexity.ai.</li>
        </ul>

        <h2>Only while you are actually there</h2>
        <p>
          A second counts when you are <strong>present</strong> at an AI surface, meaning there was recent keyboard or
          mouse activity. It also counts when an AI command line tool is <strong>working in the background</strong> and
          using CPU, even if you are not typing. A window left open in the corner does not count. Neither does an
          unrelated app.
        </p>

        <h2>A rolling window</h2>
        <p>
          Counted seconds add up inside a sliding window that you choose. The running total is saved to disk, so
          quitting and relaunching does not reset it. You pick up where you left off.
        </p>

        <h2>A warning, one minute ahead</h2>
        <p>
          Before a break, a small notice appears. You get time to finish the thought and save your work. Nothing
          happens mid-sentence.
        </p>

        <h2>The break</h2>
        <p>
          When you cross the limit, every display fills with a slow dawn to dusk landscape and a countdown. A small
          plant grows while you are away. The overlay covers all screens and Cmd-Tab is paused for the duration, which
          is rather the point. The end time is saved too, so if you quit mid-break it resumes the remaining time when
          you relaunch.
        </p>

        <h2>Firm, but not a trap</h2>
        <p>
          There is no anti-tamper daemon and nothing running that you cannot see. The break always clears on its own
          timer, and you can quit the app whenever you like. It is meant to be a nudge with a nice view.
        </p>

        <p>
          Still curious? Read the <Link href="/faq">FAQ</Link> or the <Link href="/privacy">privacy page</Link>, or{" "}
          <Link href="/download">download it</Link>, set a tiny limit, and watch it happen.
        </p>
      </article>

      <CtaStrip />
    </PageShell>
  );
}
