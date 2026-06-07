import Foundation
import Combine

enum BrowserKind {
    case safari      // uses `current tab of front window`
    case chromium    // uses `active tab of front window`
}

struct BrowserTarget {
    let appName: String   // AppleScript application name
    let kind: BrowserKind
}

/// The editable list of things that count as "AI usage": native app bundle IDs,
/// terminal CLI executable names, and AI website domains. Plus the (fixed v1)
/// catalog of terminals and browsers we know how to introspect.
final class TargetCatalog: ObservableObject {
    private let defaults = UserDefaults.standard

    @Published var aiBundleIDs: Set<String> { didSet { save(aiBundleIDs, Keys.bundles) } }
    @Published var aiCLINames: Set<String> { didSet { save(aiCLINames, Keys.cli) } }
    @Published var aiDomains: Set<String> { didSet { save(aiDomains, Keys.domains) } }

    init() {
        aiBundleIDs = TargetCatalog.load(Keys.bundles, default: TargetCatalog.defaultBundleIDs)
        aiCLINames = TargetCatalog.load(Keys.cli, default: TargetCatalog.defaultCLINames)
        aiDomains = TargetCatalog.load(Keys.domains, default: TargetCatalog.defaultDomains)
        mergeNewDefaultsIfNeeded()
    }

    /// On upgrade, union newly-shipped default targets into the saved catalog so
    /// new known AI apps appear without clobbering the user's own edits. Bump
    /// `currentVersion` whenever the seeded defaults change.
    private func mergeNewDefaultsIfNeeded() {
        let currentVersion = 2
        guard defaults.integer(forKey: Keys.version) < currentVersion else { return }
        aiBundleIDs.formUnion(Self.defaultBundleIDs)   // didSet persists each
        aiCLINames.formUnion(Self.defaultCLINames)
        aiDomains.formUnion(Self.defaultDomains)
        defaults.set(currentVersion, forKey: Keys.version)
    }

    func isTerminal(_ bundleID: String) -> Bool { Self.terminalBundleIDs.contains(bundleID) }
    func browser(for bundleID: String) -> BrowserTarget? { Self.browsers[bundleID] }

    /// True if `host` matches a configured AI domain (exact or subdomain).
    func matchesDomain(_ host: String) -> Bool {
        let h = host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
        return aiDomains.contains { h == $0 || h.hasSuffix("." + $0) }
    }

    // MARK: Seeded defaults

    /// ⚠️ Verify on-device (Learn mode / `osascript -e 'id of app "Claude"'`).
    static let defaultBundleIDs: Set<String> = [
        "com.anthropic.claudefordesktop",  // Claude desktop (confirmed on-device)
        "com.anthropic.claude",            // alternate Claude id
        "com.openai.chat",                 // ChatGPT desktop
        "com.openai.codex",                // Codex desktop (confirmed on-device)
        "com.todesktop.230313mzl4w4u92",   // Cursor (confirmed on-device)
        "com.exafunction.windsurf",        // Windsurf (confirmed on-device)
        "com.electron.ollama",             // Ollama (confirmed on-device)
    ]

    static let defaultCLINames: Set<String> = ["claude", "codex", "aider", "gemini"]

    static let defaultDomains: Set<String> = [
        "chatgpt.com", "chat.openai.com", "claude.ai", "gemini.google.com",
        "perplexity.ai", "copilot.microsoft.com", "poe.com", "grok.com", "x.ai",
        "deepseek.com", "chat.deepseek.com", "chat.mistral.ai", "character.ai",
        "you.com", "phind.com",
    ]

    static let terminalBundleIDs: Set<String> = [
        // terminals
        "com.apple.Terminal", "com.googlecode.iterm2", "dev.warp.Warp-Stable",
        "net.kovidgoyal.kitty", "io.alacritty", "com.github.wez.wezterm",
        "com.mitchellh.ghostty", "co.zeit.hyper", "org.tabby",
        // editors/IDEs that host CLIs in an integrated terminal
        "com.microsoft.VSCode", "com.microsoft.VSCodeInsiders",
        "com.todesktop.230313mzl4w4u92",   // Cursor
        "com.exafunction.windsurf",        // Windsurf
        "com.jetbrains.intellij", "com.jetbrains.pycharm",
        "com.jetbrains.WebStorm", "com.jetbrains.goland",
    ]

    static let browsers: [String: BrowserTarget] = [
        "com.apple.Safari": .init(appName: "Safari", kind: .safari),
        "com.apple.SafariTechnologyPreview": .init(appName: "Safari Technology Preview", kind: .safari),
        "com.google.Chrome": .init(appName: "Google Chrome", kind: .chromium),
        "com.google.Chrome.canary": .init(appName: "Google Chrome Canary", kind: .chromium),
        "com.microsoft.edgemac": .init(appName: "Microsoft Edge", kind: .chromium),
        "com.brave.Browser": .init(appName: "Brave Browser", kind: .chromium),
        "company.thebrowser.Browser": .init(appName: "Arc", kind: .chromium),
        "com.vivaldi.Vivaldi": .init(appName: "Vivaldi", kind: .chromium),
        "com.operasoftware.Opera": .init(appName: "Opera", kind: .chromium),
    ]

    // MARK: Persistence helpers

    private func save(_ set: Set<String>, _ key: String) {
        defaults.set(Array(set).sorted(), forKey: key)
    }

    private static func load(_ key: String, default fallback: Set<String>) -> Set<String> {
        if let arr = UserDefaults.standard.array(forKey: key) as? [String] {
            return Set(arr)
        }
        return fallback
    }

    private enum Keys {
        static let bundles = "catalog.aiBundleIDs"
        static let cli = "catalog.aiCLINames"
        static let domains = "catalog.aiDomains"
        static let version = "catalog.defaultsVersion"
    }
}
