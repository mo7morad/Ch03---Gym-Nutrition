import SwiftUI

// PhotoConfirmationView shows the photo the user just took so they can decide
// whether it's good enough to analyze, or retake it.
//
// Note: this file is not in the original CLAUDE.md spec — it was added to give
// the confirmation step its own dedicated view (one type per file rule).
struct PhotoConfirmationView: View {
    let image: UIImage
    let onRetake: () -> Void
    let onUsePhoto: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            // Full-bleed photo fills the screen just like the native camera app.
            Color.black.ignoresSafeArea()

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Action bar at the bottom — matches the iOS camera's Retake / Use Photo pattern.
            HStack(spacing: 0) {
                Button(action: onRetake) {
                    Text("Retake")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                }

                Divider()
                    .frame(height: 24)
                    .background(.white.opacity(0.4))

                Button(action: onUsePhoto) {
                    Text("Use Photo")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                }
            }
            .background(.ultraThinMaterial)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
