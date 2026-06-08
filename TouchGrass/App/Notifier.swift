import Foundation
import UserNotifications
import AppKit

/// Thin wrapper around local notifications for the pre-block warning.
/// Failures are non-fatal — the menu-bar HUD is the source of truth.
enum Notifier {
    /// Ask for permission, then report the resulting status on the main queue.
    /// (If already decided, this resolves to the existing status without a prompt.)
    static func requestAuthorization(_ completion: ((UNAuthorizationStatus) -> Void)? = nil) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in
            center.getNotificationSettings { settings in
                DispatchQueue.main.async { completion?(settings.authorizationStatus) }
            }
        }
    }

    /// Current authorization status, delivered on the main queue.
    static func currentStatus(_ completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async { completion(settings.authorizationStatus) }
        }
    }

    /// Open System Settings → Notifications (used when permission was denied and we
    /// can no longer prompt in-app).
    static func openSystemNotificationSettings() {
        let candidates = [
            "x-apple.systempreferences:com.apple.Notifications-Settings.extension",
            "x-apple.systempreferences:com.apple.preference.notifications",
        ]
        for s in candidates {
            if let url = URL(string: s), NSWorkspace.shared.open(url) { return }
        }
    }

    /// Warns that a break is imminent. `seconds` is the (counted AI-use) time left
    /// before the block fires, so the copy says how long until you touch grass.
    static func warnBreakComing(inSeconds seconds: Double) {
        let mins = max(1, Int((seconds / 60).rounded()))
        let phrase = mins == 1 ? "about a minute" : "about \(mins) minutes"
        let content = UNMutableNotificationContent()
        content.title = "Touch grass soon 🌱"
        content.body = "Heads up — you'll be touching grass in \(phrase) of AI use. Start wrapping up."
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: "touchgrass.warning",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
