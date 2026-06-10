import SwiftUI

struct MealLoggedConfirmationView: View {
    private let mascotAspectRatio: CGFloat = 319.0 / 192.0
    private let mascotRotation: Double = 13
    private let mascotWidth: CGFloat = 300

    static let scrollBottomInset: CGFloat = 168

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            mascot
            messageCluster
        }
        .frame(maxWidth: .infinity)
        .frame(height: Self.scrollBottomInset, alignment: .bottomLeading)
        .allowsHitTesting(false)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(AccessibilityLabels.mealLoggedConfirmation)
    }

    private var mascot: some View {
        Image("MealLoggedMascot")
            .resizable()
            .scaledToFit()
            .frame(width: mascotWidth, height: mascotWidth / mascotAspectRatio)
            .rotationEffect(.degrees(mascotRotation))
            .offset(x: -32, y: 52)
            .accessibilityHidden(true)
    }

    private var messageCluster: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Your meal is logged!")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(hex: "181818"))

            MealLoggedSpeechConnector()
                .stroke(Color(hex: "181818"), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                .frame(width: 104, height: 52)
                .offset(x: -12, y: 0)
        }
        .padding(.leading, 192)
        .padding(.bottom, 62)
    }
}

private struct MealLoggedSpeechConnector: Shape {
    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + 8, y: rect.minY + 6))
        path.addCurve(
            to: CGPoint(x: rect.maxX - 6, y: rect.maxY - 4),
            control1: CGPoint(x: rect.minX + 36, y: rect.midY - 8),
            control2: CGPoint(x: rect.maxX * 0.55, y: rect.maxY - 16)
        )
        return path
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        Color(hex: "F3F3F3").ignoresSafeArea()
        MealLoggedConfirmationView()
            .ignoresSafeArea(edges: .bottom)
    }
}
