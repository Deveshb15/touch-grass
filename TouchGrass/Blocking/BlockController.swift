import AppKit
import SwiftUI
import Combine

/// Drives the countdown shown on the overlay; observed by the SwiftUI block view.
@MainActor
final class BlockClock: ObservableObject {
    @Published var remaining: TimeInterval = 0
    @Published var total: TimeInterval = 1
}

/// Owns the "touch grass" lockout: a full-screen overlay on every display, the
/// countdown, and restart-persistent timing.
///
/// The app stays an `.accessory` (menu-bar) app throughout — it deliberately does
/// NOT switch to `.regular`/activate, because activating a menu-bar app triggers a
/// Space switch that drops the overlay onto a Space you aren't viewing (especially
/// with multiple displays / full-screen apps). Instead each overlay window uses
/// `.canJoinAllSpaces` + `.fullScreenAuxiliary` at the shielding level and is ordered
/// front via `orderFrontRegardless()`, so it layers over the *current* Space of every
/// display — including other apps' full-screen Spaces — without stealing focus.
///
/// "Firm but escapable": the overlay covers every screen and captures mouse input,
/// but we don't disable Cmd-Tab/force-quit (that needs an active `.regular` app, which
/// reintroduces the Space-switch problem). A determined user can still escape; that's
/// an accepted tradeoff.
@MainActor
final class BlockController: ObservableObject {
    @Published private(set) var isBlocking = false
    let clock = BlockClock()

    /// Called when a block finishes naturally; the app resets usage here.
    var onBlockEnded: (() -> Void)?

    private let settings: AppSettings
    private var endsAt: Date?
    /// Picked once per block so the overlay's personalized title/helper stay stable
    /// for this break and rotate to a different line on the next one.
    private var greetingSeed = 0
    private var overlays: [OverlayWindow] = []
    private var timer: Timer?
    private var observers: [NSObjectProtocol] = []
    private var lastScreenFrames: [CGRect] = []

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
        greetingSeed = Int.random(in: 0..<10_000)
        clock.total = max(1, end.timeIntervalSinceNow)

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
        if remaining <= 0 {
            endBlock()
            return
        }
        // Re-assert every tick so the overlay can't be buried by other windows.
        // Cheap and a visual no-op when already frontmost.
        for window in overlays { window.orderFrontRegardless() }
    }

    // MARK: - Overlay windows

    private func buildOverlays() {
        lastScreenFrames = NSScreen.screens.map(\.frame)
        for (i, screen) in NSScreen.screens.enumerated() {
            let window = OverlayWindow(screen: screen)
            let host = NSHostingView(rootView: TouchGrassView(
                clock: clock, userName: settings.userName, greetingSeed: greetingSeed))
            // By default NSHostingView resizes its window to the SwiftUI content's
            // intrinsic size, which shrinks/shifts the overlay off the full-screen
            // frame. Empty sizingOptions disables that; autoresizing fills the window.
            host.sizingOptions = []
            host.translatesAutoresizingMaskIntoConstraints = true
            host.autoresizingMask = [.width, .height]
            host.frame = NSRect(origin: .zero, size: screen.frame.size)
            window.contentView = host
            window.setFrame(screen.frame, display: true)
            // orderFrontRegardless() (not makeKeyAndOrderFront) is required: an
            // accessory app that isn't the active app has its normal window-ordering
            // suppressed by AppKit, so the overlay would never appear.
            window.orderFrontRegardless()
            if i == 0 { window.makeKey() }
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
                self.overlays.forEach { $0.orderFrontRegardless() }
            }
        })
        observers.append(nc.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.isBlocking else { return }
                // Only rebuild when the actual screen set/frames change — not on every
                // visibleFrame change — so we don't churn the overlays needlessly.
                let current = NSScreen.screens.map(\.frame)
                guard current != self.lastScreenFrames else { return }
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
