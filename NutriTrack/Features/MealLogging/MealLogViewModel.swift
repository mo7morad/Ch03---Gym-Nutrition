import Foundation
import UIKit

// MARK: - ViewModel

@Observable
@MainActor
final class MealLogViewModel {

    enum Step {
        case capturing
        case analyzing(UIImage)
        case result([FoodItem])
        case failed(UIImage, Error)
    }

    var step: Step = .capturing

    private let analysisService: any FoodAnalysisService

    init(analysisService: any FoodAnalysisService) {
        self.analysisService = analysisService
    }

    // MARK: - Transitions

    func retake() {
        step = .capturing
    }

    func usePhoto(_ image: UIImage) {
        step = .analyzing(image)

        Task {
            do {
                let nutritionInfos = try await analysisService.analyze(image: image)
                let foodItems = nutritionInfos.map { FoodItem(id: UUID(), name: $0.foodName, nutrition: $0) }
                step = .result(foodItems)
            } catch {
                step = .failed(image, error)
            }
        }
    }

    func logMeal() {
        // intentionally empty until SwiftData wiring is added
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
