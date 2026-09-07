import { OnboardingMock, SettingsMock } from "./AppMock";

const steps: { title: string; body: string }[] = [
  {
    title: "It keeps count.",
    body:
      "Time in Claude, ChatGPT, Cursor, an AI command line tool, or an AI website goes on the clock. Only while you are actually there. Idle minutes are free.",
  },
  {
    title: "It warns you first.",
    body:
      "A minute before a break, a small notice shows up so you can finish your sentence and save your work.",
  },
  {
    title: "It takes the screen.",
    body:
      "Every display turns into a slow dawn with a countdown. When the timer runs out, everything comes back exactly as you left it.",
  },
];

function Split({
  eyebrow,
  title,
  children,
  media,
  flip,
}: {
  eyebrow: string;
  title: string;
  children: React.ReactNode;
  media: React.ReactNode;
  flip?: boolean;
}) {
  return (
    <div className="grid items-center gap-10 md:grid-cols-2 md:gap-16">
      <div className={flip ? "md:order-2" : ""}>
        <p className="text-base font-medium text-sprout-deep sm:text-[0.9375rem]">{eyebrow}</p>
        <h2 className="mt-3 max-w-[20ch] font-display text-5xl text-balance text-accent-deep">{title}</h2>
        <p className="mt-5 max-w-[44ch] text-lg/7 text-pretty text-ink">{children}</p>
      </div>
      <div className={`mx-auto w-full max-w-[380px] ${flip ? "md:order-1" : ""}`}>{media}</div>
    </div>
  );
}

export default function Showcase() {
  return (
    <section className="py-20 md:py-28">
      <div className="mx-auto max-w-6xl px-6">
        <h2 className="max-w-[24ch] font-display text-5xl text-balance text-accent-deep sm:text-6xl">What happens</h2>

        <dl className="mt-12 grid gap-y-10 md:grid-cols-3 md:gap-x-16 md:gap-y-0">
          {steps.map((s) => (
            <div key={s.title} className="border-t border-line pt-6">
              <dt className="text-xl font-semibold text-ink">{s.title}</dt>
              <dd className="mt-3 max-w-[40ch] text-lg/7 text-pretty text-ink-muted sm:text-base/7">{s.body}</dd>
            </div>
          ))}
        </dl>

        <div className="mt-28 space-y-24 md:mt-36 md:space-y-32">
          <Split eyebrow="Setting up" title="It takes about ten seconds." media={<OnboardingMock />} flip>
            Your name, how long you can go before a break, and how long the break should last. After that it lives in
            the menu bar. There is no Dock icon and nothing to check on.
          </Split>

          <Split eyebrow="Settings" title="Change your mind whenever." media={<SettingsMock />}>
            Sliders for the limit, the rolling window, and the break length. Checkboxes for which apps, terminal
            tools, and websites count as AI. That is the whole settings screen.
          </Split>
        </div>
      </div>
    </section>
  );
}
