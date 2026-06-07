import SwiftUI

/// First-run welcome. A soft, magical pink dawn (a hand-painted pastel gradient with
/// the same pulsing sun + drifting birds the block overlay uses) sits behind a light
/// frosted card with three quick questions: your name, when to nudge you, and how long
/// the pause lasts. "start touching grass" hands the values to `onFinish`, which
/// `AppController` persists before it begins monitoring.
///
/// Everything is painted with explicit light colors and custom controls — no system
/// material / `.roundedBorder` / `.menu` / `.borderedProminent`, which render dark and
/// muddy when the host happens to be in dark mode. The window is also pinned to light.
struct OnboardingView: View {
    /// (name, thresholdMinutes, blockDurationMinutes). Called on Start (or close).
    var onFinish: (_ name: String, _ thresholdMinutes: Double, _ blockDurationMinutes: Double) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var nameFocused: Bool

    @State private var name = ""
    @State private var thresholdMinutes: Double = 60      // default: 1 hour of AI use
    @State private var blockMinutes: Double = 10          // default: 10-minute pause

    /// Reference epoch for the continuous landscape clock, captured once.
    private let epoch = Date().timeIntervalSinceReferenceDate

    // Palette — explicit, light & pink (never system colors).
    private let inkPrimary = RGBA(hex: 0x5B4A66).color    // deep plum
    private let inkMuted   = RGBA(hex: 0x9A86A6).color    // mauve
    private let accentRose = RGBA(hex: 0xF4A9BC).color    // rose accent
    private let deepRose   = RGBA(hex: 0x7A3F58).color    // CTA text

    private struct Choice: Identifiable, Hashable {
        let label: String
        let minutes: Double
        var id: Double { minutes }
    }

    /// Hour-scale presets — the trigger is framed in "hours of AI use" (the rolling
    /// window is auto-widened to match in `AppController.finishOnboarding`).
    private let breakChoices: [Choice] = [
        .init(label: "30m", minutes: 30),
        .init(label: "1h", minutes: 60),
        .init(label: "2h", minutes: 120),
        .init(label: "3h", minutes: 180),
    ]
    private let pauseChoices: [Choice] = [
        .init(label: "5m", minutes: 5),
        .init(label: "10m", minutes: 10),
        .init(label: "15m", minutes: 15),
        .init(label: "20m", minutes: 20),
        .init(label: "30m", minutes: 30),
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                background(size: geo.size)
                card
            }
            .ignoresSafeArea()
        }
        .preferredColorScheme(.light)
    }

    // MARK: - Live pink-dawn landscape

    @ViewBuilder
    private func background(size: CGSize) -> some View {
        ZStack {
            // Soft pastel sunrise — lavender-pink lifting off a warm cream horizon.
            LinearGradient(
                colors: [RGBA(hex: 0xEAD7EC).color, RGBA(hex: 0xF6D7DD).color,
                         RGBA(hex: 0xFBE3D8).color, RGBA(hex: 0xFDF3EA).color],
                startPoint: .top, endPoint: .bottom)

            // A gentle bloom low-center so the card seems to glow off the horizon.
            RadialGradient(colors: [Color.white.opacity(0.5), Color.white.opacity(0)],
                           center: UnitPoint(x: 0.5, y: 0.72),
                           startRadius: 0, endRadius: size.width * 0.85)

            TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: reduceMotion)) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate - epoch
                let g = reduceMotion ? 0.16 : sunriseGrowth(t)
                ZStack {
                    SunView(size: size, growth: g, tint: RGBA(hex: 0xF7C9A8).color, animate: !reduceMotion)
                    CloudsCanvas(size: size, t: t, tint: RGBA(hex: 0xFCEAF0).color)
                    BirdsCanvas(size: size, t: t, tint: RGBA(hex: 0x9B7FA6).color)
                }
            }
        }
    }

    /// A gentle sunrise: ease the sun up from dawn over ~18s, then drift faintly.
    private func sunriseGrowth(_ t: Double) -> Double {
        let rise = min(1, max(0, t / 18))
        let eased = 1 - pow(1 - rise, 3)                  // easeOutCubic
        return min(0.5, max(0, 0.04 + eased * 0.30 + sin(t * 0.05) * 0.02))
    }

    // MARK: - Form card

    private var card: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 5) {
                Text("let's set your pace")
                    .font(.system(size: 25, weight: .semibold, design: .rounded))
                    .foregroundStyle(inkPrimary)
                Text("three quick things, then we touch grass.")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(inkMuted)
            }

            field("what do we call you?") { nameField }
            field("nudge me to touch grass after") {
                chipRow(selection: $thresholdMinutes, choices: breakChoices)
            }
            field("…and keep me out for") {
                chipRow(selection: $blockMinutes, choices: pauseChoices)
            }

            startButton.padding(.top, 4)

            Text("you can change any of this later in settings.")
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(inkMuted.opacity(0.85))
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(LinearGradient(
                    colors: [Color.white.opacity(0.9), RGBA(hex: 0xFBEFF1).color.opacity(0.9)],
                    startPoint: .top, endPoint: .bottom))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.white.opacity(0.6), lineWidth: 1)
        )
        .shadow(color: RGBA(hex: 0x7A5A6B).color.opacity(0.18), radius: 30, y: 12)
        .padding(16)
        // Focus the name field once the window has had a moment to become key.
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { nameFocused = true }
        }
    }

    private var nameField: some View {
        TextField("your name", text: $name)
            .textFieldStyle(.plain)
            .font(.system(size: 16, design: .rounded))
            .foregroundStyle(inkPrimary)
            .tint(accentRose)
            .focused($nameFocused)
            .onSubmit(finish)
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.7))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(nameFocused ? accentRose.opacity(0.75) : Color.white.opacity(0.9),
                                  lineWidth: 1.5)
            )
    }

    private var startButton: some View {
        Button(action: finish) {
            Text("start touching grass")
                .font(.system(size: 15.5, weight: .semibold, design: .rounded))
                .foregroundStyle(deepRose)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    Capsule().fill(LinearGradient(
                        colors: [RGBA(hex: 0xF8C7D2).color, RGBA(hex: 0xF9D9C2).color],
                        startPoint: .leading, endPoint: .trailing))
                )
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.7), lineWidth: 1))
                .shadow(color: accentRose.opacity(0.5), radius: 18, y: 8)
        }
        .buttonStyle(PressableButtonStyle())
    }

    // MARK: - Building blocks

    @ViewBuilder
    private func field<Content: View>(_ label: String,
                                      @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(inkMuted)
            content()
        }
    }

    @ViewBuilder
    private func chipRow(selection: Binding<Double>, choices: [Choice]) -> some View {
        HStack(spacing: 8) {
            ForEach(choices) { choice in
                let isSelected = selection.wrappedValue == choice.minutes
                Button {
                    selection.wrappedValue = choice.minutes
                } label: {
                    Text(choice.label)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(isSelected ? Color.white : inkMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(
                            Group {
                                if isSelected {
                                    Capsule().fill(LinearGradient(
                                        colors: [RGBA(hex: 0xF4A9BC).color, RGBA(hex: 0xF7C9B0).color],
                                        startPoint: .leading, endPoint: .trailing))
                                } else {
                                    Capsule().fill(Color.white.opacity(0.55))
                                }
                            }
                        )
                        .overlay(
                            Capsule().strokeBorder(
                                isSelected ? Color.clear : Color.white.opacity(0.9), lineWidth: 1)
                        )
                        .shadow(color: isSelected ? accentRose.opacity(0.45) : .clear, radius: 8, y: 3)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func finish() {
        onFinish(name.trimmingCharacters(in: .whitespacesAndNewlines), thresholdMinutes, blockMinutes)
    }
}

/// A gentle press-to-shrink for the primary CTA.
private struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
