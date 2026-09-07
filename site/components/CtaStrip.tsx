import DownloadButton from "./DownloadButton";

export default function CtaStrip({ heading = "Ready to go outside?" }: { heading?: string }) {
  return (
    <div className="border-t border-line">
      <div className="mx-auto flex max-w-3xl flex-col items-center px-6 py-20 text-center md:py-24">
        <h2 className="max-w-[20ch] font-display text-5xl text-balance text-accent-deep sm:text-6xl">{heading}</h2>
        <div className="mt-8">
          <DownloadButton />
        </div>
        <p className="mt-4 text-base text-ink-muted sm:text-[0.9375rem]">Free and open source. macOS 13 or later.</p>
      </div>
    </div>
  );
}
