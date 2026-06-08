import SwiftUI
import AppKit

/// The shared "magical pink dawn" visual language used by the first-run onboarding
/// and the settings window. Extracted into one place so the two screens stay in
/// sync — everything is explicit light colors + custom rounded controls, meant to
/// live on a window pinned to light appearance (system controls render light + pink).

enum DawnPalette {
    static let inkPrimary  = RGBA(hex: 0x5B4A66).color   // deep plum
    static let inkMuted    = RGBA(hex: 0x9A86A6).color   // mauve
    static let accentRose  = RGBA(hex: 0xF4A9BC).color   // rose accent
    static let accentRose2 = RGBA(hex: 0xF7C9B0).color   // peach-rose (gradient partner)
    static let deepRose    = RGBA(hex: 0x7A3F58).color   // CTA text
    static let ctaA        = RGBA(hex: 0xF8C7D2).color   // blush → peach CTA gradient
    static let ctaB        = RGBA(hex: 0xF9D9C2).color
    static let cardFill    = RGBA(hex: 0xFBEFF1).color   // frosted card bottom tint
    static let shadow      = RGBA(hex: 0x7A5A6B).color   // warm card shadow
    static let positive    = RGBA(hex: 0x6FAE7E).color   // calm green for "ok" states

    // Landscape tints.
    static let skyTop   = RGBA(hex: 0xEAD7EC).color
    static let skyHi    = RGBA(hex: 0xF6D7DD).color
    static let skyMid   = RGBA(hex: 0xFBE3D8).color
    static let skyBot   = RGBA(hex: 0xFDF3EA).color
    static let sunTint  = RGBA(hex: 0xF7C9A8).color
    static let cloudTint = RGBA(hex: 0xFCEAF0).color
    static let birdTint = RGBA(hex: 0x9B7FA6).color

    /// The window's opaque base color (no-flash before SwiftUI paints).
    static let windowNSColor = NSColor(srgbRed: 0.918, green: 0.843, blue: 0.925, alpha: 1)
}

// MARK: - Live pink-dawn landscape

/// The soft pastel sunrise with a pulsing sun + drifting clouds & birds. Fills its
/// space; pauses its animation under Reduce Motion. Reused by onboarding + settings.
struct DawnBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let epoch = Date().timeIntervalSinceReferenceDate

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            ZStack {
                LinearGradient(
                    colors: [DawnPalette.skyTop, DawnPalette.skyHi, DawnPalette.skyMid, DawnPalette.skyBot],
                    startPoint: .top, endPoint: .bottom)

                // Gentle bloom low-center so the card seems to glow off the horizon.
                RadialGradient(colors: [Color.white.opacity(0.5), Color.white.opacity(0)],
                               center: UnitPoint(x: 0.5, y: 0.72),
                               startRadius: 0, endRadius: size.width * 0.85)

                TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: reduceMotion)) { tl in
                    let t = tl.date.timeIntervalSinceReferenceDate - epoch
                    let g = reduceMotion ? 0.16 : Self.sunriseGrowth(t)
                    ZStack {
                        SunView(size: size, growth: g, tint: DawnPalette.sunTint, animate: !reduceMotion)
                        CloudsCanvas(size: size, t: t, tint: DawnPalette.cloudTint)
                        BirdsCanvas(size: size, t: t, tint: DawnPalette.birdTint)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }

    /// A gentle sunrise: ease the sun up from dawn over ~18s, then drift faintly.
    static func sunriseGrowth(_ t: Double) -> Double {
        let rise = min(1, max(0, t / 18))
        let eased = 1 - pow(1 - rise, 3)                  // easeOutCubic
        return min(0.5, max(0, 0.04 + eased * 0.30 + sin(t * 0.05) * 0.02))
    }
}

// MARK: - Card chrome

private struct DawnCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(LinearGradient(
                        colors: [Color.white.opacity(0.9), DawnPalette.cardFill.opacity(0.9)],
                        startPoint: .top, endPoint: .bottom)))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.6), lineWidth: 1))
            .shadow(color: DawnPalette.shadow.opacity(0.18), radius: 30, y: 12)
            .padding(16)
    }
}

extension View {
    /// The frosted dawn card: soft white→blush fill, white rim, warm shadow, 16pt inset.
    func dawnCard() -> some View { modifier(DawnCardModifier()) }
}

// MARK: - Field chrome

private struct DawnFieldModifier: ViewModifier {
    var focused: Bool
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.7)))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(focused ? DawnPalette.accentRose.opacity(0.75) : Color.white.opacity(0.9),
                                  lineWidth: 1.5))
    }
}

extension View {
    /// Soft rose-bordered text-field chrome (border turns rose on focus).
    func dawnField(focused: Bool = false) -> some View { modifier(DawnFieldModifier(focused: focused)) }
}

// MARK: - Reusable bits

/// A small field/section label (mauve, rounded).
func dawnSectionLabel(_ text: String) -> some View {
    Text(text)
        .font(.system(size: 12, weight: .medium, design: .rounded))
        .foregroundStyle(DawnPalette.inkMuted)
}

/// The pastel pill look shared by the onboarding chip rows and the settings tab bar.
/// (Caller wraps this in a `Button { … } label: { dawnPill(...) }.buttonStyle(.plain)`.)
@ViewBuilder
func dawnPill(_ label: String, selected: Bool) -> some View {
    Text(label)
        .font(.system(size: 14, weight: .semibold, design: .rounded))
        .foregroundStyle(selected ? Color.white : DawnPalette.inkMuted)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 9)
        .background(
            Group {
                if selected {
                    Capsule().fill(LinearGradient(colors: [DawnPalette.accentRose, DawnPalette.accentRose2],
                                                  startPoint: .leading, endPoint: .trailing))
                } else {
                    Capsule().fill(Color.white.opacity(0.55))
                }
            })
        .overlay(Capsule().strokeBorder(selected ? Color.clear : Color.white.opacity(0.9), lineWidth: 1))
        .shadow(color: selected ? DawnPalette.accentRose.opacity(0.45) : .clear, radius: 8, y: 3)
}

/// A blush→peach pill button label (deep-rose text). Caller wraps in a Button.
@ViewBuilder
func dawnPrimaryLabel(_ text: String, systemImage: String? = nil) -> some View {
    HStack(spacing: 6) {
        if let systemImage { Image(systemName: systemImage) }
        Text(text)
    }
    .font(.system(size: 13.5, weight: .semibold, design: .rounded))
    .foregroundStyle(DawnPalette.deepRose)
    .padding(.horizontal, 16)
    .padding(.vertical, 9)
    .background(Capsule().fill(LinearGradient(colors: [DawnPalette.ctaA, DawnPalette.ctaB],
                                              startPoint: .leading, endPoint: .trailing)))
    .overlay(Capsule().strokeBorder(Color.white.opacity(0.7), lineWidth: 1))
}

/// A gentle press-to-shrink used by the dawn buttons.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
