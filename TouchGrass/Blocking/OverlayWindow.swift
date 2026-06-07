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
        // Shielding level composites above everything on EVERY display regardless of
        // which app/display is active — so one window per screen, ordered front via
        // orderFrontRegardless(), covers all displays at once without chasing focus.
        // (The earlier "nothing showed" bug was makeKeyAndOrderFront vs
        // orderFrontRegardless, not the level.)
        level = NSWindow.Level(rawValue: Int(CGShieldingWindowLevel()))
        // .canJoinAllSpaces → appear on every Space; .fullScreenAuxiliary → also over
        // other apps' full-screen Spaces; .stationary → don't shift on Space changes.
        collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        isOpaque = true
        hasShadow = false
        ignoresMouseEvents = false
        // The app (accessory, no normal windows) keeps resigning active; without
        // this the overlay would order out the moment focus leaves it.
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
        // Beige base (matches TouchGrassView's gradient) so there's no black
        // flash before the SwiftUI view paints.
        backgroundColor = NSColor(srgbRed: 0.953, green: 0.918, blue: 0.847, alpha: 1)
        isMovable = false
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
