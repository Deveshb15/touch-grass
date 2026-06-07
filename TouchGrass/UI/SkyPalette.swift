import SwiftUI

// MARK: - RGBA

/// A simple sRGB color with component access, so we can interpolate between
/// stops on macOS 13 (where `Color.mix` — macOS 15 — isn't available). Plain
/// linear component lerp is plenty for a stylized sky; no gamma-correct mixing.
struct RGBA {
    var r, g, b, a: Double

    init(_ r: Double, _ g: Double, _ b: Double, _ a: Double = 1) {
        self.r = r; self.g = g; self.b = b; self.a = a
    }

    /// 0xRRGGBB.
    init(hex: UInt32, a: Double = 1) {
        self.r = Double((hex >> 16) & 0xFF) / 255
        self.g = Double((hex >> 8) & 0xFF) / 255
        self.b = Double(hex & 0xFF) / 255
        self.a = a
    }

    var color: Color { Color(.sRGB, red: r, green: g, blue: b, opacity: a) }

    func opacity(_ o: Double) -> RGBA { RGBA(r, g, b, a * o) }
    /// Toward black.
    func darkened(_ f: Double) -> RGBA { RGBA(r * (1 - f), g * (1 - f), b * (1 - f), a) }
    /// Toward white.
    func lightened(_ f: Double) -> RGBA { RGBA(r + (1 - r) * f, g + (1 - g) * f, b + (1 - b) * f, a) }
}

/// Linear interpolation between two colors. `f` is clamped to 0…1.
func lerp(_ x: RGBA, _ y: RGBA, _ f: Double) -> RGBA {
    let t = min(1, max(0, f))
    return RGBA(x.r + (y.r - x.r) * t,
               x.g + (y.g - x.g) * t,
               x.b + (y.b - x.b) * t,
               x.a + (y.a - x.a) * t)
}

// MARK: - SkyColors

/// Everything the landscape needs to paint itself at a given block-progress.
struct SkyColors {
    let top, bottom: RGBA   // sky gradient
    let sun: RGBA           // sun disc + glow tint
    let water: RGBA         // water surface base
    let cloud: RGBA         // cloud fill
    let hill: RGBA          // far-ridge silhouette
    let bird: RGBA          // bird silhouette
    let ink: RGBA           // adaptive text color
}

// MARK: - Day-cycle ramp

/// Maps block-progress (`growth`, 0 = block start = dawn → 1 = block end = dusk)
/// to a coherent warm palette that drifts dawn → morning → midday → golden hour
/// → dusk. Midday anchors to the original `Palette` (creamTop/sandBottom/glow) so
/// the new scene reads as an evolution of the old beige garden, not a rewrite.
enum SkyPalette {
    private struct Key {
        let stop: Double
        let top, bottom, sun, water: RGBA
    }

    private static let keys: [Key] = [
        // Dawn — soft lavender over a peach horizon, low amber sun.
        Key(stop: 0.00, top: RGBA(hex: 0xC9B6D4), bottom: RGBA(hex: 0xF4C9A8),
            sun: RGBA(hex: 0xF7B27A), water: RGBA(hex: 0xC8B7C0)),
        // Morning — clean blue-grey lifting off a pale gold horizon.
        Key(stop: 0.25, top: RGBA(hex: 0xBFD3DA), bottom: RGBA(hex: 0xF6E2C4),
            sun: RGBA(hex: 0xFBD98C), water: RGBA(hex: 0xBFD0CE)),
        // Midday — the original palette: creamTop / sandBottom / glow.
        Key(stop: 0.50, top: RGBA(hex: 0xF3EAD8), bottom: RGBA(hex: 0xE4D3B8),
            sun: RGBA(hex: 0xFBF3E2), water: RGBA(hex: 0xDDD0BC)),
        // Golden hour — amber sky, coral horizon (≈ the plant's petal color).
        Key(stop: 0.78, top: RGBA(hex: 0xE9B98E), bottom: RGBA(hex: 0xF0A878),
            sun: RGBA(hex: 0xF4954F), water: RGBA(hex: 0xE0A983)),
        // Dusk — dusty violet over deep rose, a low ember sun.
        Key(stop: 1.00, top: RGBA(hex: 0x6E5A7B), bottom: RGBA(hex: 0xD98A86),
            sun: RGBA(hex: 0xE8915C), water: RGBA(hex: 0x8A6E84)),
    ]

    private static let espresso = RGBA(hex: 0x4A3F30)
    private static let cream = RGBA(hex: 0xF6EBDD)

    static func ramp(at growth: Double) -> SkyColors {
        let g = min(1, max(0, growth))

        // Find the bracketing keyframes and the fraction between them.
        var lo = keys[0], hi = keys[keys.count - 1]
        for i in 0..<(keys.count - 1) where g >= keys[i].stop && g <= keys[i + 1].stop {
            lo = keys[i]; hi = keys[i + 1]; break
        }
        let f = (g - lo.stop) / max(0.0001, hi.stop - lo.stop)

        let top = lerp(lo.top, hi.top, f)
        let bottom = lerp(lo.bottom, hi.bottom, f)
        let sun = lerp(lo.sun, hi.sun, f)
        let water = lerp(lo.water, hi.water, f)

        return SkyColors(
            top: top,
            bottom: bottom,
            sun: sun,
            water: water,
            cloud: lerp(bottom, RGBA(1, 1, 1, 0.92), 0.5),
            hill: bottom.darkened(0.18),
            bird: espresso,
            // Espresso stays legible through golden hour; warm toward cream only
            // once the sky turns deep violet at dusk.
            ink: lerp(espresso, cream, max(0, (g - 0.80) / 0.20))
        )
    }
}
