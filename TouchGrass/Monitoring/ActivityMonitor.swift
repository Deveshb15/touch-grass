import Foundation
import AppKit

/// Samples the foreground state ~once per second and reports whether an AI
/// target is being *actively engaged* (not merely open). A tick counts when:
///   (1) an AI surface is frontmost AND you're present (recent input) — typing
///       into / looking at an AI app, AI web tab, or a terminal/IDE running a CLI;
///   (2) an AI CLI is actually working (burning CPU), regardless of focus; or
///   (3) we're within the grace window of the last time (1) or (2) held.
/// An AI app/tab merely open in the background, or a CLI idle at a prompt while
/// you look elsewhere, no longer counts.
final class ActivityMonitor {
    var onSample: ((SampleResult) -> Void)?

    private let settings: AppSettings
    private let catalog: TargetCatalog
    private let cli: CLIDetector
    private let cliMonitor = CLICPUMonitor()
    let browser: BrowserDetector

    private var timer: Timer?
    private let interval: TimeInterval = 1.0

    // Tracks the last time we counted as active (engaged or agent-working), for grace.
    private var lastActive: Date?
    private var lastActiveActivity: AIActivity = .none

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
        // "Present" = you've used the keyboard/mouse recently (scrolling/reading
        // counts). Walking away with an AI surface open eventually drops the count.
        let present = idle <= settings.presenceWindowSeconds

        // Scan for AI CLIs: the matched name (for the HUD) and pids (for CPU).
        let scan = cli.scan()
        // Is an AI CLI actually working right now (burning CPU)? Counts regardless
        // of what's frontmost — the agent doing work on your behalf is real use.
        let cliWorking = cliMonitor.isWorking(pids: scan.pids,
                                              threshold: settings.cliWorkingCPUFraction)

        // Foreground AI surface: an AI app, an AI site in the active tab, or a
        // terminal/IDE that's hosting an AI CLI (you're looking at where it runs).
        var foreground: AIActivity = .none
        if catalog.aiBundleIDs.contains(bundleID) {
            foreground = .app(name: frontmost?.localizedName ?? bundleID, bundleID: bundleID)
        } else if let target = catalog.browser(for: bundleID) {
            if let domain = browser.activeAIDomain(for: target) {
                foreground = .web(domain: domain, browser: target.appName)
            }
        } else if catalog.isTerminal(bundleID), let name = scan.name {
            foreground = .cli(name: name)
        }

        // (1) focused engagement requires presence; (2) background work does not.
        let focusedEngagement = foreground.isActive && present
        let active = focusedEngagement || cliWorking
        if active {
            lastActive = now
            lastActiveActivity = focusedEngagement
                ? foreground
                : scan.name.map { AIActivity.cli(name: $0) } ?? .none
        }

        // Grace: bridge brief gaps — a glance away, or server-side think-time
        // where the CLI burns ~0 CPU between bursts.
        let inGrace = lastActive.map { now.timeIntervalSince($0) <= settings.backgroundGraceSeconds } ?? false

        let counted = active || inGrace

        // Report the most concrete thing we found, for the menu-bar HUD.
        let activity: AIActivity
        if focusedEngagement {
            activity = foreground
        } else if cliWorking, let name = scan.name {
            activity = .cli(name: name)
        } else if inGrace {
            activity = lastActiveActivity
        } else {
            activity = .none
        }

        onSample?(SampleResult(activity: activity, idleSeconds: idle, counted: counted))
    }
}
