import SwiftUI

/// The sun's position along its rise → peak → set arc, as a function of block
/// progress (`growth`, 0…1). It sweeps left → right and rides a parabolic height
/// (low at dawn/dusk, highest at midday), never dropping below the waterline.
/// Shared by `SunView` (the disc) and `WaterView` (its reflection column).
func sunPosition(in size: CGSize, growth: Double) -> CGPoint {
    let g = min(1, max(0, growth))
    let x = size.width * (0.18 + 0.64 * g)
    let arc = sin(g * .pi)                       // 0 at the ends, 1 at midday
    let y = size.height * (0.44 - 0.30 * arc)    // 0.44 (low) → 0.14 (high)
    return CGPoint(x: x, y: y)
}

/// The sun: a soft glowing disc with a layered radial halo, positioned on the
/// arc and tinted by the day-cycle. It "breathes" gently (the same slow pulse the
/// old scene had, now attached to the sun). Color/position follow `growth`; the
/// breathe is a single implicit animation, so no per-frame work here.
struct SunView: View {
    var size: CGSize
    var growth: Double
    var tint: Color
    var animate: Bool

    @State private var breathe = false

    var body: some View {
        let pos = sunPosition(in: size, growth: growth)
        let g = min(1, max(0, growth))
        let lowness = 1 - sin(g * .pi)               // 0 midday, 1 at dawn/dusk
        let disc = size.width * (0.10 + 0.045 * lowness)   // bigger & softer when low
        let glow = disc * 3.2

        ZStack {
            // Wide atmospheric bloom.
            RadialGradient(colors: [tint.opacity(0.34), tint.opacity(0)],
                           center: .center, startRadius: 0, endRadius: glow * 1.6)
                .frame(width: glow * 3.2, height: glow * 3.2)
            // Tighter glow around the disc.
            RadialGradient(colors: [tint.opacity(0.9), tint.opacity(0)],
                           center: .center, startRadius: 0, endRadius: glow)
                .frame(width: glow * 2, height: glow * 2)
            // The disc itself — a hot near-white center melting into the tint.
            Circle()
                .fill(RadialGradient(colors: [Color.white.opacity(0.95), tint],
                                     center: .center, startRadius: 0, endRadius: disc * 0.5))
                .frame(width: disc, height: disc)
        }
        .scaleEffect(animate && breathe ? 1.04 : 0.98)
        .opacity(0.96)
        .position(pos)
        .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: breathe)
        .onAppear { if animate { breathe = true } }
    }
}
