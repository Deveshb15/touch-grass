import Image from "next/image";

function Shot({ src, w, h, alt }: { src: string; w: number; h: number; alt: string }) {
  return (
    <figure className="rounded-[18px] p-1.5" style={{ background: "oklch(100% 0 0 / 0.5)", boxShadow: "0 30px 60px -28px oklch(44.9% 0.087 354.4 / 0.4)" }}>
      <Image
        src={src}
        alt={alt}
        width={w}
        height={h}
        className="h-auto w-full rounded-[13px]"
        style={{ outline: "1px solid var(--color-line)" }}
      />
    </figure>
  );
}

function Copy({ kicker, title, children }: { kicker: string; title: string; children: React.ReactNode }) {
  return (
    <div className="max-w-md">
      <span className="font-semibold text-sprout-deep">{kicker}</span>
      <h2 className="mt-2 text-[clamp(1.9rem,4.5vw,2.8rem)]" style={{ color: "var(--color-accent-deep)" }}>
        {title}
      </h2>
      <p className="mt-4 text-[1.1rem] leading-relaxed text-ink">{children}</p>
    </div>
  );
}

export default function Showcase() {
  return (
    <section className="mx-auto max-w-6xl px-6">
      {/* what it is */}
      <div className="mx-auto max-w-2xl py-20 text-center md:py-28">
        <p className="text-[clamp(1.4rem,3.4vw,2.1rem)] leading-snug text-ink">
          It watches how much <em className="not-italic font-bold text-sprout-deep">active</em> AI time you rack up —
          apps, terminal tools, AI sites — and when you cross your limit, it sits you down for a few minutes outside.
        </p>
      </div>

      {/* set your pace */}
      <div className="grid items-center gap-10 py-10 md:grid-cols-2 md:gap-16 md:py-16">
        <div className="mx-auto w-full max-w-[330px] md:order-1">
          <Shot src="/shots/onboarding.png" w={528} h={728} alt="Onboarding: a pink-dawn card asking your name and pace" />
        </div>
        <div className="md:order-2">
          <Copy kicker="set your pace" title="A ten-second hello.">
            Tell it your name, how long you can go before a break, and how long the break lasts. Then it slips into
            your menu bar — no dock icon, no clutter — and gets out of the way.
          </Copy>
        </div>
      </div>

      {/* tune everything */}
      <div className="grid items-center gap-10 py-10 md:grid-cols-2 md:gap-16 md:py-16">
        <div className="md:order-1">
          <Copy kicker="tune everything" title="Yours to dial in.">
            Change the limit, the rolling window, the break length, and exactly what counts as “AI” — which apps, which
            command-line tools, which websites. Soft sliders, no spreadsheets.
          </Copy>
        </div>
        <div className="mx-auto w-full max-w-[360px] md:order-2">
          <Shot src="/shots/settings.png" w={592} h={752} alt="Settings: pink tabs with sliders for limits and AI targets" />
        </div>
      </div>
    </section>
  );
}
