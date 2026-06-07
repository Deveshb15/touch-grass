import SwiftUI

/// The sky: a vertical day-cycle gradient with two soft far ridges sitting at the
/// horizon. Static apart from the colors, which follow block progress via the
/// `SkyColors` passed in — so this view only re-renders when `growth` changes.
struct SkyView: View {
    var size: CGSize
    var colors: SkyColors

    var body: some View {
        ZStack {
            LinearGradient(colors: [colors.top.color, colors.bottom.color],
                           startPoint: .top, endPoint: .bottom)

            // Far ridge (hazier, lighter) then a nearer one — a touch of depth at
            // the horizon. Their base sits just below the waterline (0.58H) so the
            // water, drawn on top, looks like it laps against distant hills.
            Ridge(base: 0.605, peaks: [(0.20, 0.520), (0.66, 0.505)])
                .fill(colors.hill.lightened(0.14).color)
            Ridge(base: 0.61, peaks: [(0.42, 0.545), (0.85, 0.535)])
                .fill(colors.hill.color)
        }
    }
}

/// A gentle rolling-hills silhouette: quadratic humps peaking at the given
/// fractional points, filled down to the bottom of the frame.
struct Ridge: Shape {
    /// Baseline (where humps return to), as a fraction of height.
    var base: Double
    /// Hump apexes as (x, y) fractions of the frame.
    var peaks: [(x: Double, y: Double)]

    func path(in rect: CGRect) -> Path {
        let W = rect.width, H = rect.height
        let baseY = H * base
        var p = Path()
        p.move(to: CGPoint(x: 0, y: baseY))
        var prevX = 0.0
        for peak in peaks {
            let apex = CGPoint(x: W * peak.x, y: H * peak.y)
            let endX = W * min(1, peak.x + (peak.x - prevX) + 0.06)
            p.addQuadCurve(to: CGPoint(x: endX, y: baseY), control: apex)
            prevX = peak.x
        }
        p.addLine(to: CGPoint(x: W, y: baseY))
        p.addLine(to: CGPoint(x: W, y: H))
        p.addLine(to: CGPoint(x: 0, y: H))
        p.closeSubpath()
        return p
    }
}

/// A few soft clouds drifting slowly across the upper sky. Pure function of the
/// continuous clock `t` (no state), drawn in one `Canvas` pass with radial-falloff
/// ellipses — no blur, so it stays cheap at 30fps full-screen.
struct CloudsCanvas: View {
    var size: CGSize
    var t: Double
    var tint: Color

    // (yFrac, widthFrac, heightFrac, speed px/s, phase 0…1, opacity)
    private let clouds: [(y: Double, w: Double, h: Double, speed: Double, phase: Double, op: Double)] = [
        (0.15, 0.24, 0.055, 6, 0.05, 0.50),
        (0.27, 0.32, 0.065, 9, 0.45, 0.40),
        (0.20, 0.18, 0.045, 5, 0.72, 0.45),
    ]

    var body: some View {
        Canvas { ctx, sz in
            let W = sz.width, H = sz.height
            for c in clouds {
                let cw = W * c.w, ch = H * c.h
                let margin = cw + 60
                let x = (t * c.speed + c.phase * (W + margin)).truncatingRemainder(dividingBy: W + margin) - cw
                let y = H * c.y
                let rect = CGRect(x: x - cw / 2, y: y - ch / 2, width: cw, height: ch)
                let shading = GraphicsContext.Shading.radialGradient(
                    Gradient(colors: [tint.opacity(c.op), tint.opacity(0)]),
                    center: CGPoint(x: x, y: y), startRadius: 0, endRadius: cw * 0.5)
                ctx.fill(Path(ellipseIn: rect), with: shading)
            }
        }
        .allowsHitTesting(false)
    }
}
