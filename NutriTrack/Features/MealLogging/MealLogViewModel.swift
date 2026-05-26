import Foundation
import UIKit

// MealLogViewModel drives the meal-logging flow as a state machine.
// Each case in Step represents one screen the user sees.
//
// Why a state machine here (same as onboarding)?
// It makes illegal UI states impossible — you can't be in "result" without going
// through "capturing" first. The compiler enforces the flow.
@Observable
@MainActor
final class MealLogViewModel {

    enum Step {
        case capturing                 // camera is open
        case confirmingPhoto(UIImage)  // user reviews the shot before committing
        case analyzing(UIImage)        // waiting for mock/AI to respond
        case result([FoodItem])        // food items detected, ready to log
    }

    var step: Step = .capturing

    // Set to true when the user taps "Log Meal". MealLogView's parent observes
    // this to dismiss the sheet (same pattern as onboarding's isComplete).
    var isComplete: Bool = false

    // Using protocol type so we can swap mock → live without changing this class.
    private let analysisService: any FoodAnalysisService = FoodAnalysisServiceMock()

    // MARK: - Navigation

    func photoTaken(_ image: UIImage) {
        step = .confirmingPhoto(image)
    }

    func retake() {
        step = .capturing
    }

    func usePhoto(_ image: UIImage) async {
        step = .analyzing(image)
        do {
            let items = try await analysisService.analyze(image: image)
            step = .result(items)
        } catch {
            // On error, send the user back to the camera so they can try again.
            step = .capturing
        }
    }

    // Persistence is deferred — MealEntry will be saved to SwiftData
    // when this flow is wired into the dashboard.
    func logMeal() {
        isComplete = true
    }
}
