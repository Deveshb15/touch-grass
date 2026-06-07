import Foundation
import Combine

/// Accumulates active-AI usage as a sliding window of one-second ticks, so the
/// threshold means "N minutes of active AI use within the last `windowLength`".
/// Persisted to UserDefaults so a quit/relaunch doesn't reset progress.
final class UsageTracker: ObservableObject {
    /// Active seconds currently inside the window.
    @Published private(set) var usedSeconds: Double = 0

    private let settings: AppSettings
    private var ticks: [TimeInterval] = []   // epoch seconds, one per counted tick
    private var lastPersist: TimeInterval = 0
    private let persistInterval: TimeInterval = 5

    init(settings: AppSettings) {
        self.settings = settings
        if let saved = UserDefaults.standard.array(forKey: Self.key) as? [Double] {
            ticks = saved
        }
        prune(now: Date().timeIntervalSince1970)
    }

    /// Record one second of active AI use.
    func record() {
        let now = Date().timeIntervalSince1970
        ticks.append(now)
        prune(now: now)
        persist(now: now)
    }

    /// Slide the window without counting (used while idle / paused / blocking).
    func slide() {
        prune(now: Date().timeIntervalSince1970)
    }

    func reset() {
        ticks.removeAll()
        usedSeconds = 0
        UserDefaults.standard.set(ticks, forKey: Self.key)
        lastPersist = Date().timeIntervalSince1970
    }

    var thresholdReached: Bool { usedSeconds >= settings.thresholdSeconds }

    private func prune(now: TimeInterval) {
        let cutoff = now - settings.windowLengthSeconds
        if let firstKept = ticks.firstIndex(where: { $0 >= cutoff }) {
            if firstKept > 0 { ticks.removeFirst(firstKept) }
        } else {
            ticks.removeAll()
        }
        usedSeconds = Double(ticks.count)
    }

    /// Throttled so we don't rewrite the whole window array every second.
    private func persist(now: TimeInterval) {
        guard now - lastPersist >= persistInterval else { return }
        lastPersist = now
        UserDefaults.standard.set(ticks, forKey: Self.key)
    }

    private static let key = "usage.ticks"
}
