import type { Metadata } from "next";
import Link from "next/link";
import PageShell from "@/components/PageShell";
import PageHero from "@/components/PageHero";
import CtaStrip from "@/components/CtaStrip";
import { pageMeta } from "@/lib/seo";

export const metadata: Metadata = pageMeta({
  title: "AI screen-time tracker for Mac",
  description:
    "Touch Grass is a free AI screen-time tracker for Mac. Instead of generic screen time, it measures the minutes you actually spend with AI — apps, terminal tools, and AI sites — then nudges you to take a break.",
  path: "/ai-screen-time-tracker-mac",
  ogEyebrow: "for macOS",
});

export default function AiScreenTimeTracker() {
  return (
    <PageShell>
      <PageHero
        crumb="AI screen-time tracker"
        path="/ai-screen-time-tracker-mac"
        title="An AI screen-time tracker for your Mac"
        lede="Most screen-time tools count every app the same. Touch Grass counts the one that quietly eats your day — AI — and does something about it."
      />

      <article className="prose-tg mx-auto max-w-3xl px-6 pb-8">
        <h2>Generic screen time misses the point</h2>
        <p>
          Built-in Screen Time can tell you how many hours you spent in a browser or a terminal — but not how much of
          that was AI. These days that’s the number that matters: the chats, the agents, the autocomplete you barely
          notice. Touch Grass measures <strong>AI time specifically</strong>, so the figure reflects the habit you
          actually want to watch.
        </p>

        <h2>What it measures</h2>
        <p>Once a second, it checks what’s frontmost and decides whether it’s AI:</p>
        <ul>
          <li><strong>Apps</strong> — Claude, ChatGPT, Cursor, and other AI tools, matched by bundle id.</li>
          <li><strong>Terminal tools</strong> — <code>claude</code>, <code>codex</code>, <code>aider</code>, <code>gemini</code>, including interpreter-hosted ones.</li>
          <li><strong>AI sites</strong> — chatgpt.com, claude.ai, perplexity.ai and friends, via the browser’s active-tab URL (read locally).</li>
        </ul>

        <h2>A number that actually means something</h2>
        <p>
          A second only counts when you’re engaged at an AI surface, or when an AI agent is genuinely working in the
          background. Idle windows and unrelated apps don’t inflate the total. It accumulates in a rolling window that’s
          saved to disk, so quitting doesn’t reset your progress. Read the full model on{" "}
          <Link href="/how-it-works">how it works</Link>.
        </p>

        <h2>From tracking to a real break</h2>
        <p>
          A tracker you can ignore is just a number. When you cross your limit, Touch Grass gives a one-minute warning,
          then fills every display with a calm landscape and a countdown until you step away. And it stays private —
          everything is computed <Link href="/privacy">on your Mac</Link>.
        </p>
      </article>

      <CtaStrip heading="See where your AI time really goes" />
    </PageShell>
  );
}
