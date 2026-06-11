import SwiftUI
import AppKit

/// Settings, dressed in the same magical pink dawn as the onboarding: a live dawn
/// landscape behind a frosted card with custom rose-pink controls and pink segmented
/// tabs. Hosted in `SettingsWindow` (pinned to light), so the system Slider/Toggle
/// render light + pink rather than dark/muddy.
struct SettingsView: View {
    @EnvironmentObject var controller: AppController
    @State private var tab: Tab = .general

    enum Tab: String, CaseIterable, Identifiable {
        case general = "general", targets = "targets", permissions = "permissions"
        var id: String { rawValue }
    }

    var body: some View {
        ZStack {
            DawnBackground()
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("settings")
                        .font(.system(size: 23, weight: .semibold, design: .rounded))
                        .foregroundStyle(DawnPalette.inkPrimary)
                    Text("tune your pace, targets, and permissions.")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(DawnPalette.inkMuted)
                }
                tabBar
                ScrollView {
                    Group {
                        switch tab {
                        case .general:     GeneralTab(settings: controller.settings)
                        case .targets:     TargetsTab(catalog: controller.catalog)
                        case .permissions: PermissionsTab(browser: controller.monitor.browser)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 2)
                }
                .scrollIndicators(.hidden)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .dawnCard()
        }
        .preferredColorScheme(.light)
    }

    private var tabBar: some View {
        HStack(spacing: 8) {
            ForEach(Tab.allCases) { t in
                Button { tab = t } label: { dawnPill(t.rawValue, selected: tab == t) }
                    .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Section helper (shared by the tabs)

@ViewBuilder
private func section<C: View>(_ title: String, @ViewBuilder _ content: () -> C) -> some View {
    VStack(alignment: .leading, spacing: 10) {
        dawnSectionLabel(title)
        VStack(alignment: .leading, spacing: 14) { content() }
    }
}

// MARK: - General

private struct GeneralTab: View {
    @ObservedObject var settings: AppSettings
    @EnvironmentObject var updater: SparkleUpdater
    @State private var launchAtLogin = LoginItem.isEnabled
    @FocusState private var nameFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            section("you") {
                TextField("your name", text: $settings.userName)
                    .textFieldStyle(.plain)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(DawnPalette.inkPrimary)
                    .tint(DawnPalette.accentRose)
                    .focused($nameFocused)
                    .dawnField(focused: nameFocused)
            }
            section("limits") {
                slider("block after", value: $settings.thresholdMinutes,
                       range: 0.2...120, unit: "min of AI use")
                slider("block duration", value: $settings.blockDurationMinutes,
                       range: 0.2...60, unit: "min")
                slider("rolling window", value: $settings.windowLengthMinutes,
                       range: 5...480, unit: "min", step: 5)
                slider("warn", value: $settings.warningLeadMinutes,
                       range: 0...30, unit: "min before block")
                slider("background grace", value: $settings.backgroundGraceSeconds,
                       range: 0...900, unit: "sec", step: 15)
                slider("presence window", value: $settings.presenceWindowSeconds,
                       range: 10...300, unit: "sec since input", step: 5)
                slider("agent-busy threshold", value: cpuPercentBinding,
                       range: 1...50, unit: "% of a core", step: 1)
            }
            section("monitoring") {
                toggleRow("enable monitoring", isOn: $settings.monitoringEnabled)
                toggleRow("launch at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in LoginItem.setEnabled(newValue) }
            }
            section("updates") {
                Button { updater.checkForUpdates() } label: {
                    dawnPrimaryLabel("check for updates…", systemImage: "arrow.triangle.2.circlepath")
                }
                .buttonStyle(PressableButtonStyle())
                .disabled(!updater.canCheckForUpdates)
            }
        }
    }

    /// CPU fraction (0…1) shown as a percentage of one core.
    private var cpuPercentBinding: Binding<Double> {
        .init(get: { settings.cliWorkingCPUFraction * 100 },
              set: { settings.cliWorkingCPUFraction = $0 / 100 })
    }

    private func slider(_ title: String, value: Binding<Double>,
                        range: ClosedRange<Double>, unit: String,
                        step: Double = 0.5) -> some View {
        // Step-less Slider draws no tick marks; we snap to `step` in the binding.
        let snapped = Binding<Double>(
            get: { value.wrappedValue },
            set: { value.wrappedValue = ((($0 / step).rounded()) * step) })
        return VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(title)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(DawnPalette.inkPrimary)
                Spacer()
                Text("\(value.wrappedValue, specifier: value.wrappedValue < 1 ? "%.1f" : "%.0f") \(unit)")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(DawnPalette.inkMuted)
                    .monospacedDigit()
            }
            Slider(value: snapped, in: range)
                .tint(DawnPalette.accentRose)
        }
    }

    private func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(DawnPalette.inkPrimary)
            Spacer()
            Toggle("", isOn: isOn).labelsHidden().tint(DawnPalette.accentRose)
        }
    }
}

// MARK: - Targets

private struct TargetsTab: View {
    @ObservedObject var catalog: TargetCatalog
    @State private var captureStatus: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            section("AI apps (bundle IDs)") {
                DawnList(items: bundleBinding)
                Button { captureFrontmostApp() } label: {
                    dawnPrimaryLabel("add the app I switch to (3s)…", systemImage: "plus.viewfinder")
                }
                .buttonStyle(PressableButtonStyle())
                if let captureStatus {
                    Text(captureStatus)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(DawnPalette.inkMuted)
                }
            }
            section("command-line tools") { DawnList(items: cliBinding) }
            section("website domains") { DawnList(items: domainBinding) }
        }
    }

    private func captureFrontmostApp() {
        captureStatus = "switch to the app now…"
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            guard let app = NSWorkspace.shared.frontmostApplication,
                  let id = app.bundleIdentifier,
                  id != Bundle.main.bundleIdentifier else {
                captureStatus = "couldn't capture an app."
                return
            }
            catalog.aiBundleIDs.insert(id)
            captureStatus = "added \(app.localizedName ?? id) (\(id))"
        }
    }

    private var bundleBinding: Binding<[String]> {
        .init(get: { catalog.aiBundleIDs.sorted() }, set: { catalog.aiBundleIDs = Set($0) })
    }
    private var cliBinding: Binding<[String]> {
        .init(get: { catalog.aiCLINames.sorted() }, set: { catalog.aiCLINames = Set($0) })
    }
    private var domainBinding: Binding<[String]> {
        .init(get: { catalog.aiDomains.sorted() }, set: { catalog.aiDomains = Set($0) })
    }
}

/// Add/remove string list editor, dawn-styled.
private struct DawnList: View {
    @Binding var items: [String]
    @State private var newItem = ""
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                HStack {
                    Text(item)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(DawnPalette.inkPrimary)
                    Spacer()
                    Button { items.removeAll { $0 == item } } label: {
                        Image(systemName: "minus.circle.fill")
                            .foregroundStyle(DawnPalette.accentRose)
                    }
                    .buttonStyle(.plain)
                }
            }
            HStack(spacing: 8) {
                TextField("add…", text: $newItem)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(DawnPalette.inkPrimary)
                    .tint(DawnPalette.accentRose)
                    .focused($focused)
                    .onSubmit(add)
                    .dawnField(focused: focused)
                Button(action: add) { dawnPrimaryLabel("add") }
                    .buttonStyle(PressableButtonStyle())
            }
        }
    }

    private func add() {
        let trimmed = newItem.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !items.contains(trimmed) else { return }
        items.append(trimmed)
        newItem = ""
    }
}

// MARK: - Permissions

private struct PermissionsTab: View {
    @ObservedObject var browser: BrowserDetector

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            section("browser detection (automation)") {
                Text("Touch Grass reads your browser's active-tab URL to spot AI sites. macOS asks permission once per browser the first time.")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(DawnPalette.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
                if browser.permissionDenied.isEmpty {
                    statusLabel("no denials recorded", system: "checkmark.circle.fill", tint: DawnPalette.positive)
                } else {
                    ForEach(browser.permissionDenied.sorted(), id: \.self) { app in
                        statusLabel("\(app): denied", system: "xmark.circle.fill", tint: DawnPalette.accentRose)
                    }
                }
                Button { open("x-apple.systempreferences:com.apple.preference.security?Privacy_Automation") } label: {
                    dawnPrimaryLabel("open automation settings…")
                }
                .buttonStyle(PressableButtonStyle())
            }
            section("accessibility (firefox / fallback)") {
                Button { open("x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") } label: {
                    dawnPrimaryLabel("open accessibility settings…")
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
    }

    private func statusLabel(_ text: String, system: String, tint: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: system).foregroundStyle(tint)
            Text(text).font(.system(size: 12, design: .rounded)).foregroundStyle(DawnPalette.inkPrimary)
        }
    }

    private func open(_ urlString: String) {
        if let url = URL(string: urlString) { NSWorkspace.shared.open(url) }
    }
}
