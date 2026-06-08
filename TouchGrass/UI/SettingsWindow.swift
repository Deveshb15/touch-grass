import AppKit

/// The settings window. Like `OnboardingWindow`, it's a real titled window (so it can
/// become key and accept text/slider input as an accessory/menu-bar app) with a
/// transparent full-size-content title bar, pinned to **light** appearance so the
/// pink dawn theme renders correctly even when the system is in dark mode.
///
/// `AppController.showSettings()` owns the instance and hosts `SettingsView` in it.
final class SettingsWindow: NSWindow {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 640),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        isMovableByWindowBackground = true
        appearance = NSAppearance(named: .aqua)
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true
        backgroundColor = DawnPalette.windowNSColor
        isReleasedWhenClosed = false
        center()
    }

    // An accessory app's windows must opt in to becoming key for text input to work.
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
