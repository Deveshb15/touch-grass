import AppKit

/// A borderless window that covers a single screen above the menu bar and Dock,
/// follows across Spaces, and can become key so input can't reach apps beneath.
final class OverlayWindow: NSWindow {
    init(screen: NSScreen) {
        // NSWindow's designated initializer takes no `screen:`; positioning the
        // frame in global coordinates places the window on the intended screen.
        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        setFrame(screen.frame, display: false)
        // CGShieldingWindowLevel() is what screen savers use — above everything.
        level = NSWindow.Level(rawValue: Int(CGShieldingWindowLevel()))
        collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]
        isOpaque = true
        hasShadow = false
        ignoresMouseEvents = false
        isReleasedWhenClosed = false
        backgroundColor = .black
        isMovable = false
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
