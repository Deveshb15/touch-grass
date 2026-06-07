import SwiftUI
import AppKit

struct SettingsView: View {
    @EnvironmentObject var controller: AppController

    var body: some View {
        TabView {
            GeneralSettings(settings: controller.settings)
                .tabItem { Label("General", systemImage: "gearshape") }
            TargetsSettings(catalog: controller.catalog)
                .tabItem { Label("AI Targets", systemImage: "scope") }
            PermissionsSettings(browser: controller.monitor.browser)
                .tabItem { Label("Permissions", systemImage: "lock.shield") }
        }
        .frame(width: 470, height: 440)
    }
}

// MARK: - General

private struct GeneralSettings: View {
    @ObservedObject var settings: AppSettings
    @State private var launchAtLogin = LoginItem.isEnabled

    var body: some View {
        Form {
            Section("Limits") {
                slider("Block after", value: $settings.thresholdMinutes,
                       range: 0.2...120, unit: "min of AI use")
                slider("Block duration", value: $settings.blockDurationMinutes,
                       range: 0.2...60, unit: "min")
                slider("Rolling window", value: $settings.windowLengthMinutes,
                       range: 5...240, unit: "min", step: 5)
                slider("Warn", value: $settings.warningLeadMinutes,
                       range: 0...30, unit: "min before block")
                slider("Background grace", value: $settings.backgroundGraceSeconds,
                       range: 0...900, unit: "sec", step: 15)
            }
            Section {
                Toggle("Enable monitoring", isOn: $settings.monitoringEnabled)
                Toggle("Launch at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in LoginItem.setEnabled(newValue) }
            }
        }
        .formStyle(.grouped)
    }

    private func slider(_ title: String, value: Binding<Double>,
                        range: ClosedRange<Double>, unit: String,
                        step: Double = 0.5) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(title)
                Spacer()
                Text("\(value.wrappedValue, specifier: value.wrappedValue < 1 ? "%.1f" : "%.0f") \(unit)")
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            Slider(value: value, in: range, step: step)
        }
    }
}

// MARK: - Targets

private struct TargetsSettings: View {
    @ObservedObject var catalog: TargetCatalog
    @State private var captureStatus: String?

    var body: some View {
        Form {
            Section("AI apps (bundle IDs)") {
                EditableList(items: bundleBinding)
                Button {
                    captureFrontmostApp()
                } label: {
                    Label("Add the app I switch to (3s)…", systemImage: "plus.viewfinder")
                }
                if let captureStatus {
                    Text(captureStatus).font(.caption).foregroundStyle(.secondary)
                }
            }
            Section("AI command-line tools") {
                EditableList(items: cliBinding)
            }
            Section("AI website domains") {
                EditableList(items: domainBinding)
            }
        }
        .formStyle(.grouped)
    }

    private func captureFrontmostApp() {
        captureStatus = "Switch to the app now…"
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            guard let app = NSWorkspace.shared.frontmostApplication,
                  let id = app.bundleIdentifier,
                  id != Bundle.main.bundleIdentifier else {
                captureStatus = "Couldn't capture an app."
                return
            }
            catalog.aiBundleIDs.insert(id)
            captureStatus = "Added \(app.localizedName ?? id) (\(id))"
        }
    }

    private var bundleBinding: Binding<[String]> {
        .init(get: { catalog.aiBundleIDs.sorted() },
              set: { catalog.aiBundleIDs = Set($0) })
    }
    private var cliBinding: Binding<[String]> {
        .init(get: { catalog.aiCLINames.sorted() },
              set: { catalog.aiCLINames = Set($0) })
    }
    private var domainBinding: Binding<[String]> {
        .init(get: { catalog.aiDomains.sorted() },
              set: { catalog.aiDomains = Set($0) })
    }
}

/// A simple add/remove string list editor.
private struct EditableList: View {
    @Binding var items: [String]
    @State private var newItem = ""

    var body: some View {
        ForEach(items, id: \.self) { item in
            HStack {
                Text(item).font(.callout)
                Spacer()
                Button(role: .destructive) {
                    items.removeAll { $0 == item }
                } label: {
                    Image(systemName: "minus.circle")
                }
                .buttonStyle(.borderless)
            }
        }
        HStack {
            TextField("Add…", text: $newItem)
                .textFieldStyle(.roundedBorder)
                .onSubmit(add)
            Button("Add", action: add)
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

private struct PermissionsSettings: View {
    @ObservedObject var browser: BrowserDetector

    var body: some View {
        Form {
            Section("Browser detection (Automation)") {
                Text("Touch Grass reads your browser's active-tab URL to spot AI sites. macOS asks permission once per browser the first time.")
                    .font(.caption).foregroundStyle(.secondary)
                if browser.permissionDenied.isEmpty {
                    Label("No denials recorded", systemImage: "checkmark.circle")
                        .foregroundStyle(.green)
                } else {
                    ForEach(browser.permissionDenied.sorted(), id: \.self) { app in
                        Label("\(app): denied", systemImage: "xmark.circle")
                            .foregroundStyle(.red)
                    }
                }
                Button("Open Automation settings…") {
                    open("x-apple.systempreferences:com.apple.preference.security?Privacy_Automation")
                }
            }
            Section("Accessibility (Firefox / fallback)") {
                Button("Open Accessibility settings…") {
                    open("x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
                }
            }
        }
        .formStyle(.grouped)
    }

    private func open(_ urlString: String) {
        if let url = URL(string: urlString) { NSWorkspace.shared.open(url) }
    }
}
