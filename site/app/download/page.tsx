import type { Metadata } from "next";
import Link from "next/link";
import PageShell from "@/components/PageShell";
import PageHero from "@/components/PageHero";
import DownloadButton from "@/components/DownloadButton";
import { pageMeta } from "@/lib/seo";
import { GITHUB_URL, RELEASES_URL, VERSION } from "@/lib/site";

export const metadata: Metadata = pageMeta({
  title: "Download for Mac",
  description:
    "Download Touch Grass free for macOS 13 or later, Apple Silicon and Intel. Open the disk image, drag it to Applications, and look for the sprout in your menu bar.",
  path: "/download",
  ogTitle: "Download Touch Grass for Mac.",
  ogEyebrow: "Free and open source",
});

export default function Download() {
  return (
    <PageShell>
      <PageHero
        crumb="Download"
        path="/download"
        title="Download Touch Grass"
        lede="Free, notarized, and about a minute from download to first break."
      />

      <div className="mx-auto max-w-3xl px-6">
        <DownloadButton />
        <p className="mt-4 text-base text-ink-muted sm:text-[0.9375rem]">
          Version {VERSION}. macOS 13 or later, Apple Silicon and Intel.{" "}
          <a href={RELEASES_URL} className="underline decoration-ink/30 underline-offset-3 hover:text-ink hover:decoration-ink">
            All releases
          </a>
        </p>
      </div>

      <article className="prose-tg mx-auto mt-14 max-w-3xl px-6 pb-8">
        <h2>Requirements</h2>
        <ul>
          <li>macOS 13 (Ventura) or later</li>
          <li>Apple Silicon or Intel</li>
          <li>A few megabytes of disk space</li>
        </ul>

        <h2>Install</h2>
        <ol>
          <li>Download the disk image using the button above. It points at GitHub Releases.</li>
          <li>Open it and drag <strong>Touch Grass</strong> into your <strong>Applications</strong> folder.</li>
          <li>Launch it from Applications and look for the sprout in your menu bar. There is no Dock icon.</li>
        </ol>

        <h2>Trying it out</h2>
        <p>
          To see a break without waiting, set a very small limit and break length in Settings. While a break is on,
          the overlay covers every display and Cmd-Tab is paused. It always clears on its own timer, and quitting
          mid-break resumes the remaining time on relaunch.
        </p>
        <p>
          The first time it sees a browser, macOS will ask for permission to read the address of the current tab.
          That happens on your Mac and goes no further. The <Link href="/privacy">privacy page</Link> has the
          details.
        </p>

        <h2>Updating and uninstalling</h2>
        <ul>
          <li><strong>Update:</strong> the app checks for new versions itself. You can also download a newer disk image and drag it over the old app.</li>
          <li><strong>Uninstall:</strong> quit from the menu bar (or <code>killall TouchGrass</code>), then move Touch Grass from Applications to the Trash. Nothing keeps running.</li>
        </ul>

        <p>
          New here? Read <Link href="/how-it-works">how it works</Link>, skim the <Link href="/faq">FAQ</Link>, or
          look at the <a href={GITHUB_URL}>source on GitHub</a>.
        </p>
      </article>
    </PageShell>
  );
}
