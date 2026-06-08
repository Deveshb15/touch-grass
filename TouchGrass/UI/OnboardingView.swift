import SwiftUI
import UserNotifications

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
    @State private var notifStatus: UNAuthorizationStatus = .notDetermined

    // Palette — shared dawn theme (see DawnTheme.swift).
    private let inkPrimary = DawnPalette.inkPrimary
    private let inkMuted   = DawnPalette.inkMuted
    private let accentRose = DawnPalette.accentRose
    private let deepRose   = DawnPalette.deepRose

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
        ZStack(alignment: .bottom) {
            DawnBackground()
            card
        }
        .preferredColorScheme(.light)
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
            field("a gentle heads-up before each break") { notifButton }

            startButton.padding(.top, 4)

            Text("you can change any of this later in settings.")
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(inkMuted.opacity(0.85))
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .dawnCard()
        // Focus the name field once the window has had a moment to become key.
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { nameFocused = true }
            Notifier.currentStatus { notifStatus = $0 }
        }
    }

    /// Status-aware notification opt-in: prompts when undecided, jumps to System
    /// Settings when it was turned off, and shows a confirmation once it's on.
    private var notifButton: some View {
        Button {
            switch notifStatus {
            case .notDetermined:
                Notifier.requestAuthorization { notifStatus = $0 }
            case .denied:
                Notifier.openSystemNotificationSettings()
            default:
                break
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: notifIcon)
                Text(notifLabel)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .lineLimit(1).minimumScaleFactor(0.8)
                Spacer(minLength: 0)
                if notifGranted { Image(systemName: "checkmark") }
            }
            .foregroundStyle(notifGranted ? Color.white : deepRose)
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if notifGranted {
                        Capsule().fill(LinearGradient(
                            colors: [RGBA(hex: 0xF4A9BC).color, RGBA(hex: 0xF7C9B0).color],
                            startPoint: .leading, endPoint: .trailing))
                    } else {
                        Capsule().fill(Color.white.opacity(0.7))
                    }
                }
            )
            .overlay(Capsule().strokeBorder(
                notifGranted ? Color.clear : accentRose.opacity(0.5), lineWidth: 1.5))
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(notifGranted)
    }

    private var notifGranted: Bool {
        notifStatus == .authorized || notifStatus == .provisional
    }
    private var notifIcon: String {
        switch notifStatus {
        case .denied: return "bell.slash.fill"
        case .notDetermined: return "bell.fill"
        default: return "bell.badge.fill"
        }
    }
    private var notifLabel: String {
        switch notifStatus {
        case .denied: return "reminders are off — open settings"
        case .notDetermined: return "turn on touch-grass reminders"
        default: return "reminders are on"
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
            .dawnField(focused: nameFocused)
    }

    /// Whether a non-blank name has been entered (the start button requires it).
    private var nameEntered: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
                .shadow(color: accentRose.opacity(nameEntered ? 0.5 : 0), radius: 18, y: 8)
                .opacity(nameEntered ? 1 : 0.45)
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(!nameEntered)
        .animation(.easeInOut(duration: 0.18), value: nameEntered)
    }

    // MARK: - Building blocks

    @ViewBuilder
    private func field<Content: View>(_ label: String,
                                      @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            dawnSectionLabel(label)
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
                    dawnPill(choice.label, selected: isSelected)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func finish() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }   // a name is required to start
        onFinish(trimmed, thresholdMinutes, blockMinutes)
    }
}
