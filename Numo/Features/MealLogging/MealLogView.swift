import SwiftUI
import PhotosUI

struct MealLogView: View {

    let onComplete: (MealEntry) -> Void
    let onCancel: () -> Void
    var startsWithCamera: Bool = false
    var startsWithGallery: Bool = false

    @Environment(\.foodAnalysisService) private var foodAnalysisService
    @State private var viewModel: MealLogViewModel?
    @State private var showCamera = false
    @State private var showGalleryPicker = false
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
            if startsWithCamera {
                cameraCaptureScreen(viewModel: viewModel)
            } else if startsWithGallery {
                galleryPickScreen(viewModel: viewModel)
            } else {
                choiceScreen(viewModel: viewModel)
            }

        case .analyzing(let image):
            analyzingView(image: image)

        case .result(let mealName, let items):
            NavigationStack {
                PhotoResultSummary(
                    meal: viewModel.makeMealEntry(mealName: mealName, items: items),
                    context: .newMeal,
                    onDone: {
                        let meal = viewModel.makeMealEntry(mealName: mealName, items: items)
                        viewModel.logMeal(meal)
                        onComplete(meal)
                    },
                    onDismiss: {
                        viewModel.retake()
                        onCancel()
                    }
                )
            }

        case .failed(let image, let error):
            failedView(image: image, error: error, viewModel: viewModel)
        }
    }

    // MARK: - Camera-only capture (dashboard entry)

    @ViewBuilder
    private func cameraCaptureScreen(viewModel: MealLogViewModel) -> some View {
        PhotoCaptureView(
            onPhotoCaptured: { image in
                viewModel.usePhoto(image)
            },
            onCancel: onCancel
        )
        .ignoresSafeArea()
    }

    // MARK: - Gallery-only entry (dashboard "Choose Photo")

    @ViewBuilder
    private func galleryPickScreen(viewModel: MealLogViewModel) -> some View {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
            .photosPicker(isPresented: $showGalleryPicker, selection: $selectedItem, matching: .images)
            .onAppear {
                showGalleryPicker = true
            }
            .onChange(of: showGalleryPicker) { _, isPresented in
                guard !isPresented, selectedItem == nil else { return }
                onCancel()
            }
            .onChange(of: selectedItem) { _, newValue in
                handleSelectedPhoto(newValue, viewModel: viewModel)
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
                            .accessibilityAddTraits(.isHeader)

                        Text("Take a photo or pick one from your library")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .multilineTextAlignment(.center)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(
                        "\(AccessibilityLabels.MealLog.addYourMeal). \(AccessibilityLabels.MealLog.addYourMealSubtitle)"
                    )
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
                        .accessibilityLabel(AccessibilityLabels.MealLog.takePhoto)
                        .accessibilityHint(AccessibilityLabels.MealLog.takePhotoHint())

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
                        .accessibilityLabel(AccessibilityLabels.MealLog.chooseFromGallery)
                        .accessibilityHint(AccessibilityLabels.MealLog.chooseFromGalleryHint())
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
                    .accessibilityLabel(AccessibilityLabels.close)
                }
            }
        }
        .onChange(of: selectedItem) { _, newValue in
            handleSelectedPhoto(newValue, viewModel: viewModel)
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

    private func handleSelectedPhoto(_ item: PhotosPickerItem?, viewModel: MealLogViewModel) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedItem = nil
                viewModel.usePhoto(image)
            } else {
                selectedItem = nil
                viewModel.retake()
            }
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
                .accessibilityHidden(true)

            VStack(spacing: 16) {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)
                Text("Analyzing your meal…")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(AccessibilityLabels.MealLog.analyzing)
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
                .accessibilityHidden(true)

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
                .accessibilityLabel(AccessibilityLabels.MealLog.tryAgain)
                .accessibilityHint(AccessibilityLabels.MealLog.tryAgainHint())

                Button {
                    viewModel.retake()
                } label: {
                    Text("Retake Photo")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                }
                .background(.ultraThinMaterial, in: Capsule())
                .accessibilityLabel(AccessibilityLabels.MealLog.retakePhoto)
                .accessibilityHint(AccessibilityLabels.MealLog.retakePhotoHint())
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
            onComplete: { _ in showMealLog = false },
            onCancel: { showMealLog = false }
        )
    }
}
