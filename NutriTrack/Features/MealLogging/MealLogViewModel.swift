import Foundation
import UIKit

// MARK: - ViewModel

@Observable
@MainActor
final class MealLogViewModel {

    enum Step {
        case capturing
        case analyzing(UIImage)
        case result([FoodItem], UIImage)
        case failed(UIImage, Error)
    }

    var step: Step = .capturing
    private(set) var savedPhotoRef: String?

    /// Set after a photo is saved on "Done" and cleared once the meal is committed.
    private(set) var uncommittedPhotoRef: String?

    private let analysisService: any FoodAnalysisService
    private let photoStorage: any MealPhotoStorage

    init(
        analysisService: any FoodAnalysisService,
        photoStorage: any MealPhotoStorage = ImageProcessingService()
    ) {
        self.analysisService = analysisService
        self.photoStorage = photoStorage
    }

    // MARK: - Transitions

    func retake() {
        savedPhotoRef = nil
        step = .capturing
    }

    func usePhoto(_ image: UIImage) {
        step = .analyzing(image)
        savedPhotoRef = try? ImageProcessingService.saveMealPhoto(image)

        Task {
            do {
                let nutritionInfos = try await analysisService.analyze(image: image)
                let foodItems = nutritionInfos.map {
                    FoodItem(id: UUID(), name: $0.foodName, nutrition: $0)
                }
                step = .result(foodItems)
            } catch {
                step = .failed(image, error)
            }
        }
    }

    func makeMealEntry(items: [FoodItem]) -> MealEntry {
        MealEntry(
            id: UUID(),
            timestamp: .now,
            photoRef: savedPhotoRef,
            items: items
        )
    }

    func logMeal(_ meal: MealEntry) {
        // SwiftData persistence can be added here; dashboard receives the meal via onComplete.
        _ = meal
    }
}

// MARK: - Step helpers

extension MealLogViewModel.Step {
    var id: String {
        switch self {
        case .capturing:  return "capturing"
        case .analyzing:  return "analyzing"
        case .result:     return "result"
        case .failed:     return "failed"
        }
    }
}

// MARK: - Errors

enum MealLogError: LocalizedError {
    case noResultToLog

    var errorDescription: String? {
        switch self {
        case .noResultToLog:
            return "There is no analyzed meal to save."
        }
    }
}
