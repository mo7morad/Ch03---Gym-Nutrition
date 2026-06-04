import SwiftUI
import PhotosUI

struct MealLogView: View {

    let onComplete: () -> Void
    let onCancel: () -> Void

    @Environment(\.foodAnalysisService) private var foodAnalysisService
    @State private var viewModel: MealLogViewModel?
    @State private var showCamera = false
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        Group {
            if let viewModel {
                content(for: viewModel)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel?.step.id)
        .task {
            if viewModel == nil {
                viewModel = MealLogViewModel(analysisService: foodAnalysisService)
            }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private func content(for viewModel: MealLogViewModel) -> some View {
        switch viewModel.step {

        case .capturing:
            choiceScreen(viewModel: viewModel)

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

        case .failed(let image, let error):
            failedView(image: image, error: error, viewModel: viewModel)
        }
    }

    // MARK: - Choice Screen

    @ViewBuilder
    private func choiceScreen(viewModel: MealLogViewModel) -> some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 16) {
                        Text("Add Your Meal")
                            .font(.title.weight(.bold))

                        Text("Take a photo or pick one from your library")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 32)

                    VStack(spacing: 16) {
                        Button {
                            showCamera = true
                        } label: {
                            VStack(spacing: 10) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 36))
                                Text("Take Photo")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 28)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)

                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            VStack(spacing: 10) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 36))
                                Text("Choose from Gallery")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 28)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 32)

                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onCancel()
                    } label: {
                        Label("Close", systemImage: "xmark")
                    }
                }
            }
        }
        .onChange(of: selectedItem) { oldValue, newValue in
            guard let item = newValue else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    viewModel.usePhoto(image)
                } else {
                    viewModel.retake()
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            PhotoCaptureView(
                onPhotoCaptured: { image in
                    showCamera = false
                    viewModel.usePhoto(image)
                },
                onCancel: {
                    showCamera = false
                }
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Analyzing

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

    // MARK: - Failed

    @ViewBuilder
    private func failedView(image: UIImage, error: Error, viewModel: MealLogViewModel) -> some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(.ultraThinMaterial)

            VStack(spacing: 16) {
                Text(error.localizedDescription)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Button {
                    viewModel.usePhoto(image)
                } label: {
                    Text("Try Again")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                }
                .background(.ultraThinMaterial, in: Capsule())

                Button {
                    viewModel.retake()
                } label: {
                    Text("Retake Photo")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                }
                .background(.ultraThinMaterial, in: Capsule())
            }
            .padding(32)
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
