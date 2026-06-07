import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var controller: AppController

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            if controller.isBlocking {
                blockingRow
            } else {
                usageRow
                activityRow
            }

            Divider()

            Toggle("Pause monitoring", isOn: $controller.isPaused)
                .toggleStyle(.switch)
                .font(.callout)

            HStack {
                Button("Settings…") { openSettingsWindow() }
                Spacer()
                Button("Quit") { NSApplication.shared.terminate(nil) }
            }
            .font(.callout)
        }
        .padding(14)
        .frame(width: 280)
    }

    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: controller.menuBarSymbol)
                .foregroundStyle(.green)
            Text("Touch Grass")
                .font(.headline)
            Spacer()
        }
    }

    private var usageRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("AI usage")
                Spacer()
                Text("\(minutes(controller.usage.usedSeconds)) / \(minutes(controller.settings.thresholdSeconds)) min")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            .font(.callout)
            ProgressView(value: controller.usageFraction)
                .tint(controller.usageFraction > 0.8 ? .orange : .green)
        }
    }

    private var activityRow: some View {
        HStack(spacing: 6) {
            Image(systemName: controller.currentActivity.symbol)
                .foregroundStyle(controller.currentActivity.isActive ? .orange : .secondary)
            Text(controller.currentActivity.label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    private var blockingRow: some View {
        HStack(spacing: 8) {
            Text("🌱")
            VStack(alignment: .leading) {
                Text("Touch grass")
                    .font(.callout).bold()
                Text("Back in \(countdown(controller.blockRemaining))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            Spacer()
        }
    }

    /// Opens the SwiftUI Settings scene across macOS 13/14+ (the `openSettings`
    /// environment value is 14-only), by sending the standard menu action.
    private func openSettingsWindow() {
        NSApp.activate(ignoringOtherApps: true)
        if !NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil) {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }

    private func minutes(_ seconds: Double) -> Int { Int((seconds / 60).rounded()) }

    private func countdown(_ seconds: Double) -> String {
        let total = Int(seconds.rounded(.up))
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}
