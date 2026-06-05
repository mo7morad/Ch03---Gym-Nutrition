import SwiftUI

/// Mascot image peeking in from the bottom-left corner with a speech-style confirmation message.
struct MealLoggedConfirmationView: View {
    /// Space so scroll content clears the visible part of the mascot footer.
    static let scrollBottomInset: CGFloat = 152

    private let mascotWidth: CGFloat = 360
    /// Shifts the image off the leading and bottom edges so it looks like it pops out of the corner.
    private let mascotPeekOffset = CGSize(width: -96, height: 72)

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("MealLoggedMascot")
                .resizable()
                .scaledToFit()
                .frame(width: mascotWidth)
                .offset(mascotPeekOffset)
                .accessibilityDecorative()

            messageCluster
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .allowsHitTesting(false)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Your meal is logged!")
    }

    private var messageCluster: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Your meal is logged!")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(hex: "181818"))

            MealLoggedSpeechConnector()
                .stroke(Color(hex: "181818"), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                .frame(width: 104, height: 52)
                .offset(x: -12, y: 0)
        }
        .padding(.leading, 176)
        .padding(.bottom, 96)
    }
}

private struct MealLoggedSpeechConnector: Shape {
    func path(in rect: CGRect) -> Path {
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
    ZStack(alignment: .bottomLeading) {
        Color(hex: "F3F3F3").ignoresSafeArea()
        MealLoggedConfirmationView()
            .ignoresSafeArea(edges: [.bottom, .leading])
    }
    .clipped()
}
