import Foundation
import CoreGraphics

/// What kind of AI usage (if any) is happening in the foreground right now.
enum AIActivity: Equatable {
    case none
    case app(name: String, bundleID: String)
    case cli(name: String)
    case web(domain: String, browser: String)

    var isActive: Bool {
        if case .none = self { return false }
        return true
    }

    /// Short human label for the menu-bar HUD.
    var label: String {
        switch self {
        case .none: return "No AI activity"
        case .app(let name, _): return "App · \(name)"
        case .cli(let name): return "CLI · \(name)"
        case .web(let domain, let browser): return "Web · \(domain) (\(browser))"
        }
    }

    var symbol: String {
        switch self {
        case .none: return "leaf"
        case .app: return "app.badge"
        case .cli: return "terminal"
        case .web: return "globe"
        }
    }
}

/// One tick of the monitoring loop.
struct SampleResult {
    let activity: AIActivity
    let idleSeconds: Double
    /// True when this tick counts as active AI engagement: an AI surface frontmost
    /// while present, an AI CLI actively working, or within the grace window.
    let counted: Bool
}

/// Seconds since the last user input event, system-wide.
///
/// We take the minimum across concrete input event types rather than passing
/// `kCGAnyInputEventType` (whose Swift `CGEventType(rawValue:)` is unsafe to
/// force-unwrap). Reading idle time needs no Input Monitoring permission.
enum IdleDetector {
    private static let eventTypes: [CGEventType] = [
        .keyDown, .keyUp, .flagsChanged,
        .leftMouseDown, .leftMouseUp, .leftMouseDragged,
        .rightMouseDown, .rightMouseUp, .rightMouseDragged,
        .otherMouseDown, .mouseMoved, .scrollWheel,
    ]

    static func idleSeconds() -> Double {
        let values = eventTypes.map {
            CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: $0)
        }
        return values.min() ?? 0
    }
}
