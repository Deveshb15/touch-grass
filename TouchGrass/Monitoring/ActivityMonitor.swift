import Foundation
import AppKit

/// Samples the foreground state ~once per second and reports whether an AI
/// target is being actively used. Classification order: native app → terminal
/// CLI → browser site. Idle gating is applied by the consumer via `counted`.
final class ActivityMonitor {
    var onSample: ((SampleResult) -> Void)?

    private let settings: AppSettings
    private let catalog: TargetCatalog
    private let cli: CLIDetector
    let browser: BrowserDetector

    private var timer: Timer?
    private let interval: TimeInterval = 1.0

    // Tracks the last time an AI app/tab was in the foreground, for the grace window.
    private var lastForeground: Date?
    private var lastForegroundActivity: AIActivity = .none

    init(settings: AppSettings, catalog: TargetCatalog) {
        self.settings = settings
        self.catalog = catalog
        self.cli = CLIDetector(names: { catalog.aiCLINames })
        self.browser = BrowserDetector(matchesDomain: { catalog.matchesDomain($0) })
    }

    func start() {
        guard timer == nil else { return }
        let t = Timer(timeInterval: interval, repeats: true) { [weak self] _ in self?.tick() }
        RunLoop.main.add(t, forMode: .common)
        timer = t
        tick()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        let now = Date()
        let frontmost = NSWorkspace.shared.frontmostApplication
        let bundleID = frontmost?.bundleIdentifier ?? ""
        let idle = IdleDetector.idleSeconds()

        // Foreground AI: an AI app you're looking at, or an AI site in the active
        // tab. Counts whether or not you're typing — reading/waiting is still use.
        var foreground: AIActivity = .none
        if catalog.aiBundleIDs.contains(bundleID) {
            foreground = .app(name: frontmost?.localizedName ?? bundleID, bundleID: bundleID)
        } else if let target = catalog.browser(for: bundleID) {
            if let domain = browser.activeAIDomain(for: target) {
                foreground = .web(domain: domain, browser: target.appName)
            }
        }
        if foreground.isActive {
            lastForeground = now
            lastForegroundActivity = foreground
        }

        // Background AI: any AI CLI (claude/codex/…) running, regardless of what's
        // frontmost — the whole point is the agent works while you do other things.
        let cliName = cli.activeAICLI()

        // Grace: keep counting briefly after an AI app/tab leaves the foreground,
        // so glancing at another window mid-task doesn't drop the count.
        let inGrace = lastForeground.map { now.timeIntervalSince($0) <= settings.backgroundGraceSeconds } ?? false

        let counted = foreground.isActive || cliName != nil || inGrace

        // Report the most concrete thing we found, for the menu-bar HUD.
        let activity: AIActivity
        if foreground.isActive {
            activity = foreground
        } else if let cliName {
            activity = .cli(name: cliName)
        } else if inGrace {
            activity = lastForegroundActivity
        } else {
            activity = .none
        }

        onSample?(SampleResult(activity: activity, idleSeconds: idle, counted: counted))
    }
}
