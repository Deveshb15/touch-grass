# 🌱 Touch Grass

A macOS menu-bar app that blocks your whole Mac for a while when you've spent too
long with AI tools. Opal-style, but specifically for AI: native apps (Claude,
ChatGPT, Cursor…), CLIs (`claude`, `codex`, `aider`, `gemini`), and AI websites
(chatgpt.com, claude.ai, gemini, perplexity…).

When you accumulate **30 minutes of active AI use** within a rolling hour, the
screen is taken over by a full-screen "touch grass" countdown for **10 minutes**.

## How it works

- **Detection** (`ActivityMonitor`, 1 Hz): looks at the frontmost app each second.
  - Native apps → matched by bundle ID (`NSWorkspace`).
  - Terminal frontmost → scans processes via `libproc` (+ `KERN_PROCARGS2` so
    interpreter-hosted CLIs like `node …/claude` are caught).
  - Browser frontmost → reads the active-tab URL via AppleScript and matches AI
    domains.
  - A second only counts if you're **not idle** (`CGEventSource` idle time).
- **Accumulation** (`UsageTracker`): a sliding window of counted seconds. Persisted,
  so quitting and relaunching doesn't reset your progress.
- **Block** (`BlockController`): full-screen overlays on every display at
  `CGShieldingWindowLevel()` + presentation options that hide the Dock/menu bar and
  disable Cmd-Tab and force-quit. The end time is persisted, so quitting during a
  block just resumes it on relaunch.

This is **"firm but escapable"** by design: there's no anti-tamper daemon, and
Activity Monitor isn't blocked — a determined user can still `killall TouchGrass`.

## Requirements

- macOS 13+ (developed/tested on macOS 15, Apple Silicon)
- Xcode 16+ and [XcodeGen](https://github.com/yonyz/XcodeGen) (`brew install xcodegen`)

## Build & run

```sh
xcodegen generate          # regenerate TouchGrass.xcodeproj from project.yml
open TouchGrass.xcodeproj   # then Run (⌘R) in Xcode
```

Or from the command line:

```sh
xcodegen generate
xcodebuild -project TouchGrass.xcodeproj -scheme TouchGrass -configuration Debug build
```

The app has no Dock icon (`LSUIElement`); look for the 🌿 leaf in the menu bar.

## First run

1. **Notifications** — allow when prompted (used for the pre-block warning).
2. **Automation** — the first time a browser is frontmost, macOS asks to let Touch
   Grass control it (to read the active tab URL). Allow it, per browser. Denials
   show up in **Settings → Permissions**.
3. **Verify bundle IDs** — the seeded list covers Cursor and ChatGPT; the Claude
   desktop ID may differ on your machine. In **Settings → AI Targets**, use
   *"Add the app I switch to (3s)…"* to capture any app's bundle ID automatically.

## ⚠️ Test the block safely first

The block disables Cmd-Tab and force-quit for its duration. Before your first real
block, open **Settings → General** and set:

- **Block after** → `0.2` min (~12 s of AI use)
- **Block duration** → `0.5` min (30 s)

Then focus an AI app and type for ~15 s. The overlay should appear on all displays
and clear itself after 30 s. Once you trust it, restore 30 / 10. If you ever get
stuck, the block always ends on its own timer; worst case, `killall TouchGrass`
from another machine over SSH.

## What to verify

- [ ] Menu-bar usage bar climbs while an AI **app** is frontmost and you're typing.
- [ ] It **pauses** when you go idle (>60 s) or switch to a non-AI app.
- [ ] `claude`/`codex` in a **frontmost terminal** counts.
- [ ] An AI site as the **active browser tab** counts (after granting Automation).
- [ ] Threshold → overlay on every display, Dock/menu bar hidden, Cmd-Tab blocked.
- [ ] Quit the app mid-block, relaunch → it **resumes** the remaining time.
- [ ] Timer ends → overlay clears, usage resets.

## Configuration

All in the menu-bar **Settings** window:

- **General** — thresholds (block-after, duration, rolling window, warning lead,
  idle cutoff), enable monitoring, launch at login.
- **AI Targets** — edit the app bundle IDs / CLI names / domains that count as AI.
- **Permissions** — Automation status + shortcuts to the relevant System Settings panes.

## Project layout

```
project.yml                     XcodeGen spec (source of truth; .xcodeproj is generated)
TouchGrass/
  Info.plist, *.entitlements    LSUIElement, hardened runtime, apple-events
  App/                          @main app, AppDelegate, AppController, Notifier, LoginItem
  Config/                       AppSettings, TargetCatalog
  Monitoring/                   ActivityMonitor, AppDetector(idle), CLIDetector, BrowserDetector, UsageTracker
  Blocking/                     BlockController, OverlayWindow, (TouchGrassView in UI/)
  UI/                           MenuBarView, SettingsView, TouchGrassView
```

## Distribution (later)

Sign with a **Developer ID Application** cert + hardened runtime, **notarize** via
`xcrun notarytool`, staple, and ship as a DMG. The App Store isn't viable here: the
sandbox blocks `libproc` and cross-app AppleScript, and the screen-takeover behavior
risks rejection.
