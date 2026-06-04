import SwiftUI

/// Mascot peeking in from the bottom-left with a speech-style confirmation message.
struct MealLoggedConfirmationView: View {
    private let mascotAspectRatio: CGFloat = 319 / 192
    private let mascotRotation: Double = 13
    private let mascotWidth: CGFloat = 220

    /// Space to reserve above the home indicator so scroll content clears the mascot.
    static let scrollBottomInset: CGFloat = 112

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            mascot

            messageCluster
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .clipped()
        .allowsHitTesting(false)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Your meal is logged!")
    }

    private var mascot: some View {
        Image("MealLoggedMascot")
            .resizable()
            .scaledToFit()
            .frame(width: mascotWidth, height: mascotWidth / mascotAspectRatio)
            .rotationEffect(.degrees(mascotRotation))
            .offset(x: -56, y: 80)
    }

    private var messageCluster: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Your meal is logged!")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(hex: "181818"))

            MealLoggedSpeechConnector()
                .stroke(Color(hex: "181818"), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                .frame(width: 88, height: 44)
                .offset(x: -8, y: -4)
        }
        .padding(.leading, 148)
        .padding(.bottom, 108)
    }
}

private struct MealLoggedSpeechConnector: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX * 0.7, y: rect.minY + 6))
        path.addCurve(
            to: CGPoint(x: rect.minX + 4, y: rect.maxY - 2),
            control1: CGPoint(x: rect.maxX * 0.4, y: rect.minY + 24),
            control2: CGPoint(x: rect.minX + 20, y: rect.maxY * 0.5)
        )
        return path
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        Color(hex: "F3F3F3").ignoresSafeArea()
        MealLoggedConfirmationView()
    }
}
