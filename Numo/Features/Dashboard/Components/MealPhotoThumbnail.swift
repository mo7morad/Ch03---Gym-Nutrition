import SwiftUI

struct MealPhotoThumbnail: View {
    let photoRef: String?
    var size: CGFloat = 72

    var body: some View {
        Group {
            if let photoRef,
               let image = ImageProcessingService.loadMealPhoto(from: photoRef) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Color(.systemGray5)
                    Image(systemName: "fork.knife")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityLabel(photoRef == nil ? "Meal placeholder" : "Meal photo")
    }
}

#Preview {
    MealPhotoThumbnail(photoRef: nil)
        .padding()
}
