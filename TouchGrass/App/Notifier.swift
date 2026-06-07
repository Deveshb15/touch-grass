import Foundation
import UserNotifications

/// Thin wrapper around local notifications for the pre-block warning.
/// Failures are non-fatal — the menu-bar HUD is the source of truth.
enum Notifier {
    static func requestAuthorization() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    static func warnBreakComing(inMinutes minutes: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Touch grass soon 🌱"
        content.body = "You're about to hit your AI limit — a \(minutes)-minute break is coming up."
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: "touchgrass.warning",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
