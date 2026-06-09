import { ImageResponse } from "next/og";

export const contentType = "image/png";

// Branded 1200×630 OpenGraph card. /og?title=…&eyebrow=…
export function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const title = (searchParams.get("title") ?? "Touch Grass").slice(0, 110);
  const eyebrow = (searchParams.get("eyebrow") ?? "touchgrass.rest").slice(0, 70);

  return new ImageResponse(
    (
      <div
        style={{
          height: "100%",
          width: "100%",
          display: "flex",
          flexDirection: "column",
          justifyContent: "space-between",
          padding: "76px 84px",
          background: "linear-gradient(135deg, #ead7ec 0%, #f6d7dd 36%, #fbe3d8 64%, #fdf3ea 100%)",
        }}
      >
        {/* eyebrow */}
        <div style={{ display: "flex", alignItems: "center", gap: "20px" }}>
          <div
            style={{
              display: "flex",
              width: "60px",
              height: "60px",
              borderRadius: "16px",
              background: "linear-gradient(135deg, #86b96a, #5a9e43)",
            }}
          />
          <div style={{ display: "flex", fontSize: "30px", color: "#9a86a6", fontWeight: 600 }}>{eyebrow}</div>
        </div>
        {/* title */}
        <div
          style={{
            display: "flex",
            fontSize: title.length > 38 ? "76px" : "94px",
            fontWeight: 700,
            color: "#7a3f58",
            lineHeight: 1.04,
            letterSpacing: "-0.02em",
            maxWidth: "1000px",
          }}
        >
          {title}
        </div>
        {/* footer */}
        <div style={{ display: "flex", fontSize: "28px", color: "#9a86a6" }}>
          Touch Grass — free, open-source macOS app
        </div>
      </div>
    ),
    { width: 1200, height: 630 }
  );
}
