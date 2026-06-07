import Foundation
import AppKit

/// Reads the active tab URL of the frontmost browser via AppleScript and checks
/// it against the AI-domain list. Requires Automation (Apple Events) consent,
/// which macOS prompts for once per target browser.
final class BrowserDetector: ObservableObject {
    private let matchesDomain: (String) -> Bool
    private var compiled: [String: NSAppleScript] = [:]

    /// App names for which the user has denied Automation, surfaced to the UI.
    @Published private(set) var permissionDenied: Set<String> = []

    private var cachedHost: String?
    private var cachedFor: String?
    private var lastRun: Date = .distantPast
    private let throttle: TimeInterval = 1.5

    init(matchesDomain: @escaping (String) -> Bool) {
        self.matchesDomain = matchesDomain
    }

    /// Returns the matched AI domain if the browser's active tab is an AI site.
    func activeAIDomain(for browser: BrowserTarget) -> String? {
        let host: String?
        if browser.appName == cachedFor, Date().timeIntervalSince(lastRun) < throttle {
            host = cachedHost
        } else {
            host = currentHost(for: browser)
            cachedHost = host
            cachedFor = browser.appName
            lastRun = Date()
        }
        guard let host, matchesDomain(host) else { return nil }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }

    private func currentHost(for browser: BrowserTarget) -> String? {
        let tab = browser.kind == .safari ? "current tab" : "active tab"
        let source = """
        tell application "\(browser.appName)"
            if (count of windows) is 0 then return ""
            return URL of \(tab) of front window
        end tell
        """
        let script: NSAppleScript
        if let existing = compiled[browser.appName] {
            script = existing
        } else if let made = NSAppleScript(source: source) {
            compiled[browser.appName] = made
            script = made
        } else {
            return nil
        }

        var error: NSDictionary?
        let output = script.executeAndReturnError(&error)
        if let error {
            handle(error: error, app: browser.appName)
            return nil
        }
        clearDenied(browser.appName)
        guard let urlString = output.stringValue, !urlString.isEmpty else { return nil }
        return URLComponents(string: urlString)?.host
    }

    private func handle(error: NSDictionary, app: String) {
        let code = (error["NSAppleScriptErrorNumber"] as? Int) ?? 0
        // -1743 / errAEEventNotPermitted: user denied Automation for this app.
        // (-600 = app not running, -1728 = no front window: transient, ignore.)
        if code == -1743 {
            DispatchQueue.main.async { self.permissionDenied.insert(app) }
        }
    }

    private func clearDenied(_ app: String) {
        if permissionDenied.contains(app) {
            DispatchQueue.main.async { self.permissionDenied.remove(app) }
        }
    }
}
