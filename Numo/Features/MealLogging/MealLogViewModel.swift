import Foundation
import UIKit

// MARK: - ViewModel

@Observable
@MainActor
final class MealLogViewModel {

    enum Step {
        case capturing
        case analyzing(UIImage)
        case result(mealName: String, items: [FoodItemModel])
        case failed(UIImage, Error)
    }

    var step: Step = .capturing
    private(set) var savedPhotoRef: String?

    private let analysisService: any FoodAnalysisService

    init(analysisService: any FoodAnalysisService) {
        self.analysisService = analysisService
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
                let analysisResult = try await analysisService.analyze(image: image)
                let foodItems = analysisResult.items.map {
                    FoodItemModel(id: UUID(), name: $0.foodName, nutrition: $0)
                }
                step = .result(mealName: analysisResult.mealName, items: foodItems)
            } catch {
                step = .failed(image, error)
            }
        }
    }

    func makeMealEntry(mealName: String, items: [FoodItemModel]) -> MealEntry {
        let trimmed = mealName.trimmingCharacters(in: .whitespacesAndNewlines)
        return MealEntry(
            id: UUID(),
            timestamp: .now,
            photoRef: savedPhotoRef,
            mealName: trimmed.isEmpty ? nil : trimmed,
            items: items
        )
    }

    func logMeal(_ meal: MealEntry) {
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
