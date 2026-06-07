import AppKit

/// The small, centered welcome window shown once on first launch. It's the gentle
/// cousin of `OverlayWindow`: a real titled window (so it can become key and accept
/// text input as an accessory/menu-bar app), but with a transparent full-size-content
/// title bar so the live landscape in `OnboardingView` reaches the very top edge.
///
/// Fixed size, no resize/minimize/zoom — it reads as a clean panel, draggable by its
/// background. `AppController` owns the instance and hosts `OnboardingView` in it.
final class OnboardingWindow: NSWindow {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 660),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        isMovableByWindowBackground = true
        // The scene is a deliberate light pastel palette — pin it to light appearance
        // so system bits (cursor, any control chrome) never render dark and muddy.
        appearance = NSAppearance(named: .aqua)
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true
        // Soft lavender-pink base (#EAD7EC) — matches the top of the dawn gradient in
        // OnboardingView, so there's no flash before SwiftUI paints.
        backgroundColor = NSColor(srgbRed: 0.918, green: 0.843, blue: 0.925, alpha: 1)
        isReleasedWhenClosed = false
        center()
    }

    // An accessory app's windows must opt in to becoming key for text input to work.
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
