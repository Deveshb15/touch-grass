import AppKit
import SwiftUI
import Combine

/// Drives the countdown shown on the overlay; observed by the SwiftUI block view.
@MainActor
final class BlockClock: ObservableObject {
    @Published var remaining: TimeInterval = 0
    @Published var total: TimeInterval = 1
}

/// Owns the "touch grass" lockout: full-screen overlays on every display, the
/// kiosk presentation options, the countdown, and restart-persistent timing.
///
/// "Firm but escapable" — no relaunch daemon, no Activity Monitor blocking. A
/// determined user can still kill the process; that's an accepted tradeoff.
@MainActor
final class BlockController: ObservableObject {
    @Published private(set) var isBlocking = false
    let clock = BlockClock()

    /// Called when a block finishes naturally; the app resets usage here.
    var onBlockEnded: (() -> Void)?

    private let settings: AppSettings
    private var endsAt: Date?
    private var overlays: [OverlayWindow] = []
    private var timer: Timer?
    private var savedPolicy: NSApplication.ActivationPolicy = .accessory
    private var observers: [NSObjectProtocol] = []

    init(settings: AppSettings) {
        self.settings = settings
    }

    /// If a block was in progress when the app was last quit, resume it.
    func resumeIfNeeded() {
        guard let ts = UserDefaults.standard.object(forKey: Self.key) as? Double else { return }
        let end = Date(timeIntervalSince1970: ts)
        if end > Date() {
            begin(until: end)
        } else {
            UserDefaults.standard.removeObject(forKey: Self.key)
        }
    }

    func startBlock() {
        guard !isBlocking else { return }
        begin(until: Date().addingTimeInterval(settings.blockDurationSeconds))
    }

    /// Manual early exit (used by the debug/escape affordance).
    func endNow() {
        guard isBlocking else { return }
        endBlock()
    }

    // MARK: - Lifecycle

    private func begin(until end: Date) {
        endsAt = end
        UserDefaults.standard.set(end.timeIntervalSince1970, forKey: Self.key)
        isBlocking = true
        clock.total = max(1, end.timeIntervalSinceNow)

        savedPolicy = NSApp.activationPolicy()
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        applyPresentationOptions()
        buildOverlays()
        registerObservers()
        startTimer()
        updateClock()
    }

    private func endBlock() {
        timer?.invalidate()
        timer = nil
        removeObservers()
        overlays.forEach { $0.orderOut(nil) }
        overlays.removeAll()
        NSApp.presentationOptions = []
        NSApp.setActivationPolicy(savedPolicy)
        UserDefaults.standard.removeObject(forKey: Self.key)
        endsAt = nil
        isBlocking = false
        onBlockEnded?()
    }

    private func startTimer() {
        let t = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.updateClock() }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func updateClock() {
        guard let endsAt else { return }
        let remaining = endsAt.timeIntervalSinceNow
        clock.remaining = max(0, remaining)
        if remaining <= 0 { endBlock() }
    }

    // MARK: - Window + system UI

    private func applyPresentationOptions() {
        // Valid combination: hideMenuBar requires hideDock; the disable* flags
        // are independent. Blocks Cmd-Tab, force-quit, and the Dock/menu bar.
        NSApp.presentationOptions = [
            .hideDock, .hideMenuBar,
            .disableProcessSwitching, .disableForceQuit,
            .disableSessionTermination, .disableHideApplication,
        ]
    }

    private func buildOverlays() {
        for screen in NSScreen.screens {
            let window = OverlayWindow(screen: screen)
            let host = NSHostingView(rootView: TouchGrassView(clock: clock))
            host.frame = NSRect(origin: .zero, size: screen.frame.size)
            window.contentView = host
            window.setFrame(screen.frame, display: true)
            window.makeKeyAndOrderFront(nil)
            overlays.append(window)
        }
    }

    private func registerObservers() {
        let nc = NotificationCenter.default
        observers.append(nc.addObserver(
            forName: NSApplication.didResignActiveNotification, object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.isBlocking else { return }
                NSApp.activate(ignoringOtherApps: true)
                self.applyPresentationOptions()
                self.overlays.first?.makeKeyAndOrderFront(nil)
            }
        })
        observers.append(nc.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.isBlocking else { return }
                self.overlays.forEach { $0.orderOut(nil) }
                self.overlays.removeAll()
                self.buildOverlays()
            }
        })
    }

    private func removeObservers() {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        observers.removeAll()
    }

    private static let key = "block.endsAt"
}
