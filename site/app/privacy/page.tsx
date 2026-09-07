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
    "Touch Grass has no analytics, no account, and no server. Everything runs on your Mac. The only thing it reads is the address of your browser’s current tab, locally, to recognize AI websites.",
  path: "/privacy",
  ogTitle: "Nothing leaves your Mac.",
  ogEyebrow: "Privacy",
});

export default function Privacy() {
  return (
    <PageShell>
      <PageHero
        crumb="Privacy"
        path="/privacy"
        title="What stays on your Mac"
        lede="All of it. There is no server to send anything to, and the source is open so you can check."
      />

      <article className="prose-tg mx-auto max-w-3xl px-6 pb-8">
        <h2>No network, no account</h2>
        <p>
          Touch Grass makes no network calls. It has no backend, no account system, and nothing to upload. Your usage
          numbers never leave your machine.
        </p>

        <h2>The one thing it reads</h2>
        <p>
          To recognize AI websites, Touch Grass reads the <strong>address of your browser’s current tab</strong> and
          nothing else, through macOS Automation. macOS asks for your permission once per browser. The address is
          compared against a list of AI domains on your Mac and is never stored or sent anywhere. If you decline, it
          simply will not detect AI sites in that browser. Denials are listed under <strong>Settings, then
          Permissions</strong>.
        </p>

        <h2>What it never does</h2>
        <ul>
          <li>No telemetry or usage analytics.</li>
          <li>No crash reports to a remote service.</li>
          <li>No ads, no trackers, no third party SDKs.</li>
          <li>No selling or sharing of data. There is none to sell.</li>
        </ul>

        <h2>Your progress, on disk</h2>
        <p>
          Your accumulated AI time is saved locally so that quitting and relaunching does not wipe it, and so a break can
          resume if it was interrupted. It is ordinary app data. Delete the app and it is gone.
        </p>

        <h2>Check for yourself</h2>
        <p>
          The full source is on <a href={GITHUB_URL}>GitHub</a> under the MIT license. You can read exactly what it
          does, build it yourself, and verify every claim on this page. See also{" "}
          <Link href="/how-it-works">how it works</Link>.
        </p>
      </article>

      <CtaStrip heading="Nothing to hide." />
    </PageShell>
  );
}
