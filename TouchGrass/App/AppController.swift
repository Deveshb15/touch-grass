import SwiftUI
import Combine

/// Central coordinator: owns settings/catalog/usage/monitor/blocker and wires
/// the per-second sample into the rolling window, warnings, and block trigger.
@MainActor
final class AppController: ObservableObject {
    let settings = AppSettings()
    let catalog = TargetCatalog()
    let usage: UsageTracker
    let monitor: ActivityMonitor
    let blocker: BlockController

    // Mirrored state for the menu-bar UI (refreshed each sample).
    @Published private(set) var currentActivity: AIActivity = .none
    @Published private(set) var idleSeconds: Double = 0
    @Published private(set) var isBlocking = false
    @Published private(set) var blockRemaining: TimeInterval = 0
    @Published var isPaused = false

    private var didWarn = false

    init() {
        let settings = self.settings
        let catalog = self.catalog
        usage = UsageTracker(settings: settings)
        blocker = BlockController(settings: settings)
        monitor = ActivityMonitor(settings: settings, catalog: catalog)

        monitor.onSample = { [weak self] result in self?.handle(result) }
        blocker.onBlockEnded = { [weak self] in
            self?.usage.reset()
            self?.didWarn = false
        }
    }

    func start() {
        Notifier.requestAuthorization()
        blocker.resumeIfNeeded()
        if settings.monitoringEnabled {
            monitor.start()
        }
    }

    /// Debug: trigger a short block immediately to verify the overlay.
    func startTestBlock() {
        blocker.startTestBlock()
        isBlocking = true
    }

    /// Convenience for the menu-bar progress bar (0...1).
    var usageFraction: Double {
        guard settings.thresholdSeconds > 0 else { return 0 }
        return min(1, usage.usedSeconds / settings.thresholdSeconds)
    }

    var menuBarSymbol: String {
        if isBlocking { return "leaf.fill" }
        return currentActivity.isActive ? "brain.head.profile" : "leaf"
    }

    private func handle(_ result: SampleResult) {
        currentActivity = result.activity
        idleSeconds = result.idleSeconds
        isBlocking = blocker.isBlocking
        blockRemaining = blocker.clock.remaining

        // While blocking or paused, slide the window but don't accumulate.
        guard !isPaused, !blocker.isBlocking else {
            usage.slide()
            return
        }

        if result.counted {
            usage.record()
        } else {
            usage.slide()
        }

        maybeWarn()

        if usage.thresholdReached {
            blocker.startBlock()
            isBlocking = true
        }
    }

    private func maybeWarn() {
        let warnAt = settings.thresholdSeconds - settings.warningLeadSeconds
        if usage.usedSeconds >= warnAt && usage.usedSeconds < settings.thresholdSeconds {
            if !didWarn {
                didWarn = true
                Notifier.warnBreakComing(inMinutes: Int(settings.blockDurationMinutes.rounded()))
            }
        } else if usage.usedSeconds < warnAt {
            didWarn = false
        }
    }
}
