import SwiftUI

/// The calm pond that fills the lower-middle of the scene. It reflects the sky's
/// current color, shimmers along the sun's reflection, and ripples gently — all
/// pure functions of the continuous clock `t`, drawn in one `Canvas` pass confined
/// to the water band (no full-screen overdraw, no blur).
struct WaterView: View {
    var size: CGSize
    var t: Double
    var growth: Double
    var surface: RGBA      // base water color from the day-cycle
    var sunTint: RGBA

    /// Waterline and floor as fractions of height. Kept in sync with the scene
    /// composition in `TouchGrassView`. The floor runs under the shore crest
    /// (~0.85H) so the shore, drawn on top, hides the water's lower edge.
    static let topFrac = 0.58
    static let bottomFrac = 0.86

    var body: some View {
        Canvas { ctx, sz in
            let W = sz.width, H = sz.height
            let top = H * WaterView.topFrac
            let bottom = H * WaterView.bottomFrac
            let band = CGRect(x: 0, y: top, width: W, height: bottom - top)

            // Base: darker at the far edge, lighter as it nears the viewer.
            ctx.fill(Path(band), with: .linearGradient(
                Gradient(colors: [surface.darkened(0.12).color, surface.lightened(0.12).color]),
                startPoint: CGPoint(x: 0, y: top), endPoint: CGPoint(x: 0, y: bottom)))

            // The catch-light where the surface meets the sky.
            var line = Path()
            line.move(to: CGPoint(x: 0, y: top))
            line.addLine(to: CGPoint(x: W, y: top))
            ctx.stroke(line, with: .color(.white.opacity(0.16)), lineWidth: 1)

            // Sun reflection: a column of glints directly below the sun, wobbling.
            let sunX = sunPosition(in: sz, growth: growth).x
            let colW = max(46, W * 0.055)
            let glints = 9
            for i in 0..<glints {
                let f = Double(i) / Double(glints - 1)
                let y = top + (bottom - top) * f
                let wob = sin(t * 1.5 + f * 6) * (colW * 0.22)
                let w = colW * (0.45 + 0.55 * abs(sin(t * 1.1 + f * 3))) + colW * 0.25
                let r = CGRect(x: sunX - w / 2 + wob, y: y - 1.6, width: w, height: 3.2)
                ctx.fill(Path(roundedRect: r, cornerRadius: 1.6),
                         with: .color(sunTint.opacity(0.32 * (1 - f * 0.45)).color))
            }

            // Ripples: faint horizontal sine lines, larger and brighter near the
            // viewer for a touch of perspective.
            let ripples = 6
            let freq = Double.pi * 2 / (W * 0.5)
            for i in 0..<ripples {
                let f = (Double(i) + 0.5) / Double(ripples)
                let baseY = top + (bottom - top) * f
                let amp = (1 + f * 1.4) * 2.0
                var p = Path()
                var x = 0.0
                var first = true
                while x <= W {
                    let yy = baseY + sin(x * freq + t * 0.8 + f * 4) * amp
                    if first { p.move(to: CGPoint(x: x, y: yy)); first = false }
                    else { p.addLine(to: CGPoint(x: x, y: yy)) }
                    x += 10
                }
                ctx.stroke(p, with: .color(.white.opacity(0.09 + f * 0.06)), lineWidth: 1)
            }
        }
        .allowsHitTesting(false)
    }
}

/// The near shore: a warm soil bank along the bottom that the plant roots into,
/// with a few sparse grass blades. Static (the plant carries the motion), so it's
/// drawn once and only re-tinted nothing-per-frame.
struct ShoreView: View {
    var size: CGSize

    private let soilTop = Palette.soil
    private let soilBottom = Color(red: 0.60, green: 0.52, blue: 0.40)

    // Grass blades: (xFrac, heightFrac, lean, color)
    private let blades: [(x: Double, h: Double, lean: Double, light: Bool)] = [
        (0.18, 0.055, -0.018, false), (0.235, 0.075, 0.012, true),
        (0.40, 0.05, 0.02, false), (0.52, 0.065, -0.015, true),
        (0.68, 0.045, 0.018, false), (0.80, 0.07, -0.02, true),
        (0.90, 0.05, 0.014, false),
    ]

    var body: some View {
        let W = size.width, H = size.height
        let crest = H * 0.855

        ZStack {
            // The bank, with a gently undulating crest.
            Path { p in
                p.move(to: CGPoint(x: 0, y: crest + H * 0.012))
                p.addCurve(to: CGPoint(x: W, y: crest - H * 0.006),
                           control1: CGPoint(x: W * 0.32, y: crest - H * 0.016),
                           control2: CGPoint(x: W * 0.66, y: crest + H * 0.012))
                p.addLine(to: CGPoint(x: W, y: H))
                p.addLine(to: CGPoint(x: 0, y: H))
                p.closeSubpath()
            }
            .fill(LinearGradient(colors: [soilTop, soilBottom], startPoint: .top, endPoint: .bottom))

            // Sparse grass.
            ForEach(0..<blades.count, id: \.self) { i in
                let b = blades[i]
                let baseX = W * b.x
                let baseY = crest + H * 0.004
                let h = H * b.h
                let tip = CGPoint(x: baseX + W * b.lean, y: baseY - h)
                Path { p in
                    p.move(to: CGPoint(x: baseX - 2, y: baseY))
                    p.addQuadCurve(to: tip, control: CGPoint(x: baseX + W * b.lean * 0.4, y: baseY - h * 0.55))
                    p.addQuadCurve(to: CGPoint(x: baseX + 2, y: baseY), control: CGPoint(x: baseX, y: baseY - h * 0.4))
                }
                .fill(b.light ? Palette.leafLight : Palette.stem)
            }
        }
    }
}
