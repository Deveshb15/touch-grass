import { ISSUES_URL } from "@/lib/site";
import DownloadButton from "./DownloadButton";

const facts: { title: string; body: string }[] = [
  {
    title: "Nothing leaves your Mac.",
    body:
      "No account, no analytics, no server. To spot AI websites it reads the address of your browser’s current tab, on your machine, and throws it away.",
  },
  {
    title: "Background agents count.",
    body:
      "If Claude or Codex is working away in a terminal while you make coffee, that time still goes on the clock.",
  },
  {
    title: "You can always quit.",
    body:
      "A break ends on its own timer. If you truly need out, quit the app. There is no daemon fighting you.",
  },
  {
    title: "The source is open.",
    body:
      "MIT licensed on GitHub. Read it, build it yourself, and change the timings if you disagree with them.",
  },
];

export default function Ethos() {
  return (
    <section className="bg-paper-2 py-20 md:py-28">
      <div className="mx-auto max-w-6xl px-6">
        <h2 className="max-w-[24ch] font-display text-5xl text-balance text-accent-deep sm:text-6xl">
          A few things worth knowing
        </h2>

        <dl className="mt-12 grid gap-x-16 gap-y-10 md:grid-cols-2">
          {facts.map((f) => (
            <div key={f.title} className="border-t border-line pt-6">
              <dt className="text-xl font-semibold text-ink">{f.title}</dt>
              <dd className="mt-3 max-w-[44ch] text-lg/7 text-pretty text-ink-muted sm:text-base/7">{f.body}</dd>
            </div>
          ))}
        </dl>

        <p className="mt-16 max-w-[52ch] text-lg/7 text-pretty text-ink">
          Touch Grass is made by one person, in Swift, for a very specific problem. If something breaks, or you want
          an app added to the list, please{" "}
          <a href={ISSUES_URL} className="font-medium underline decoration-ink/30 underline-offset-4 hover:decoration-ink">
            open an issue
          </a>
          .
        </p>
      </div>

      <div className="mx-auto mt-24 flex max-w-3xl flex-col items-center px-6 text-center md:mt-32">
        <h2 className="max-w-[16ch] font-display text-6xl text-balance text-accent-deep sm:text-7xl">
          Go on, then.
        </h2>
        <div className="mt-8">
          <DownloadButton />
        </div>
        <p className="mt-4 text-base text-ink-muted sm:text-[0.9375rem]">Free and open source. macOS 13 or later.</p>
      </div>
    </section>
  );
}
