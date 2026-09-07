/* eslint-disable @next/next/no-img-element */
import { ImageResponse } from "next/og";
import { readFile } from "node:fs/promises";
import path from "node:path";

export const contentType = "image/png";

// Branded 1200×630 OpenGraph card, styled like the site: pink dawn sky, a soft
// sun, the serif wordmark and title, and the real break screenshot in a frame.
// /og?title=…&eyebrow=…

const load = (...parts: string[]) => readFile(path.join(process.cwd(), ...parts));
const toDataUrl = (buf: Buffer, type: string) => `data:${type};base64,${buf.toString("base64")}`;

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const title = (searchParams.get("title") ?? "The Mac app that sends you outside.").slice(0, 90);
  const eyebrow = (searchParams.get("eyebrow") ?? "Touch Grass").slice(0, 60);

  const [serif, serifItalic, sans, shot, icon] = await Promise.all([
    load("app", "og", "fonts", "InstrumentSerif-Regular.ttf"),
    load("app", "og", "fonts", "InstrumentSerif-Italic.ttf"),
    load("app", "og", "fonts", "Figtree-Medium.ttf"),
    load("public", "shots", "block.png"),
    load("public", "shots", "icon.png"),
  ]);

  const size = title.length > 40 ? 66 : title.length > 24 ? 80 : 96;
  const plum = "#6b3a52";
  const ink = "#5a4a66";
  const muted = "#8b7a95";
  const green = "#4f8a3d";

  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          position: "relative",
          overflow: "hidden",
          fontFamily: "Figtree",
          background: "linear-gradient(180deg, #ead6eb 0%, #f5d6dd 30%, #fbe2d6 60%, #fdf1e6 100%)",
        }}
      >
        {/* sun */}
        <div
          style={{
            position: "absolute",
            left: 700,
            top: -240,
            width: 560,
            height: 560,
            borderRadius: 9999,
            background: "radial-gradient(circle, rgba(255,255,255,1) 0%, rgba(249,218,184,0.95) 30%, rgba(249,218,184,0) 68%)",
          }}
        />
        {/* clouds */}
        <div style={{ position: "absolute", left: -60, top: 150, width: 460, height: 80, borderRadius: 9999, background: "radial-gradient(ellipse, rgba(255,255,255,0.75) 0%, rgba(255,255,255,0) 70%)" }} />
        <div style={{ position: "absolute", left: 300, top: 40, width: 360, height: 70, borderRadius: 9999, background: "radial-gradient(ellipse, rgba(255,255,255,0.6) 0%, rgba(255,255,255,0) 70%)" }} />
        {/* birds */}
        <svg style={{ position: "absolute", left: 560, top: 150 }} width="120" height="40" viewBox="0 0 120 40" fill="none">
          <path d="M4 22c8-12 16-12 22 0 6-12 14-12 22 0" stroke={muted} strokeWidth="2.4" strokeLinecap="round" opacity="0.55" />
          <path d="M70 10c6-9 12-9 17 0 5-9 11-9 17 0" stroke={muted} strokeWidth="2.2" strokeLinecap="round" opacity="0.45" />
        </svg>

        {/* wordmark */}
        <div style={{ position: "absolute", left: 72, top: 60, display: "flex", alignItems: "center", gap: 14 }}>
          <img alt="" src={toDataUrl(icon, "image/png")} width={44} height={44} style={{ borderRadius: 11 }} />
          <div style={{ display: "flex", fontFamily: "Instrument Serif", fontStyle: "italic", fontSize: 40, color: plum }}>
            touch grass
          </div>
        </div>

        {/* text column */}
        <div style={{ position: "absolute", left: 72, top: 176, width: 540, display: "flex", flexDirection: "column" }}>
          <div style={{ display: "flex", fontSize: 26, color: green }}>{eyebrow}</div>
          <div
            style={{
              display: "flex",
              marginTop: 20,
              fontFamily: "Instrument Serif",
              fontSize: size,
              lineHeight: 0.98,
              letterSpacing: -1.5,
              color: plum,
            }}
          >
            {title}
          </div>
        </div>

        {/* footer line */}
        <div style={{ position: "absolute", left: 72, bottom: 60, display: "flex", alignItems: "center", gap: 14, fontSize: 24, color: ink }}>
          <div style={{ display: "flex" }}>touchgrass.rest</div>
          <div style={{ display: "flex", width: 6, height: 6, borderRadius: 9999, background: green }} />
          <div style={{ display: "flex", color: muted }}>Free and open source for macOS</div>
        </div>

        {/* the break, whole, with a little tilt */}
        <div
          style={{
            position: "absolute",
            right: 56,
            top: 178,
            width: 500,
            height: 312,
            display: "flex",
            borderRadius: 22,
            overflow: "hidden",
            transform: "rotate(-5deg)",
            boxShadow: "0 40px 80px -28px rgba(107,58,82,0.55), 0 0 0 1px rgba(107,58,82,0.14), 0 0 0 10px rgba(255,255,255,0.45)",
          }}
        >
          <img alt="" src={toDataUrl(shot, "image/png")} width={500} height={312} style={{ objectFit: "cover" }} />
        </div>
      </div>
    ),
    {
      width: 1200,
      height: 630,
      fonts: [
        { name: "Instrument Serif", data: serif, weight: 400, style: "normal" },
        { name: "Instrument Serif", data: serifItalic, weight: 400, style: "italic" },
        { name: "Figtree", data: sans, weight: 500, style: "normal" },
      ],
    }
  );
}
