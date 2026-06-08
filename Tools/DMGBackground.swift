// DMGBackground.swift — renders the disk-image "drag to Applications" background, no external deps.
//
// Run:  swift Tools/DMGBackground.swift   → writes dist/dmg-bg.png (1320×840 = @2x of 660×420).
//
// A static slice of the onboarding's pink dawn: lavender→cream gradient + a low sun-glow bloom,
// "touch grass" up top, two frosted pads where the app icon and the Applications alias sit, and a
// rose arrow between them. The drop-zone centers MUST match the create-dmg --icon / --app-drop-link
// coordinates (app at 180,205 — Applications at 480,205 — in the 660×420 window).
//
// Self-contained (mirrors Tools/IconExport.swift): inlines RGBA + c() so it compiles standalone
// and never enters the app target.

import SwiftUI
import AppKit

struct RGBA {
    var r, g, b, a: Double
    init(hex: UInt32, a: Double = 1) {
        r = Double((hex >> 16) & 0xFF) / 255
        g = Double((hex >> 8) & 0xFF) / 255
        b = Double(hex & 0xFF) / 255
        self.a = a
    }
    var color: Color { Color(.sRGB, red: r, green: g, blue: b, opacity: a) }
}
func c(_ hex: Int, _ a: Double = 1) -> Color { RGBA(hex: UInt32(truncatingIfNeeded: hex), a: a).color }

private let W: CGFloat = 660
private let H: CGFloat = 420
private let appCenter  = CGPoint(x: 180, y: 205)
private let appsCenter = CGPoint(x: 480, y: 205)

struct DMGBackgroundArt: View {
    // DawnPalette hexes.
    private let skyTop = 0xEAD7EC, skyHi = 0xF6D7DD, skyMid = 0xFBE3D8, skyBot = 0xFDF3EA
    private let inkPrimary = 0x5B4A66, inkMuted = 0x9A86A6, accentRose = 0xF4A9BC, deepRose = 0x7A3F58, shadow = 0x7A5A6B

    var body: some View {
        ZStack {
            LinearGradient(colors: [c(skyTop), c(skyHi), c(skyMid), c(skyBot)],
                           startPoint: .top, endPoint: .bottom)
            RadialGradient(colors: [Color.white.opacity(0.55), Color.white.opacity(0)],
                           center: UnitPoint(x: 0.5, y: 0.78),
                           startRadius: 0, endRadius: W * 0.6)

            VStack(spacing: 6) {
                Text("touch grass")
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .foregroundStyle(c(deepRose))
                Text("after too much AI, it nudges you outside to touch real grass")
                    .font(.system(size: 13.5, weight: .medium, design: .rounded))
                    .foregroundStyle(c(inkPrimary, 0.72))
            }
            .position(x: W / 2, y: 60)

            pad.position(appCenter)
            pad.position(appsCenter)

            ArrowShape()
                .stroke(c(accentRose), style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                .frame(width: 116, height: 28)
                .position(x: (appCenter.x + appsCenter.x) / 2, y: appCenter.y)
                .shadow(color: c(accentRose, 0.4), radius: 6, y: 2)

            Text("drag me into your Applications folder")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(c(inkMuted))
                .position(x: W / 2, y: 366)
        }
        .frame(width: W, height: H)
    }

    /// A soft frosted pad the real icon / Applications alias rests on.
    private var pad: some View {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
            .fill(Color.white.opacity(0.4))
            .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(Color.white.opacity(0.6), lineWidth: 1))
            .frame(width: 168, height: 190)
            .shadow(color: c(shadow, 0.12), radius: 12, y: 6)
    }
}

/// A horizontal arrow pointing right (from the app pad toward the Applications pad).
struct ArrowShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let y = rect.midY
        p.move(to: CGPoint(x: rect.minX, y: y))
        p.addLine(to: CGPoint(x: rect.maxX, y: y))
        p.move(to: CGPoint(x: rect.maxX - 14, y: y - 9))
        p.addLine(to: CGPoint(x: rect.maxX, y: y))
        p.addLine(to: CGPoint(x: rect.maxX - 14, y: y + 9))
        return p
    }
}

@MainActor
func render(scale: CGFloat, to out: String) {
    let renderer = ImageRenderer(content: DMGBackgroundArt().frame(width: W, height: H))
    renderer.scale = scale
    guard let cg = renderer.cgImage else {
        FileHandle.standardError.write(Data("ERROR: no image\n".utf8)); exit(1)
    }
    let rep = NSBitmapImageRep(cgImage: cg)
    guard let data = rep.representation(using: .png, properties: [:]) else {
        FileHandle.standardError.write(Data("ERROR: png encode\n".utf8)); exit(1)
    }
    do {
        try data.write(to: URL(fileURLWithPath: out))
        print("wrote \(out)  (\(cg.width)×\(cg.height))")
    } catch {
        FileHandle.standardError.write(Data("ERROR writing \(out): \(error)\n".utf8)); exit(1)
    }
}

// Emit a 1× and a 2× PNG; a HiDPI .tiff is assembled from them (see build steps) so the
// background maps 1:1 to the 660×420-point window yet stays crisp on retina.
MainActor.assumeIsolated {
    render(scale: 1, to: "dist/dmg-bg-1x.png")
    render(scale: 2, to: "dist/dmg-bg-2x.png")
}
