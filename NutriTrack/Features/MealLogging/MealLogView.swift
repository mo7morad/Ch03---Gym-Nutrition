import SwiftUI

// MealLogView is the root of the meal-logging flow.
// It owns the ViewModel and switches between screens based on viewModel.step —
// the same state-machine pattern used in onboarding.
//
// How to use this "lego":
// Present it as a fullScreenCover from any parent view:
//
//   .fullScreenCover(isPresented: $showMealLog) {
//       MealLogView(onComplete: { showMealLog = false },
//                   onCancel:   { showMealLog = false })
//   }
//
// The Dashboard will wire this up when its camera button is added.
struct MealLogView: View {

    let onComplete: () -> Void
    let onCancel: () -> Void

    @State private var viewModel = MealLogViewModel()

    var body: some View {
        Group {
            switch viewModel.step {

            case .capturing:
                PhotoCaptureView(
                    onPhotoCaptured: { image in
                        viewModel.photoTaken(image)
                    },
                    onCancel: onCancel
                )

            case .confirmingPhoto(let image):
                PhotoConfirmationView(
                    image: image,
                    onRetake: { viewModel.retake() },
                    onUsePhoto: {
                        // usePhoto is async — wrap it in Task so we don't block the UI.
                        // This is identical to how SummaryStepView calls viewModel.complete().
                        Task { await viewModel.usePhoto(image) }
                    }
                )

            case .analyzing(let image):
                // Inline loading screen — simple enough to not warrant its own file.
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

            case .result(let items):
                AnalysisResultView(
                    items: items,
                    onLog: {
                        viewModel.logMeal()
                        onComplete()
                    },
                    onRetake: { viewModel.retake() }
                )
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.step.id)
    }
}

// MealLogViewModel.Step needs to be Equatable for the animation value.
// We give each case a stable String id so SwiftUI can detect changes.
extension MealLogViewModel.Step {
    var id: String {
        switch self {
        case .capturing:         return "capturing"
        case .confirmingPhoto:   return "confirmingPhoto"
        case .analyzing:         return "analyzing"
        case .result:            return "result"
        }
    }
}

#Preview {
    // Launch the full flow from a button so you can test it standalone in Simulator.
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
            onCancel: { showMealLog = false }
        )
    }
}
