import SwiftUI

// MealLogView is the root of the meal-logging flow.
// It owns the ViewModel and switches between screens based on viewModel.step.
//
// Present it as a fullScreenCover from any parent:
//
//   .fullScreenCover(isPresented: $showMealLog) {
//       MealLogView(
//           onComplete: { showMealLog = false },
//           onCancel:   { showMealLog = false }
//       )
//   }
struct MealLogView: View {

    let onComplete: () -> Void
    let onCancel: () -> Void

    @State private var viewModel = MealLogViewModel()

    var body: some View {
        Group {
            switch viewModel.step {

            case .capturing:
                PhotoCaptureView(
                    onPhotoCaptured: { image in viewModel.usePhoto(image) },
                    onCancel: onCancel
                )
                .ignoresSafeArea()

            case .analyzing(let image):
                analyzingView(image: image)

            case .result(let items):
                AnalysisResultView(
                    items: items,
                    onLog: {
                        viewModel.logMeal()
                        onComplete()
                    },
                    onRetake: {
                        viewModel.retake()
                    }
                )
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.step.id)
    }

    // MARK: - Analyzing overlay

    // Inline because it's tightly coupled to this flow and too small for its own file.
    @ViewBuilder
    private func analyzingView(image: UIImage) -> some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(.ultraThinMaterial)

            VStack(spacing: 16) {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)
                Text("Analyzing your meal…")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var showMealLog = false

    Button {
        showMealLog = true
    } label: {
        Label("Open Camera", systemImage: "camera.fill")
            .font(.headline)
            .padding()
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }
    .fullScreenCover(isPresented: $showMealLog) {
        MealLogView(
            onComplete: { showMealLog = false },
            onCancel:   { showMealLog = false }
        )
    }
}
