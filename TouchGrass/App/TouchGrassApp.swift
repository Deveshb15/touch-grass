import SwiftUI
import AppKit

@main
struct TouchGrassApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(appDelegate.controller)
        } label: {
            MenuBarLabel(controller: appDelegate.controller)
        }
        .menuBarExtraStyle(.window)
        // Settings is presented via AppController.showSettings() in our own
        // (light, pink) SettingsWindow — not the SwiftUI `Settings` scene, which
        // doesn't open reliably for an accessory app and spawned a stray window.
    }
}

/// Owns the controller's lifecycle and starts monitoring after launch.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let controller = AppController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        controller.start()
    }
}

/// Menu-bar icon that reflects current state (idle / using AI / blocking).
struct MenuBarLabel: View {
    @ObservedObject var controller: AppController
    var body: some View {
        Image(systemName: controller.menuBarSymbol)
    }
}
