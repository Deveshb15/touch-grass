import SwiftUI

/// The full-screen lockout shown on every display during a block.
struct TouchGrassView: View {
    @ObservedObject var clock: BlockClock

    private var progress: Double {
        guard clock.total > 0 else { return 1 }
        return min(1, max(0, 1 - clock.remaining / clock.total))
    }

    private var countdown: String {
        let total = Int(clock.remaining.rounded(.up))
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.04, green: 0.22, blue: 0.10),
                         Color(red: 0.07, green: 0.36, blue: 0.16)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Text("🌱")
                    .font(.system(size: 96))

                Text("Touch grass")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("You've been with the machines long enough.\nStep away. Look at something far away. Breathe.")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)

                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.18), lineWidth: 10)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(.white, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.5), value: progress)
                    Text(countdown)
                        .font(.system(size: 44, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                }
                .frame(width: 180, height: 180)
                .padding(.top, 8)

                Text("Back in \(countdown)")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(60)
        }
    }
}
