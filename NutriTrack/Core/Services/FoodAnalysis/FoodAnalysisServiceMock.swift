import Foundation
import UIKit

// MARK: - Mock Implementation

/// Fake implementation of `FoodAnalysisService` for:
///   - SwiftUI Previews
///   - Unit tests
///   - Teammates who haven't set up API keys yet
///
/// Returns realistic but hardcoded data. Simulates network delay.
final class FoodAnalysisServiceMock: FoodAnalysisService {

    /// If set, the mock throws this error instead of returning data.
    /// Useful for testing error states in your UI.
    var forcedError: Error? = nil

    /// Delay in seconds to simulate real network latency.
    var simulatedDelay: TimeInterval = 1.5

    func analyze(image: UIImage) async throws -> [NutritionInfo] {
        // Simulate network latency
        try await Task.sleep(for: .seconds(simulatedDelay))

        // Support forced error for testing error UI
        if let error = forcedError {
            throw error
        }

        return Self.sampleMeals.randomElement() ?? Self.chickenAndRice
    }

    // MARK: - Sample Data

    private static let chickenAndRice: [NutritionInfo] = [
        NutritionInfo(
            foodName: "Grilled Chicken Breast",
            calories: 231,
            protein: 43.4,
            carbs: 0,
            fat: 5.0,
            fiber: 0.0,
            servingSize: "174g"
        ),
        NutritionInfo(
            foodName: "Brown Rice (cooked)",
            calories: 216,
            protein: 5.0,
            carbs: 44.8,
            fat: 1.8,
            fiber: 3.5,
            servingSize: "195g (1 cup)"
        )
    ]

    private static let salad: [NutritionInfo] = [
        NutritionInfo(
            foodName: "Mixed Greens Salad",
            calories: 15,
            protein: 1.5,
            carbs: 2.5,
            fat: 0.2,
            fiber: 1.2,
            servingSize: "85g (2 cups)"
        ),
        NutritionInfo(
            foodName: "Grilled Salmon",
            calories: 233,
            protein: 32.0,
            carbs: 0,
            fat: 11.2,
            fiber: 0.0,
            servingSize: "140g"
        ),
        NutritionInfo(
            foodName: "Olive Oil Dressing",
            calories: 120,
            protein: 0,
            carbs: 0,
            fat: 14.0,
            fiber: 0.0,
            servingSize: "1 tbsp"
        )
    ]

    private static let breakfast: [NutritionInfo] = [
        NutritionInfo(
            foodName: "Scrambled Eggs",
            calories: 182,
            protein: 12.4,
            carbs: 1.6,
            fat: 14.0,
            fiber: 0.0,
            servingSize: "2 large eggs"
        ),
        NutritionInfo(
            foodName: "Whole Wheat Toast",
            calories: 128,
            protein: 6.0,
            carbs: 24.0,
            fat: 2.0,
            fiber: 3.0,
            servingSize: "2 slices"
        )
    ]

    private static let sampleMeals: [[NutritionInfo]] = [
        chickenAndRice,
        salad,
        breakfast
    ]
}

// MARK: - Preview Helpers

extension FoodAnalysisServiceMock {
    /// Returns an error-throwing mock. Use in previews to test error states.
    static var alwaysFailing: FoodAnalysisServiceMock {
        let mock = FoodAnalysisServiceMock()
        mock.forcedError = FoodAnalysisError.noFoodDetected
        return mock
    }

    /// Returns a fast mock (no delay). Use in unit tests.
    static var instant: FoodAnalysisServiceMock {
        let mock = FoodAnalysisServiceMock()
        mock.simulatedDelay = 0
        return mock
    }
}

// MARK: - Domain Errors

enum FoodAnalysisError: LocalizedError {
    case noFoodDetected
    case analysisUnavailable

    var errorDescription: String? {
        switch self {
        case .noFoodDetected:
            return "No food detected in the photo. Try a clearer shot."
        case .analysisUnavailable:
            return "Food analysis is temporarily unavailable."
        }
    }
}
