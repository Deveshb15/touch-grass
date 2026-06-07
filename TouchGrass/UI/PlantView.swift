import SwiftUI

// MARK: - Palette

/// Warm-beige garden palette for the block overlay ("Textured bloom" direction).
enum Palette {
    static let creamTop  = Color(red: 0.953, green: 0.918, blue: 0.847) // #F3EAD8
    static let sandBottom = Color(red: 0.894, green: 0.827, blue: 0.722) // #E4D3B8
    static let glow      = Color(red: 0.984, green: 0.953, blue: 0.886) // #FBF3E2
    static let soil      = Color(red: 0.788, green: 0.706, blue: 0.573) // #C9B492
    static let stem      = Color(red: 0.431, green: 0.478, blue: 0.333) // #6E7A55
    static let leaf      = Color(red: 0.525, green: 0.604, blue: 0.400) // #869A66
    static let leafLight = Color(red: 0.608, green: 0.682, blue: 0.482) // #9BAE7B
    static let petal     = Color(red: 0.910, green: 0.659, blue: 0.486) // #E8A87C
    static let petalCore = Color(red: 0.949, green: 0.784, blue: 0.475) // #F2C879
    static let espresso  = Color(red: 0.290, green: 0.247, blue: 0.188) // #4A3F30
}

// MARK: - Stem geometry (shared by the Stem shape and leaf placement)

/// The four control points of the stem's S-curve, derived from the canvas size
/// so the `Stem` shape and the leaf attach points always agree.
struct StemAnchors {
    let base: CGPoint   // roots, bottom-center
    let c1: CGPoint
    let c2: CGPoint
    let top: CGPoint    // where the flower sits
}

func stemAnchors(_ size: CGSize) -> StemAnchors {
    StemAnchors(
        base: CGPoint(x: size.width * 0.50, y: size.height * 0.98),
        c1:   CGPoint(x: size.width * 0.30, y: size.height * 0.64),
        c2:   CGPoint(x: size.width * 0.70, y: size.height * 0.30),
        top:  CGPoint(x: size.width * 0.50, y: size.height * 0.08)
    )
}

/// Point on the stem's cubic Bézier at parameter `t` (0 = base, 1 = top).
func bezier(_ a: StemAnchors, _ t: CGFloat) -> CGPoint {
    let mt = 1 - t
    let x = mt*mt*mt*a.base.x + 3*mt*mt*t*a.c1.x + 3*mt*t*t*a.c2.x + t*t*t*a.top.x
    let y = mt*mt*mt*a.base.y + 3*mt*mt*t*a.c1.y + 3*mt*t*t*a.c2.y + t*t*t*a.top.y
    return CGPoint(x: x, y: y)
}

// MARK: - Shapes

/// The stem itself. Drawn on via `.trim` as the block elapses.
struct Stem: Shape {
    func path(in rect: CGRect) -> Path {
        let a = stemAnchors(rect.size)
        var p = Path()
        p.move(to: a.base)
        p.addCurve(to: a.top, control1: a.c1, control2: a.c2)
        return p
    }
}

/// An almond/lens leaf that unfurls from `attach` toward `angle`. Growth is
/// baked into the path (via `animatableData`) so the leaf extends and widens
/// smoothly as `grow` 0→1, anchored at the stem rather than scaling in place.
struct Leaf: Shape {
    var attach: CGPoint
    var angle: CGFloat      // radians; -.pi/2 points straight up (y grows downward)
    var length: CGFloat
    var width: CGFloat
    var grow: CGFloat       // 0...1

    var animatableData: CGFloat {
        get { grow }
        set { grow = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let g = max(0, min(1, grow))
        guard g > 0.001 else { return Path() }
        let len = length * g
        let wid = width * g
        let tip = CGPoint(x: attach.x + cos(angle) * len,
                          y: attach.y + sin(angle) * len)
        let mid = CGPoint(x: attach.x + cos(angle) * len * 0.5,
                          y: attach.y + sin(angle) * len * 0.5)
        let perp = angle + .pi / 2
        let left  = CGPoint(x: mid.x + cos(perp) * wid, y: mid.y + sin(perp) * wid)
        let right = CGPoint(x: mid.x - cos(perp) * wid, y: mid.y - sin(perp) * wid)

        var p = Path()
        p.move(to: attach)
        p.addQuadCurve(to: tip, control: left)
        p.addQuadCurve(to: attach, control: right)
        p.closeSubpath()
        return p
    }
}

// MARK: - Flower

/// The bloom at the stem's tip. `open` 0→1 takes it from a tight bud to a fully
/// splayed flower; the petals fan outward as it opens.
private struct Flower: View {
    var open: CGFloat   // 0...1

    private let petals = 8

    var body: some View {
        ZStack {
            ForEach(0..<petals, id: \.self) { i in
                Ellipse()
                    .fill(LinearGradient(colors: [Palette.petal, Palette.petalCore],
                                         startPoint: .bottom, endPoint: .top))
                    .frame(width: 16, height: 26)
                    .offset(y: -(9 + 13 * open))
                    .rotationEffect(.degrees(Double(i) / Double(petals) * 360.0))
            }
            Circle().fill(Palette.petalCore).frame(width: 18, height: 18)
            Circle().fill(.white.opacity(0.35)).frame(width: 7, height: 7)
        }
        // A closed bud is slightly twisted; it untwists as it opens.
        .rotationEffect(.degrees(Double(1 - open) * 22))
    }
}

// MARK: - Plant

/// The whole plant: soil mound, stem, leaves, and bloom. Growth is driven from
/// the caller (block progress); the gentle sway runs on its own forever-loop.
struct PlantView: View {
    var growth: Double
    @State private var sway = false

    // Leaf pairs along the stem: (t on stem, growth threshold, side, length, width)
    private let leaves: [(t: CGFloat, appear: Double, side: CGFloat, len: CGFloat, wid: CGFloat)] = [
        (0.32, 0.16,  1, 0.34, 0.12),
        (0.32, 0.20, -1, 0.32, 0.11),
        (0.54, 0.38,  1, 0.30, 0.11),
        (0.54, 0.42, -1, 0.28, 0.10),
        (0.74, 0.58,  1, 0.24, 0.09),
        (0.74, 0.62, -1, 0.22, 0.08),
    ]

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let a = stemAnchors(size)

            ZStack {
                // Soil mound — stays put (no sway). Radial fill so the edges
                // melt into the background instead of reading as a hard disc.
                Ellipse()
                    .fill(RadialGradient(colors: [Palette.soil, Palette.soil.opacity(0)],
                                         center: .center,
                                         startRadius: 2, endRadius: size.width * 0.34))
                    .frame(width: size.width * 0.80, height: size.height * 0.13)
                    .position(x: size.width * 0.5, y: size.height * 0.965)

                // Everything that grows + sways.
                ZStack {
                    backFoliage(size: size, a: a)

                    Stem()
                        .trim(from: 0, to: stemGrow)
                        .stroke(Palette.stem,
                                style: StrokeStyle(lineWidth: max(4, size.width * 0.022),
                                                   lineCap: .round))
                        .animation(.linear(duration: 0.5), value: growth)

                    ForEach(0..<leaves.count, id: \.self) { i in
                        let s = leaves[i]
                        let base = s.side > 0 ? Palette.leaf : Palette.leafLight
                        Leaf(attach: bezier(a, s.t),
                             angle: -.pi / 2 + s.side * 0.62,
                             length: size.height * s.len,
                             width: size.height * s.wid,
                             grow: leafGrow(s.appear))
                            .fill(LinearGradient(colors: [Palette.stem.opacity(0.55), base],
                                                 startPoint: .bottom, endPoint: .top))
                            .animation(.spring(response: 0.8, dampingFraction: 0.7), value: growth)
                    }

                    Flower(open: flowerOpen)
                        .scaleEffect(max(0.001, flowerAppear))
                        .opacity(min(1, Double(flowerAppear) * 1.3))
                        .position(x: a.top.x, y: a.top.y + 1)
                        .animation(.spring(response: 0.7, dampingFraction: 0.6), value: growth)
                }
                .rotationEffect(.degrees(sway ? 2.5 : -2.5), anchor: .bottom)
                .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: sway)
            }
        }
        .onAppear { sway = true }
    }

    private var stemGrow: CGFloat { min(1, CGFloat(growth) / 0.85) }
    /// Bud fades/scales in only once the stem has reached the top (≈0.85) …
    private var flowerAppear: CGFloat { CGFloat(max(0, min(1, (growth - 0.82) / 0.08))) }
    /// … then the petals open over the final stretch.
    private var flowerOpen: CGFloat { CGFloat(max(0, min(1, (growth - 0.88) / 0.12))) }

    private func leafGrow(_ appearAt: Double) -> CGFloat {
        CGFloat(max(0, min(1, (growth - appearAt) / 0.22)))
    }

    /// Two larger, lighter, blurred leaves sitting behind the stem for depth.
    @ViewBuilder
    private func backFoliage(size: CGSize, a: StemAnchors) -> some View {
        ForEach(0..<2, id: \.self) { i in
            let side: CGFloat = i == 0 ? -1 : 1
            Leaf(attach: bezier(a, 0.42),
                 angle: -.pi / 2 + side * 0.95,
                 length: size.height * 0.36,
                 width: size.height * 0.13,
                 grow: leafGrow(0.45))
                .fill(Palette.leafLight.opacity(0.45))
                .blur(radius: 7)
                .animation(.spring(response: 0.9, dampingFraction: 0.7), value: growth)
        }
    }
}

// MARK: - Grain

/// A static film-grain texture (drawn once, deterministic) for warmth. Composited
/// with `.overlay` blend at low opacity — no per-frame work, no animation.
struct GrainOverlay: View {
    var body: some View {
        Canvas { ctx, size in
            var seed: UInt64 = 0x9E3779B97F4A7C15
            func rnd() -> Double {
                seed ^= seed << 13
                seed ^= seed >> 7
                seed ^= seed << 17
                return Double(seed % 100_000) / 100_000.0
            }
            let count = min(4000, Int(size.width * size.height / 900))
            for _ in 0..<count {
                let x = rnd() * size.width
                let y = rnd() * size.height
                let s = 0.6 + rnd() * 0.9
                let alpha = 0.03 + rnd() * 0.05
                ctx.fill(Path(ellipseIn: CGRect(x: x, y: y, width: s, height: s)),
                         with: .color(.black.opacity(alpha)))
            }
        }
        .blendMode(.overlay)
        .allowsHitTesting(false)
    }
}
