import type { Metadata } from "next";
import Link from "next/link";
import PageShell from "@/components/PageShell";
import PageHero from "@/components/PageHero";
import CtaStrip from "@/components/CtaStrip";
import { pageMeta } from "@/lib/seo";
import { GITHUB_URL } from "@/lib/site";

export const metadata: Metadata = pageMeta({
  title: "Privacy",
  description:
    "Touch Grass is private by default: no analytics, no account, no servers. Everything runs on your Mac, and the only thing it reads is your browser’s active-tab URL — locally — to spot AI sites.",
  path: "/privacy",
  ogEyebrow: "privacy",
});

export default function Privacy() {
  return (
    <PageShell>
      <PageHero
        crumb="Privacy"
        path="/privacy"
        title="Private by default"
        lede="Touch Grass is built to be trustworthy without you having to take our word for it: everything happens on your Mac, and the source is open."
      />

      <article className="prose-tg mx-auto max-w-3xl px-6 pb-8">
        <h2>Everything stays on your Mac</h2>
        <p>
          There are no analytics, no network calls, no account, and no servers. Touch Grass doesn’t phone home, doesn’t
          have a backend, and has nothing to upload. Your usage never leaves your machine.
        </p>

        <h2>The one thing it reads</h2>
        <p>
          To recognize AI websites, Touch Grass reads your browser’s <strong>active-tab URL</strong> — and only that —
          via macOS Automation. macOS asks for your permission once per browser. The URL is matched against AI domains
          on-device and is never stored or sent anywhere. If you deny permission, it simply won’t detect AI sites in
          that browser; denials are shown in <strong>Settings → Permissions</strong>.
        </p>

        <h2>What it never does</h2>
        <ul>
          <li>No telemetry or usage analytics.</li>
          <li>No crash reporting to a remote service.</li>
          <li>No ads, no trackers, no third-party SDKs.</li>
          <li>No selling or sharing of data — there isn’t any to sell.</li>
        </ul>

        <h2>Your progress, stored locally</h2>
        <p>
          Your accumulated AI time is saved on disk so quitting and relaunching doesn’t wipe your progress, and so a
          break can resume if interrupted. It’s ordinary local app data — delete the app and it’s gone.
        </p>

        <h2>Open source, so you can check</h2>
        <p>
          The full source is on <a href={GITHUB_URL}>GitHub</a> under the MIT license. You can read exactly what it
          does, build it yourself, and verify every claim on this page. See also{" "}
          <Link href="/how-it-works">how it works</Link>.
        </p>
      </article>

      <CtaStrip heading="Nothing to hide. Go touch grass." />
    </PageShell>
  );
}
