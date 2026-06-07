import SwiftUI

/// The full-screen lockout shown on every display during a block.
///
/// A calm landscape that lives through a day: the sun rises at the start and
/// arcs to a warm dusk as the timer runs down, birds drift across the sky, water
/// shimmers, and a plant grows on the near shore and blooms toward golden hour.
/// The day-cycle is a gentle "almost done" cue; the countdown is the exact one.
///
/// Two clocks drive it: block-progress `growth` (0→1, from `BlockClock`) moves the
/// sun, shifts every color, and grows the plant; a continuous 30fps `TimelineView`
/// drives the birds, ripples, and clouds as pure functions of elapsed time.
struct TouchGrassView: View {
    @ObservedObject var clock: BlockClock
    /// Name shown in the personalized title; empty → generic copy.
    var userName: String = ""
    /// Chosen once per block so the rotating title/helper stay stable for this break.
    var greetingSeed: Int = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Reference epoch for the continuous clock, captured once per overlay so the
    /// animation phase is stable across this view's lifetime.
    private let epoch = Date().timeIntervalSinceReferenceDate

    /// 0 at the start of the block → 1 when it ends. Drives sun, sky, and plant.
    private var growth: Double {
        guard clock.total > 0 else { return 1 }
        return min(1, max(0, 1 - clock.remaining / clock.total))
    }

    private var countdown: String {
        let total = Int(clock.remaining.rounded(.up))
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let g = growth
            let sky = SkyPalette.ramp(at: g)
            // Pause continuous motion when the block is over or the user prefers
            // reduced motion — the slow color drift (informational) still applies.
            let paused = clock.remaining <= 0 || reduceMotion

            ZStack {
                // Backdrop: sky gradient + far hills, then the sun on its arc.
                SkyView(size: size, colors: sky)
                SunView(size: size, growth: g, tint: sky.sun.color, animate: !reduceMotion)

                // One continuous clock for everything that's alive every frame.
                TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: paused)) { tl in
                    let t = tl.date.timeIntervalSinceReferenceDate - epoch
                    ZStack {
                        CloudsCanvas(size: size, t: t, tint: sky.cloud.color)
                        BirdsCanvas(size: size, t: t, tint: sky.bird.color)
                        WaterView(size: size, t: t, growth: g, surface: sky.water, sunTint: sky.sun)
                    }
                }

                // Foreground: shore bank, then the plant rooted on it (off-center).
                ShoreView(size: size)
                PlantView(growth: g)
                    .frame(width: size.width * 0.32, height: size.height * 0.52)
                    .position(x: size.width * 0.30, y: size.height * 0.59)

                textOverlay(size: size, sky: sky)

                GrainOverlay()
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }

    /// Title at the top, countdown + helper at the bottom over a soft scrim, with
    /// an adaptive ink color so type stays legible as the sky shifts toward dusk.
    @ViewBuilder
    private func textOverlay(size: CGSize, sky: SkyColors) -> some View {
        let ink = sky.ink.color
        ZStack {
            // Bottom scrim — guarantees the countdown reads over any sky/water.
            VStack {
                Spacer()
                LinearGradient(colors: [.clear, .black.opacity(0.32)],
                               startPoint: .top, endPoint: .bottom)
                    .frame(height: size.height * 0.34)
            }
            .allowsHitTesting(false)

            // Title, top — personalized + rotating per block.
            VStack {
                Text(BlockGreeting.title(name: userName, seed: greetingSeed))
                    .font(.system(size: 40, weight: .semibold, design: .rounded))
                    .tracking(1)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(ink)
                    .shadow(color: .black.opacity(0.18), radius: 8, y: 1)
                    .padding(.horizontal, 32)
                Spacer()
            }
            .padding(.top, size.height * 0.08)

            // Countdown + helper, bottom.
            VStack {
                Spacer()
                VStack(spacing: 14) {
                    // White on a solid dark pill reads cleanly at every day stage
                    // (pastel dawn, cream midday, violet dusk) and over the soil —
                    // unlike a material capsule, which picks up the brown shore.
                    Text(countdown)
                        .font(.system(size: 46, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(Color.black.opacity(0.34)))
                        .overlay(Capsule().stroke(Color.white.opacity(0.4), lineWidth: 1))
                        .shadow(color: .black.opacity(0.30), radius: 16, y: 6)

                    Text(BlockGreeting.helper(name: userName, seed: greetingSeed))
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.92))
                        .shadow(color: .black.opacity(0.45), radius: 6, y: 1)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom, size.height * 0.06)
            }
        }
    }
}
