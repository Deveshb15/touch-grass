import SwiftUI

/// The full-screen lockout shown on every display during a block.
///
/// A warm, beige "garden": a plant grows over the block and a flower opens right
/// as the timer hits 0, so waiting it out is rewarding rather than purely a
/// punishment. The growing plant *is* the progress indicator.
struct TouchGrassView: View {
    @ObservedObject var clock: BlockClock
    @State private var breathe = false

    /// 0 at the start of the block → 1 when it ends. Drives the plant's growth.
    private var growth: Double {
        guard clock.total > 0 else { return 1 }
        return min(1, max(0, 1 - clock.remaining / clock.total))
    }

    private var countdown: String {
        let total = Int(clock.remaining.rounded(.up))
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Palette.creamTop, Palette.sandBottom],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            // Soft warm halo behind the plant that slowly "breathes".
            RadialGradient(colors: [Palette.glow.opacity(0.85), Palette.glow.opacity(0)],
                           center: .center, startRadius: 0, endRadius: 460)
                .scaleEffect(breathe ? 1.06 : 0.97)
                .opacity(breathe ? 0.95 : 0.6)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: breathe)

            VStack(spacing: 24) {
                Text("Touch grass")
                    .font(.system(size: 40, weight: .semibold, design: .rounded))
                    .tracking(1)
                    .foregroundStyle(Palette.espresso)

                PlantView(growth: growth)
                    .frame(width: 300, height: 360)

                VStack(spacing: 14) {
                    Text(countdown)
                        .font(.system(size: 46, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(Palette.espresso)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(Color.white.opacity(0.42)))
                        .overlay(Capsule().stroke(Color.white.opacity(0.65), lineWidth: 1))
                        .shadow(color: Palette.espresso.opacity(0.10), radius: 14, y: 5)

                    Text("You've earned a pause — look at something far away and breathe.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Palette.espresso.opacity(0.55))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(56)

            GrainOverlay()
                .ignoresSafeArea()
        }
        .onAppear { breathe = true }
    }
}
