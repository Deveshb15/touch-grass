import type { Metadata } from "next";
import Link from "next/link";
import PageShell from "@/components/PageShell";
import PageHero from "@/components/PageHero";
import CtaStrip from "@/components/CtaStrip";
import JsonLd from "@/components/JsonLd";
import { pageMeta, faqPageLd } from "@/lib/seo";
import { ISSUES_URL } from "@/lib/site";

export const metadata: Metadata = pageMeta({
  title: "FAQ",
  description:
    "Answers about Touch Grass: whether it is free, whether it tracks you, how it detects AI use, whether background agent time counts, how to get out of a break, and which Macs it runs on.",
  path: "/faq",
  ogEyebrow: "frequently asked",
});

const qa: { q: string; a: string }[] = [
  {
    q: "Is Touch Grass free?",
    a: "Yes. It is free and open source under the MIT license. There is no paid tier, no account, and no ads.",
  },
  {
    q: "Which Macs does it run on?",
    a: "macOS 13 (Ventura) or later, on both Apple Silicon and Intel.",
  },
  {
    q: "Does it track me or send my data anywhere?",
    a: "No. There are no analytics, no network calls, no account, and no server. The only thing it reads is the address of your browser’s current tab, on your Mac, to recognize AI websites.",
  },
  {
    q: "How does it detect AI usage?",
    a: "Once a second it checks what is frontmost. Apps are matched by bundle id. A frontmost terminal is checked for AI command line tools, including ones running under an interpreter like node …/claude. A frontmost browser has its current tab’s address compared against a list of AI domains.",
  },
  {
    q: "Does time count when I am away from the keyboard?",
    a: "A second counts only when you are present at an AI surface, meaning recent keyboard or mouse activity, or when an AI command line tool is actively working in the background. Idle time and unrelated apps do not count.",
  },
  {
    q: "Does background agent time count, like a long Claude or Codex run?",
    a: "Yes. If an AI command line tool is working on your behalf and using CPU, that time counts even while you are not typing.",
  },
  {
    q: "Can I change the limit and the break length?",
    a: "Yes. Settings lets you change the limit, the rolling window, the break length, the warning lead time, and exactly which apps, terminal tools, and websites count as AI.",
  },
  {
    q: "Can I skip or get out of a break?",
    a: "A break always clears on its own timer. There is no anti-tamper daemon, so if you really need out you can quit the app (killall TouchGrass). If you quit mid-break, the remaining time resumes when you relaunch.",
  },
  {
    q: "How is it different from Screen Time or a website blocker?",
    a: "It measures AI time specifically, across native apps, terminal tools, and AI websites, and counts only the time you are actually engaged. Instead of a block list it gives you a short full-screen break. It is independent of Apple’s Screen Time and does not touch your Apple account.",
  },
  {
    q: "Will it lock me out for good?",
    a: "No. A break lasts exactly as long as you set, then clears by itself.",
  },
  {
    q: "Is it notarized and safe to install?",
    a: "Yes. It ships as a notarized macOS disk image. Download the DMG from GitHub Releases, open it, drag Touch Grass to Applications, and launch it.",
  },
  {
    q: "Does it have a Dock icon?",
    a: "No. It lives in the menu bar, where you will see a small sprout. There is nothing in the Dock.",
  },
  {
    q: "Why does it ask permission to read my browser tabs?",
    a: "To recognize AI websites, macOS asks once per browser for Automation permission so the app can read the address of the current tab. That address is compared on your Mac and never stored or sent. If you decline, it simply will not detect AI sites in that browser. Denials are listed under Settings, then Permissions.",
  },
  {
    q: "Where is the source code?",
    a: "On GitHub, under the MIT license. You can read exactly what it does and build it yourself.",
  },
];

export default function FAQ() {
  return (
    <PageShell>
      <JsonLd data={faqPageLd(qa)} />
      <PageHero
        crumb="FAQ"
        path="/faq"
        title="Questions people ask"
        lede="What it counts, what it does not, and what it never does with your data."
      />

      <div className="mx-auto max-w-3xl px-6 pb-8">
        <dl className="divide-y divide-line">
          {qa.map(({ q, a }) => (
            <div key={q} className="py-7 first:pt-0">
              <dt className="max-w-[40ch] text-xl font-semibold text-balance text-ink">{q}</dt>
              <dd className="mt-3 max-w-[64ch] text-lg/7 text-pretty text-ink-muted sm:text-base/7">{a}</dd>
            </div>
          ))}
        </dl>
        <p className="prose-tg mt-10">
          Something else? Read <Link href="/how-it-works">how it works</Link> or{" "}
          <a href={ISSUES_URL}>open an issue on GitHub</a>.
        </p>
      </div>

      <CtaStrip />
    </PageShell>
  );
}
