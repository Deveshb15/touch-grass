import Foundation
import Combine

/// User-tunable thresholds, persisted in UserDefaults.
///
/// All values are exposed in minutes/seconds for the UI; `*Seconds` accessors
/// convert to the units the monitoring loop works in.
final class AppSettings: ObservableObject {
    private let defaults = UserDefaults.standard

    /// Active-AI minutes (within the rolling window) that trigger a block.
    @Published var thresholdMinutes: Double {
        didSet {
            defaults.set(thresholdMinutes, forKey: Keys.threshold)
            // Keep the stored window from falling below the reachable floor when the
            // threshold is raised, so the Settings slider mirrors the effective window
            // (see `windowLengthSeconds`). One-directional — editing the window never
            // writes back here — so there's no didSet feedback loop. didSet does not
            // fire for the initial assignment in init(), so launch loads are untouched.
            if windowLengthMinutes < thresholdMinutes * 2 {
                windowLengthMinutes = thresholdMinutes * 2
            }
        }
    }
    /// How long the "touch grass" block lasts once triggered.
    @Published var blockDurationMinutes: Double { didSet { defaults.set(blockDurationMinutes, forKey: Keys.blockDuration) } }
    /// Length of the rolling window the threshold is measured against.
    @Published var windowLengthMinutes: Double { didSet { defaults.set(windowLengthMinutes, forKey: Keys.windowLength) } }
    /// After an AI app/tab leaves the foreground, keep counting this long — covers
    /// switching to another window while the AI keeps working in the background.
    @Published var backgroundGraceSeconds: Double { didSet { defaults.set(backgroundGraceSeconds, forKey: Keys.grace) } }
    /// Seconds since the last keyboard/mouse input within which you still count as
    /// "present" at an AI surface (reading/scrolling counts as use).
    @Published var presenceWindowSeconds: Double { didSet { defaults.set(presenceWindowSeconds, forKey: Keys.presence) } }
    /// Minimum CPU fraction (of one core, 0…1) an AI-CLI process must consume
    /// between ticks to count as "the agent is working" while not frontmost.
    @Published var cliWorkingCPUFraction: Double { didSet { defaults.set(cliWorkingCPUFraction, forKey: Keys.cliCPU) } }
    /// How far ahead of the threshold to warn ("break coming up").
    @Published var warningLeadMinutes: Double { didSet { defaults.set(warningLeadMinutes, forKey: Keys.warningLead) } }
    /// Master on/off for monitoring.
    @Published var monitoringEnabled: Bool { didSet { defaults.set(monitoringEnabled, forKey: Keys.enabled) } }
    /// What to call you in the overlay copy ("{name}, go touch some grass."). Empty → generic copy.
    @Published var userName: String { didSet { defaults.set(userName, forKey: Keys.userName) } }
    /// Whether the first-run onboarding has been completed. Gates the welcome window.
    @Published var hasOnboarded: Bool { didSet { defaults.set(hasOnboarded, forKey: Keys.hasOnboarded) } }

    init() {
        thresholdMinutes = defaults.object(forKey: Keys.threshold) as? Double ?? 30
        blockDurationMinutes = defaults.object(forKey: Keys.blockDuration) as? Double ?? 10
        windowLengthMinutes = defaults.object(forKey: Keys.windowLength) as? Double ?? 60
        backgroundGraceSeconds = defaults.object(forKey: Keys.grace) as? Double ?? 180
        presenceWindowSeconds = defaults.object(forKey: Keys.presence) as? Double ?? 60
        cliWorkingCPUFraction = defaults.object(forKey: Keys.cliCPU) as? Double ?? 0.03
        warningLeadMinutes = defaults.object(forKey: Keys.warningLead) as? Double ?? 1
        monitoringEnabled = defaults.object(forKey: Keys.enabled) as? Bool ?? true
        userName = defaults.object(forKey: Keys.userName) as? String ?? ""
        hasOnboarded = defaults.object(forKey: Keys.hasOnboarded) as? Bool ?? false
    }

    var thresholdSeconds: Double { thresholdMinutes * 60 }
    var blockDurationSeconds: Double { blockDurationMinutes * 60 }
    /// The rolling window the threshold is measured against, in seconds.
    ///
    /// `usedSeconds` is a count of one-second ticks *inside* this window, so it can
    /// never exceed the window. If the window were ≤ the threshold the block could
    /// only fire at a 100%-impossible duty cycle (every single second counted, with
    /// zero gaps) and so would effectively never trigger — the menu bar just sits
    /// pinned at "N/N min" forever. Onboarding already widens to 2× the threshold;
    /// we enforce the same floor here so the independent Settings sliders can't
    /// recreate an unreachable pair. Applied at read time, so it also retroactively
    /// repairs any window/threshold already persisted below the floor.
    var windowLengthSeconds: Double { max(windowLengthMinutes, thresholdMinutes * 2) * 60 }
    var warningLeadSeconds: Double { warningLeadMinutes * 60 }

    private enum Keys {
        static let threshold = "thresholdMinutes"
        static let blockDuration = "blockDurationMinutes"
        static let windowLength = "windowLengthMinutes"
        static let grace = "backgroundGraceSeconds"
        static let presence = "presenceWindowSeconds"
        static let cliCPU = "cliWorkingCPUFraction"
        static let warningLead = "warningLeadMinutes"
        static let enabled = "monitoringEnabled"
        static let userName = "userName"
        static let hasOnboarded = "hasOnboarded"
    }
}
