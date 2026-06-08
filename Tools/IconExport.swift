// IconExport.swift — renders the Touch Grass app icon to a PNG, no external deps.
//
// Run:  swift Tools/IconExport.swift
// Writes a 1024×1024 master to TouchGrass/Assets.xcassets/AppIcon.appiconset/icon_1024.png.
// The smaller sizes are produced from the master with `sips` (see the README / build steps).
//
// The icon is authored as a SwiftUI view (`AppIconArt`) and rasterized via `ImageRenderer`
// (macOS 13+). It lives in Tools/ — outside the `sources: TouchGrass` glob — so it never gets
// compiled into the app; it's just the reproducible source-of-truth for the icon artwork.
//
// Design: a cute 3D-clay grass sprout (soil mound + fanned grass blades + a chunky green body
// with two cotyledon leaves and a kawaii face) on a vibrant green gradient, drawn as a macOS
// Big Sur rounded-rect tile (824 within a 1024 canvas) with a transparent margin + soft shadow.

import SwiftUI
import AppKit

// MARK: - Color helper (mirrors TouchGrass/UI/SkyPalette.swift)

struct RGBA {
    var r, g, b, a: Double
    init(_ r: Double, _ g: Double, _ b: Double, _ a: Double = 1) { self.r = r; self.g = g; self.b = b; self.a = a }
    init(hex: UInt32, a: Double = 1) {
        r = Double((hex >> 16) & 0xFF) / 255
        g = Double((hex >> 8) & 0xFF) / 255
        b = Double(hex & 0xFF) / 255
        self.a = a
    }
    var color: Color { Color(.sRGB, red: r, green: g, blue: b, opacity: a) }
}

func c(_ hex: Int, _ a: Double = 1) -> Color { RGBA(hex: UInt32(truncatingIfNeeded: hex), a: a).color }

// MARK: - Geometry constants (tile space is 0…824)

private let canvas: CGFloat = 1024
private let tile: CGFloat   = 824
private let radius: CGFloat = 185      // ≈ 0.2247 × 824, the Big Sur corner
private let cx: CGFloat     = tile / 2 // 412, the tile's horizontal center

// MARK: - Shapes

/// A chunky tapered grass blade: rounded base, pointed tip, bulging sides.
struct Blade: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        var p = Path()
        p.move(to: CGPoint(x: w * 0.40, y: h))
        p.addQuadCurve(to: CGPoint(x: w * 0.5, y: 0),               // tip
                       control: CGPoint(x: w * -0.05, y: h * 0.42)) // left bulge
        p.addQuadCurve(to: CGPoint(x: w * 0.60, y: h),              // back to base
                       control: CGPoint(x: w * 1.05, y: h * 0.42))  // right bulge
        p.closeSubpath()
        return p
    }
}

/// A happy U-smile arc.
struct Smile: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addArc(center: CGPoint(x: rect.midX, y: rect.minY),
                 radius: rect.width / 2,
                 startAngle: .degrees(25), endAngle: .degrees(155), clockwise: false)
        return p
    }
}

// MARK: - The icon

struct AppIconArt: View {
    // Palette
    private let bgTop = 0x82DA63, bgMid = 0x46B84C, bgBot = 0x1E8341
    private let soilTop = 0x9A6A41, soilBot = 0x5E3A22
    private let bodyLo = 0x80D158, bodyHi = 0x4DA636
    private let leafLo = 0x97DE66, leafHi = 0x63BD44
    private let bladeBackLo = 0x57B345, bladeBackHi = 0x3C963A
    private let bladeFrontLo = 0x95DC5B, bladeFrontHi = 0x70C649
    private let ink = 0x33302A
    private let blush = 0xF59AAE

    private let tileShape = RoundedRectangle(cornerRadius: radius, style: .continuous)

    var body: some View {
        ZStack {
            // Transparent canvas; the tile is the only opaque thing (margin + shadow).
            tile_
                .offset(y: -6) // a touch up so the drop shadow has room below
        }
        .frame(width: canvas, height: canvas)
    }

    // The rounded-rect tile: gradient + internal glow + vignette + rim + soft shadow.
    // The sprout is scaled up and nudged up so the subject reads boldly even at 16–32px.
    private var tile_: some View {
        ZStack {
            tileShape.fill(LinearGradient(colors: [c(bgTop), c(bgMid), c(bgBot)],
                                          startPoint: .top, endPoint: .bottom))
            // Internal glow, upper-center.
            tileShape.fill(RadialGradient(colors: [.white.opacity(0.42), .clear],
                                          center: UnitPoint(x: 0.5, y: 0.34),
                                          startRadius: 0, endRadius: tile * 0.6))
            // Bottom vignette for depth.
            tileShape.fill(LinearGradient(colors: [.clear, .black.opacity(0.16)],
                                          startPoint: .center, endPoint: .bottom))
            sprout
                .scaleEffect(1.32, anchor: .center)
                .offset(y: -22)
        }
        .frame(width: tile, height: tile)
        .clipShape(tileShape)
        .overlay(tileShape.strokeBorder(.white.opacity(0.22), lineWidth: 2))
        .shadow(color: .black.opacity(0.22), radius: 28, x: 0, y: 22)
    }

    // MARK: Sprout (positioned in tile space)

    private var sprout: some View {
        ZStack {
            backBlades
            soil
            plantBody
            leaves
            frontBlades
            face
        }
        .frame(width: tile, height: tile)
    }

    private var soil: some View {
        Ellipse()
            .fill(LinearGradient(colors: [c(soilTop), c(soilBot)], startPoint: .top, endPoint: .bottom))
            .frame(width: 462, height: 166)
            .overlay(
                Ellipse().fill(c(0xFFFFFF, 0.12))
                    .frame(width: 330, height: 72).offset(y: -36)
            )
            .position(x: cx, y: 650)
            .shadow(color: .black.opacity(0.18), radius: 14, y: 10)
    }

    // Chunky rounded bulb the face lives on (kept small so the leaves read as the sprout).
    private var body_w: CGFloat { 150 }
    private var body_h: CGFloat { 174 }
    private var bodyCenter: CGPoint { CGPoint(x: cx, y: 568) }

    private var plantBody: some View {
        RoundedRectangle(cornerRadius: 74, style: .continuous)
            .fill(LinearGradient(colors: [c(bodyHi), c(bodyLo)], startPoint: .bottom, endPoint: .top))
            .frame(width: body_w, height: body_h)
            // top-left key highlight
            .overlay(
                Ellipse().fill(c(0xFFFFFF, 0.30))
                    .frame(width: 58, height: 94)
                    .blur(radius: 10)
                    .offset(x: -26, y: -40)
            )
            .position(bodyCenter)
            .shadow(color: c(0x16401E, 0.30), radius: 14, y: 10)
    }

    // Three cotyledon leaves fanning up from the crown — a small center bud behind
    // two side leaves splayed in a gentle V (a seedling).
    private var leaves: some View {
        ZStack(alignment: .bottom) {
            oneLeaf(angle: 0, w: 82, h: 188)   // center bud, behind
            oneLeaf(angle: -40)
            oneLeaf(angle: 40)
        }
        .frame(width: 2, height: 2)
        .position(x: cx, y: 488)
    }

    private func oneLeaf(angle: Double, w: CGFloat = 116, h: CGFloat = 214) -> some View {
        Ellipse()
            .fill(LinearGradient(colors: [c(leafHi), c(leafLo)], startPoint: .bottom, endPoint: .top))
            .frame(width: w, height: h)
            .overlay( // center vein
                Capsule().fill(c(0xFFFFFF, 0.22))
                    .frame(width: w * 0.06, height: h * 0.68).offset(y: -h * 0.08)
            )
            .overlay( // soft top gloss
                Ellipse().fill(c(0xFFFFFF, 0.26))
                    .frame(width: w * 0.45, height: h * 0.34).blur(radius: 8).offset(x: -w * 0.09, y: -h * 0.26)
            )
            .rotationEffect(.degrees(angle), anchor: .bottom)
            .shadow(color: c(0x16401E, 0.22), radius: 10, y: 6)
    }

    // Grass blades fanning from the soil, behind and in front of the body.
    private var backBlades: some View {
        let specs: [(Double, CGFloat, CGFloat)] = [   // (angle°, width, height)
            (-54, 72, 256), (-38, 82, 312), (-22, 76, 280),
            (22, 76, 276), (38, 82, 306), (54, 72, 250),
        ]
        return bladeFan(specs, lo: bladeBackLo, hi: bladeBackHi, baseY: 664)
    }

    private var frontBlades: some View {
        let specs: [(Double, CGFloat, CGFloat)] = [
            (-66, 60, 162), (-78, 50, 120), (66, 58, 150), (78, 50, 116),
        ]
        return bladeFan(specs, lo: bladeFrontLo, hi: bladeFrontHi, baseY: 670)
    }

    private func bladeFan(_ specs: [(Double, CGFloat, CGFloat)], lo: Int, hi: Int, baseY: CGFloat) -> some View {
        ZStack {
            ForEach(0..<specs.count, id: \.self) { i in
                let s = specs[i]
                Blade()
                    .fill(LinearGradient(colors: [c(lo), c(hi)], startPoint: .bottom, endPoint: .top))
                    .frame(width: s.1, height: s.2)
                    .overlay(
                        Blade().fill(c(0xFFFFFF, 0.18))
                            .frame(width: s.1 * 0.4, height: s.2 * 0.9).offset(x: -s.1 * 0.16)
                    )
                    .rotationEffect(.degrees(s.0), anchor: .bottom)
                    .position(x: cx, y: baseY - s.2 / 2)
            }
        }
    }

    // Kawaii face on the body.
    private var face: some View {
        let eyeY = bodyCenter.y - 16
        return ZStack {
            eye.position(x: cx - 33, y: eyeY)
            eye.position(x: cx + 33, y: eyeY)
            Smile()
                .stroke(c(ink), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .frame(width: 60, height: 30)
                .position(x: cx, y: eyeY + 50)
            blushDot.position(x: cx - 56, y: eyeY + 30)
            blushDot.position(x: cx + 56, y: eyeY + 30)
        }
    }

    private var eye: some View {
        ZStack {
            Capsule().fill(c(ink)).frame(width: 30, height: 40)
            Circle().fill(.white).frame(width: 11, height: 11).offset(x: 6, y: -11)
        }
    }

    private var blushDot: some View {
        Ellipse().fill(c(blush, 0.55)).frame(width: 38, height: 24)
    }
}

// MARK: - Render

@MainActor
func renderIcon() {
    let out = "TouchGrass/Assets.xcassets/AppIcon.appiconset/icon_1024.png"
    let renderer = ImageRenderer(content: AppIconArt().frame(width: canvas, height: canvas))
    renderer.scale = 1
    guard let cg = renderer.cgImage else {
        FileHandle.standardError.write(Data("ERROR: ImageRenderer produced no image\n".utf8))
        exit(1)
    }
    let rep = NSBitmapImageRep(cgImage: cg)
    guard let data = rep.representation(using: .png, properties: [:]) else {
        FileHandle.standardError.write(Data("ERROR: PNG encoding failed\n".utf8))
        exit(1)
    }
    do {
        try data.write(to: URL(fileURLWithPath: out))
        print("wrote \(out)  (\(cg.width)×\(cg.height))")
    } catch {
        FileHandle.standardError.write(Data("ERROR writing \(out): \(error)\n".utf8))
        exit(1)
    }
}

MainActor.assumeIsolated { renderIcon() }
