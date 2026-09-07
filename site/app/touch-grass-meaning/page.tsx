import type { Metadata } from "next";
import Link from "next/link";
import PageShell from "@/components/PageShell";
import PageHero from "@/components/PageHero";
import CtaStrip from "@/components/CtaStrip";
import JsonLd from "@/components/JsonLd";
import { pageMeta, definedTermLd } from "@/lib/seo";

const DEFINITION =
  "“Touch grass” is internet slang. It is a usually playful way of telling someone to log off, step outside, and reconnect with the physical world after spending too long online.";

export const metadata: Metadata = pageMeta({
  title: "What “touch grass” means",
  description: DEFINITION,
  path: "/touch-grass-meaning",
  ogTitle: "What “touch grass” means",
  ogEyebrow: "Internet slang",
});

export default function TouchGrassMeaning() {
  return (
    <PageShell>
      <JsonLd data={definedTermLd({ term: "touch grass", definition: DEFINITION })} />
      <PageHero
        crumb="What “touch grass” means"
        path="/touch-grass-meaning"
        title="What does “touch grass” mean?"
        lede={DEFINITION}
      />

      <article className="prose-tg mx-auto max-w-3xl px-6 pb-8">
        <h2>The short version</h2>
        <p>
          To <strong>touch grass</strong> is to step away from the screen and back into the real world. People say it,
          usually half joking, to someone who seems too online: too deep in a feed, an argument, or a screen. Go
          outside, breathe, get some perspective. Taken literally it means exactly what it says. Go outside and put
          your hand on some actual grass.
        </p>

        <h2>Where it comes from</h2>
        <p>
          It spread across social platforms over the last several years as a gentle, sometimes cheeky, reality check.
          The image is deliberately ordinary. The cure for being chronically online is the grass outside your door.
        </p>

        <h2>How people use it</h2>
        <ul>
          <li>“You have been doomscrolling for three hours. Go touch grass.”</li>
          <li>“Logging off to touch some grass. Back later.”</li>
          <li>A friendly sign off after a long, very online day.</li>
        </ul>

        <h2>An app that helps you actually do it</h2>
        <p>
          <strong>Touch Grass</strong> is a free macOS app named after the phrase. After too much active AI time it
          gives you a one minute warning, then fills the screen with a calm landscape until the break is over. It is
          the difference between being told to touch grass and being walked to the door.
        </p>
        <p>
          See <Link href="/how-it-works">how it works</Link>, read the <Link href="/faq">FAQ</Link>, or{" "}
          <Link href="/download">download it for Mac</Link>.
        </p>
      </article>

      <CtaStrip heading="Go on, touch some grass." />
    </PageShell>
  );
}
