import DownloadButton from "./DownloadButton";

export default function CtaStrip({ heading = "Time to touch grass?" }: { heading?: string }) {
  return (
    <div className="mx-auto max-w-3xl px-6 py-20 text-center md:py-28">
      <h2 className="font-display font-semibold" style={{ color: "var(--color-accent-deep)", fontSize: "clamp(1.9rem, 5vw, 3rem)" }}>
        {heading}
      </h2>
      <div className="mt-7 flex flex-col items-center gap-3">
        <DownloadButton />
        <p className="text-sm text-ink-muted">Free &middot; macOS 13+ &middot; Apple Silicon &amp; Intel</p>
      </div>
    </div>
  );
}
