import SwiftUI

/// A small, loose flock of distant gulls drifting across the upper sky. Each bird
/// is the classic shallow "⌒⌒" stroke; it glides at its own speed/height, bobs
/// gently, beats its wings on its own cadence, and wraps around when it leaves the
/// frame — so the flock "keeps flying" for the whole block.
///
/// Everything is a pure function of the continuous clock `t` (no `@State`, no
/// `repeatForever`), drawn in a single `Canvas` pass — cheap enough for 30fps
/// full-screen. Three depth tiers (far/faint/slow → near/darker/fast) give parallax.
struct BirdsCanvas: View {
    var size: CGSize
    var t: Double
    var tint: Color

    private struct Bird {
        let yFrac: Double      // resting height
        let span: Double       // half-wingspan, fraction of width
        let opacity: Double
        let speed: Double      // px/sec
        let bob: Double        // vertical bob amplitude, fraction of height
        let flap: Double       // wing-beats: radians/sec
        let phase: Double
    }

    private let birds: [Bird] = [
        Bird(yFrac: 0.15, span: 0.016, opacity: 0.32, speed: 13, bob: 0.012, flap: 3.4, phase: 0.0),
        Bird(yFrac: 0.21, span: 0.018, opacity: 0.36, speed: 15, bob: 0.013, flap: 3.9, phase: 2.1),
        Bird(yFrac: 0.19, span: 0.026, opacity: 0.48, speed: 21, bob: 0.015, flap: 4.3, phase: 3.7),
        Bird(yFrac: 0.28, span: 0.028, opacity: 0.50, speed: 23, bob: 0.015, flap: 4.1, phase: 5.0),
        Bird(yFrac: 0.24, span: 0.038, opacity: 0.58, speed: 29, bob: 0.018, flap: 4.7, phase: 1.2),
    ]

    var body: some View {
        Canvas { ctx, sz in
            let W = sz.width, H = sz.height
            let lineW = max(1.2, W * 0.0015)
            for b in birds {
                let span = W * b.span
                let margin = span * 2 + 30
                let x = (t * b.speed + b.phase * 97).truncatingRemainder(dividingBy: W + margin) - span
                let y = H * b.yFrac + sin(t * 0.5 + b.phase) * H * b.bob
                // Wing dip oscillates → the "⌒⌒" flattens and deepens (a wingbeat).
                let dip = span * (0.45 + 0.32 * sin(t * b.flap + b.phase))

                var p = Path()
                p.move(to: CGPoint(x: x - span, y: y))
                p.addQuadCurve(to: CGPoint(x: x, y: y),
                               control: CGPoint(x: x - span * 0.5, y: y - dip))
                p.addQuadCurve(to: CGPoint(x: x + span, y: y),
                               control: CGPoint(x: x + span * 0.5, y: y - dip))
                ctx.stroke(p, with: .color(tint.opacity(b.opacity)),
                           style: StrokeStyle(lineWidth: lineW, lineCap: .round))
            }
        }
        .allowsHitTesting(false)
    }
}
