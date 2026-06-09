import type { Metadata } from "next";
import Link from "next/link";
import PageShell from "@/components/PageShell";
import PageHero from "@/components/PageHero";
import DownloadButton from "@/components/DownloadButton";
import { pageMeta } from "@/lib/seo";
import { GITHUB_URL } from "@/lib/site";

export const metadata: Metadata = pageMeta({
  title: "Download for Mac",
  description:
    "Download Touch Grass free for macOS 13 or later (Apple Silicon & Intel). A one-minute install: open the DMG, drag it to Applications, and look for the sprout in your menu bar.",
  path: "/download",
  ogEyebrow: "download",
});

export default function Download() {
  return (
    <PageShell>
      <PageHero
        crumb="Download"
        path="/download"
        title="Download Touch Grass for Mac"
        lede="Free, notarized, and about a minute to set up. Grab the latest disk image and you’re moments away from your first break."
      />

      <div className="mx-auto max-w-3xl px-6">
        <div className="flex flex-col items-start gap-3">
          <DownloadButton />
          <p className="text-sm text-ink-muted">Free &middot; macOS 13+ &middot; Apple Silicon &amp; Intel</p>
        </div>
      </div>

      <article className="prose-tg mx-auto mt-12 max-w-3xl px-6 pb-8">
        <h2>Requirements</h2>
        <ul>
          <li>macOS 13 (Ventura) or later</li>
          <li>Apple Silicon or Intel</li>
          <li>A few megabytes of disk — it’s a tiny menu-bar app</li>
        </ul>

        <h2>Install</h2>
        <ul>
          <li>Download the latest <code>TouchGrass-x.y.z.dmg</code> from the download button above (it points at GitHub Releases).</li>
          <li>Open the disk image and drag <strong>Touch Grass</strong> into your <strong>Applications</strong> folder.</li>
          <li>Launch it from Applications — look for the sprout in your menu bar. There’s no Dock icon.</li>
        </ul>

        <h2>The first run</h2>
        <p>
          Want to see it work safely? Set a tiny limit and break length in Settings and trigger a quick break. While a
          break is on, the overlay covers every display and Cmd-Tab is paused for its duration — that’s intentional. It
          always clears itself on its own timer, and quitting mid-break just resumes the remaining time on relaunch.
        </p>
        <p>
          To recognize AI websites, macOS will ask once per browser for permission to read the active-tab URL. That
          read happens locally and never leaves your Mac — see <Link href="/privacy">privacy</Link> for the details.
        </p>

        <h2>Updating &amp; uninstalling</h2>
        <ul>
          <li><strong>Update:</strong> download the newer DMG and drag the new app over the old one in Applications.</li>
          <li><strong>Uninstall:</strong> quit from the menu bar (or <code>killall TouchGrass</code>), then drag Touch Grass from Applications to the Trash. Nothing keeps running in the background.</li>
        </ul>

        <p>
          New here? Read <Link href="/how-it-works">how it works</Link>, skim the <Link href="/faq">FAQ</Link>, or view
          the <a href={GITHUB_URL}>source on GitHub</a>.
        </p>
      </article>
    </PageShell>
  );
}
