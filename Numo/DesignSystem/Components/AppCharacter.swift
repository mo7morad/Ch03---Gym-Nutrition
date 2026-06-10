import SwiftUI

// AppCharacter renders the app mascot from Assets.xcassets.
// Pass a width and the height is derived automatically from the SVG's native aspect ratio.
struct AppCharacter: View {

    var width: CGFloat = 240

    // Native SVG dimensions: 243.619 × 146.712 → aspect ratio ≈ 1.66 : 1 (wide)
    private let aspectRatio: CGFloat = 243.619 / 146.712

    var body: some View {
        Image("AppCharacter")
            .resizable()
            .scaledToFit()
            .frame(width: width, height: width / aspectRatio)
            .accessibilityLabel(AccessibilityLabels.appMascot)
    }
}

#Preview {
    AppCharacter(width: 300)
        .padding()
}
