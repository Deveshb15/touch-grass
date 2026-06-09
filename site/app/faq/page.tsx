import type { Metadata } from "next";
import Link from "next/link";
import PageShell from "@/components/PageShell";
import PageHero from "@/components/PageHero";
import CtaStrip from "@/components/CtaStrip";
import JsonLd from "@/components/JsonLd";
import { pageMeta, faqPageLd } from "@/lib/seo";

export const metadata: Metadata = pageMeta({
  title: "FAQ",
  description:
    "Answers about Touch Grass: is it free, does it track you, how it detects AI use, whether background agent time counts, how to skip a break, macOS support, and more.",
  path: "/faq",
  ogEyebrow: "frequently asked",
});

const qa: { q: string; a: string }[] = [
  {
    q: "Is Touch Grass free?",
    a: "Yes — completely free and open source under the MIT license. There’s no paid tier, no account, and no ads.",
  },
  {
    q: "Which Macs does it run on?",
    a: "macOS 13 (Ventura) or later, on both Apple Silicon and Intel Macs.",
  },
  {
    q: "Does it track me or send my data anywhere?",
    a: "No. Everything stays on your Mac — no analytics, no network calls, no account, no servers. The only thing it ever reads is your browser’s active-tab URL, locally, to recognize AI sites.",
  },
  {
    q: "How does it detect AI usage?",
    a: "Once a second it checks what’s frontmost: apps are matched by bundle id, a frontmost terminal is scanned for AI command-line tools (including interpreter-hosted ones like node …/claude), and a frontmost browser’s active-tab URL is matched against AI domains.",
  },
  {
    q: "Does time count when I’m not at the keyboard?",
    a: "A second counts only when you’re present (recent keyboard or mouse activity) at an AI surface, or when an AI command-line tool is genuinely working in the background. Idle time and unrelated apps don’t count.",
  },
  {
    q: "Does background agent time count — like a long Claude or Codex run?",
    a: "Yes. If an AI CLI is genuinely working on your behalf and using CPU, that time counts even when you’re not typing.",
  },
  {
    q: "Can I change the limit and the break length?",
    a: "Yes. In Settings you can change the limit, the rolling window, the break length, the warning lead time, and exactly what counts as “AI” — which apps, which command-line tools, and which websites.",
  },
  {
    q: "Can I skip or escape a break?",
    a: "The break always clears itself on its own timer. There’s no anti-tamper daemon, so if you truly need out you can quit the app (killall TouchGrass); quitting mid-break just resumes the remaining time when you relaunch.",
  },
  {
    q: "How is it different from Screen Time or a website blocker?",
    a: "It measures active AI time specifically — across native apps, terminal tools, and AI sites — counts only the time you’re actually engaged, and nudges you with a calming full-screen break instead of a hard block list. It’s independent of Apple’s Screen Time and doesn’t touch your Apple account.",
  },
  {
    q: "Will it lock me out or block me forever?",
    a: "No. A break lasts only as long as you set, then clears automatically. It’s a nudge, not a cage.",
  },
  {
    q: "Is it notarized and safe to install?",
    a: "It’s distributed as a notarized macOS disk image. Download the DMG from GitHub Releases, open it, drag Touch Grass to your Applications folder, and launch it.",
  },
  {
    q: "Does it have a Dock icon?",
    a: "No — it lives quietly in the menu bar (look for the sprout). There’s no Dock icon and nothing in the way.",
  },
  {
    q: "Why does it ask permission to read my browser tabs?",
    a: "To recognize AI websites, macOS asks once per browser for Automation permission to read the active-tab URL. It’s read locally, matched on-device, and never stored or sent. Denials are shown in Settings → Permissions.",
  },
  {
    q: "Where’s the source code?",
    a: "On GitHub, under the MIT license, so you can read exactly what it does and build it yourself.",
  },
];

export default function FAQ() {
  return (
    <PageShell>
      <JsonLd data={faqPageLd(qa)} />
      <PageHero
        crumb="FAQ"
        path="/faq"
        title="Frequently asked questions"
        lede="Everything people usually want to know before they install — what it counts, what it doesn’t, and what it never does with your data."
      />

      <div className="prose-tg mx-auto max-w-3xl px-6 pb-8">
        {qa.map(({ q, a }) => (
          <div key={q}>
            <h2 className="!text-[1.3rem]" style={{ color: "var(--color-ink)" }}>{q}</h2>
            <p>{a}</p>
          </div>
        ))}
        <p>
          Still wondering something? Read <Link href="/how-it-works">how it works</Link> or open an issue on{" "}
          <Link href="/download">the project</Link>.
        </p>
      </div>

      <CtaStrip />
    </PageShell>
  );
}
