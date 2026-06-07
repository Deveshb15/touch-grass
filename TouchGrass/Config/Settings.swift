import Foundation
import Combine

/// User-tunable thresholds, persisted in UserDefaults.
///
/// All values are exposed in minutes/seconds for the UI; `*Seconds` accessors
/// convert to the units the monitoring loop works in.
final class AppSettings: ObservableObject {
    private let defaults = UserDefaults.standard

    /// Active-AI minutes (within the rolling window) that trigger a block.
    @Published var thresholdMinutes: Double { didSet { defaults.set(thresholdMinutes, forKey: Keys.threshold) } }
    /// How long the "touch grass" block lasts once triggered.
    @Published var blockDurationMinutes: Double { didSet { defaults.set(blockDurationMinutes, forKey: Keys.blockDuration) } }
    /// Length of the rolling window the threshold is measured against.
    @Published var windowLengthMinutes: Double { didSet { defaults.set(windowLengthMinutes, forKey: Keys.windowLength) } }
    /// After an AI app/tab leaves the foreground, keep counting this long — covers
    /// switching to another window while the AI keeps working in the background.
    @Published var backgroundGraceSeconds: Double { didSet { defaults.set(backgroundGraceSeconds, forKey: Keys.grace) } }
    /// How far ahead of the threshold to warn ("break coming up").
    @Published var warningLeadMinutes: Double { didSet { defaults.set(warningLeadMinutes, forKey: Keys.warningLead) } }
    /// Master on/off for monitoring.
    @Published var monitoringEnabled: Bool { didSet { defaults.set(monitoringEnabled, forKey: Keys.enabled) } }

    init() {
        thresholdMinutes = defaults.object(forKey: Keys.threshold) as? Double ?? 30
        blockDurationMinutes = defaults.object(forKey: Keys.blockDuration) as? Double ?? 10
        windowLengthMinutes = defaults.object(forKey: Keys.windowLength) as? Double ?? 60
        backgroundGraceSeconds = defaults.object(forKey: Keys.grace) as? Double ?? 180
        warningLeadMinutes = defaults.object(forKey: Keys.warningLead) as? Double ?? 5
        monitoringEnabled = defaults.object(forKey: Keys.enabled) as? Bool ?? true
    }

    var thresholdSeconds: Double { thresholdMinutes * 60 }
    var blockDurationSeconds: Double { blockDurationMinutes * 60 }
    var windowLengthSeconds: Double { windowLengthMinutes * 60 }
    var warningLeadSeconds: Double { warningLeadMinutes * 60 }

    private enum Keys {
        static let threshold = "thresholdMinutes"
        static let blockDuration = "blockDurationMinutes"
        static let windowLength = "windowLengthMinutes"
        static let grace = "backgroundGraceSeconds"
        static let warningLead = "warningLeadMinutes"
        static let enabled = "monitoringEnabled"
    }
}
