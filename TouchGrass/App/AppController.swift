import SwiftUI
import AppKit
import Combine

/// Central coordinator: owns settings/catalog/usage/monitor/blocker and wires
/// the per-second sample into the rolling window, warnings, and block trigger.
/// (`NSObject` so it can act as the onboarding window's delegate.)
@MainActor
final class AppController: NSObject, ObservableObject, NSWindowDelegate {
    let settings = AppSettings()
    let catalog = TargetCatalog()
    let usage: UsageTracker
    let monitor: ActivityMonitor
    let blocker: BlockController
    let updater = SparkleUpdater()

    // Mirrored state for the menu-bar UI (refreshed each sample).
    @Published private(set) var currentActivity: AIActivity = .none
    @Published private(set) var idleSeconds: Double = 0
    @Published private(set) var isBlocking = false
    @Published private(set) var blockRemaining: TimeInterval = 0
    @Published var isPaused = false

    private var didWarn = false

    /// Held strongly while the first-run onboarding window is on screen.
    private var onboardingWindow: OnboardingWindow?

    /// Our own settings window. We host `SettingsView` in a plain `NSWindow` rather
    /// than rely on the SwiftUI `Settings` scene + `showSettingsWindow:` selector,
    /// which doesn't reliably open for a menu-bar accessory app.
    private var settingsWindow: NSWindow?

    override init() {
        let settings = self.settings
        let catalog = self.catalog
        usage = UsageTracker(settings: settings)
        blocker = BlockController(settings: settings)
        monitor = ActivityMonitor(settings: settings, catalog: catalog)
        super.init()

        monitor.onSample = { [weak self] result in self?.handle(result) }
        blocker.onBlockEnded = { [weak self] in
            self?.usage.reset()
            self?.didWarn = false
        }
    }

    func start() {
        // Notification permission is requested explicitly via the onboarding button,
        // not silently at launch (an invisible prompt is easy to miss / dismiss).
        blocker.resumeIfNeeded()
        if !settings.hasOnboarded {
            presentOnboarding()          // monitoring starts once onboarding finishes
        } else if settings.monitoringEnabled {
            monitor.start()
        }
    }

    // MARK: - Settings window

    /// Open (or re-focus) the settings window so the user can change timing, etc.
    func showSettings() {
        if settingsWindow == nil {
            let window = SettingsWindow()
            let host = NSHostingView(rootView: SettingsView()
                .environmentObject(self)
                .environmentObject(updater))
            host.sizingOptions = []          // fill the window; don't resize it to fit
            host.translatesAutoresizingMaskIntoConstraints = true
            host.autoresizingMask = [.width, .height]
            host.frame = NSRect(origin: .zero, size: window.frame.size)
            window.contentView = host
            settingsWindow = window
        }
        // Accessory apps must activate to bring a window forward and accept input.
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow?.makeKeyAndOrderFront(nil)
    }

    // MARK: - First-run onboarding

    private func presentOnboarding() {
        let window = OnboardingWindow()
        let view = OnboardingView { [weak self] name, threshold, block in
            self?.finishOnboarding(name: name, thresholdMinutes: threshold, blockDurationMinutes: block)
        }
        let host = NSHostingView(rootView: view)
        host.sizingOptions = []          // don't let the view resize the window to fit
        host.autoresizingMask = [.width, .height]
        window.contentView = host        // contentView is auto-sized to fill the window
        window.delegate = self           // catch a manual close (skip → keep defaults)
        onboardingWindow = window

        // As an accessory app we must activate to take focus for text input.
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    /// Persist the onboarding answers, then begin monitoring. Idempotent via the
    /// `hasOnboarded` flag so the "Start" path and a stray close can't double-run.
    private func finishOnboarding(name: String, thresholdMinutes: Double, blockDurationMinutes: Double) {
        guard !settings.hasOnboarded else { return }
        settings.userName = name
        settings.thresholdMinutes = thresholdMinutes
        settings.blockDurationMinutes = blockDurationMinutes
        // The trigger fires only if accumulated AI-use ≤ the rolling window, so widen
        // the window to 2× the threshold (preserving the shipped 30-in-60 ratio) — this
        // is what lets hour-scale targets actually fire.
        settings.windowLengthMinutes = max(settings.windowLengthMinutes, thresholdMinutes * 2)
        settings.hasOnboarded = true

        dismissOnboarding()
        if settings.monitoringEnabled { monitor.start() }
    }

    private func dismissOnboarding() {
        onboardingWindow?.delegate = nil   // avoid windowWillClose re-entry on programmatic close
        onboardingWindow?.close()
        onboardingWindow = nil
    }

    /// Closing the window without pressing Start = "use the defaults and get going".
    nonisolated func windowWillClose(_ notification: Notification) {
        Task { @MainActor in
            self.finishOnboarding(name: self.settings.userName,
                                  thresholdMinutes: self.settings.thresholdMinutes,
                                  blockDurationMinutes: self.settings.blockDurationMinutes)
        }
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
                Notifier.warnBreakComing(inSeconds: settings.thresholdSeconds - usage.usedSeconds)
            }
        } else if usage.usedSeconds < warnAt {
            didWarn = false
        }
    }
}
