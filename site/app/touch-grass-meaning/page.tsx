import type { Metadata } from "next";
import Link from "next/link";
import PageShell from "@/components/PageShell";
import PageHero from "@/components/PageHero";
import CtaStrip from "@/components/CtaStrip";
import JsonLd from "@/components/JsonLd";
import { pageMeta, definedTermLd } from "@/lib/seo";

const DEFINITION =
  "“Touch grass” is internet slang — a usually playful nudge telling someone to log off, step outside, and reconnect with the physical world after spending too long online.";

export const metadata: Metadata = pageMeta({
  title: "What “touch grass” means",
  description: DEFINITION,
  path: "/touch-grass-meaning",
  ogTitle: "What “touch grass” means",
  ogEyebrow: "internet slang",
});

export default function TouchGrassMeaning() {
  return (
    <PageShell>
      <JsonLd data={definedTermLd({ term: "touch grass", definition: DEFINITION })} />
      <PageHero
        crumb="“Touch grass” meaning"
        path="/touch-grass-meaning"
        title="What does “touch grass” mean?"
        lede={DEFINITION}
      />

      <article className="prose-tg mx-auto max-w-3xl px-6 pb-8">
        <h2>The short version</h2>
        <p>
          To <strong>touch grass</strong> is to step away from the screen and back into the real world. It’s most often
          said half-jokingly to someone who seems too online — too deep in a feed, an argument, or a screen — as a way
          of saying: go outside, breathe, get some perspective. Taken literally, it’s exactly what it sounds like —
          go outside and put your hand on some actual grass.
        </p>

        <h2>Where it comes from</h2>
        <p>
          It’s internet slang that spread across social platforms over the last several years, usually as a gentle
          (sometimes cheeky) reality check. The image is deliberately simple: the antidote to being chronically online
          is something as ordinary as the grass outside your door.
        </p>

        <h2>How people use it</h2>
        <ul>
          <li>“You’ve been doomscrolling for three hours — go touch grass.”</li>
          <li>“Logging off to touch some grass. Back later.”</li>
          <li>A friendly sign-off after a long, very-online day.</li>
        </ul>

        <h2>An app that helps you actually do it</h2>
        <p>
          <strong>Touch Grass</strong> is a free macOS app named after the phrase — and built to honor it. After too
          much active AI time, it gently sends you outside: a one-minute warning, then a calm full-screen break until
          you step away. It’s the difference between being told to touch grass and being kindly nudged to.
        </p>
        <p>
          See <Link href="/how-it-works">how it works</Link>, read the <Link href="/faq">FAQ</Link>, or{" "}
          <Link href="/download">download it for Mac</Link>.
        </p>
      </article>

      <CtaStrip heading="Go on — touch some grass" />
    </PageShell>
  );
}
