import Foundation
import UIKit

// MealLogViewModel drives the meal-logging flow as a state machine.
// Each case in Step represents one screen the user sees.
//
// Why a state machine?
// Illegal UI states become impossible — you can't reach "result" without
// going through "capturing" first. The compiler enforces the flow.
@Observable
@MainActor
final class MealLogViewModel {

    enum Step {
        case capturing
        case analyzing(UIImage)
        case result([FoodItem])
    }

    var step: Step = .capturing

    private let analysisService: any FoodAnalysisService = FoodAnalysisServiceMock()

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
                // On error, return to camera so the user can try again.
                step = .capturing
            }
        }
    }

    // Persistence is deferred — MealEntry will be saved to SwiftData
    // when this flow is wired into the dashboard.
    func logMeal() {
        // intentionally empty until SwiftData wiring is added
    }
}

// MARK: - Step helpers

extension MealLogViewModel.Step {
    // Stable id for SwiftUI animation value tracking.
    var id: String {
        switch self {
        case .capturing:  return "capturing"
        case .analyzing:  return "analyzing"
        case .result:     return "result"
        }
    }
}
