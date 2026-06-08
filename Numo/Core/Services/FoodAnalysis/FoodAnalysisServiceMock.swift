// FILE: NutriTrack/Core/Services/FoodAnalysis/FoodAnalysisServiceMock.swift

import Foundation
import UIKit

// MARK: - Mock Implementation

/// Fake implementation of `FoodAnalysisService` for:
///   - SwiftUI Previews
///   - Unit tests
///   - Teammates who haven't set up API keys yet
///
/// Returns realistic but hardcoded data. Simulates network delay.
final class FoodAnalysisServiceMock: FoodAnalysisService, @unchecked Sendable {

    /// If set, the mock throws this error instead of returning data.
    /// Useful for testing error states in your UI.
    var forcedError: Error? = nil

    /// Delay in seconds to simulate real network latency.
    var simulatedDelay: TimeInterval = 1.5

    func analyze(image: UIImage) async throws -> MealAnalysisResult {
        try await Task.sleep(for: .seconds(simulatedDelay))

        if let error = forcedError {
            throw error
        }

        return Self.sampleMeals.randomElement() ?? Self.chickenAndRiceMeal
    }

    // MARK: - Sample Data

    private static let chickenAndRiceMeal = MealAnalysisResult(
        mealName: "Grilled Chicken and Brown Rice",
        items: [
            NutritionInfo(
                foodName: "Grilled Chicken Breast",
                calories: 331.2,
                protein: 62.0,
                carbs: 0.0,
                fat: 7.1,
                fiber: 0.0,
                servingSize: "200g"
            ),
            NutritionInfo(
                foodName: "Brown Rice",
                calories: 221.4,
                protein: 4.9,
                carbs: 46.1,
                fat: 1.8,
                fiber: 2.9,
                servingSize: "180g"
            )
        ]
    )

    private static let salmonSaladMeal = MealAnalysisResult(
        mealName: "Salmon Salad Bowl",
        items: [
            NutritionInfo(
                foodName: "Salmon Fillet",
                calories: 312.0,
                protein: 33.6,
                carbs: 0.0,
                fat: 18.3,
                fiber: 0.0,
                servingSize: "150g"
            ),
            NutritionInfo(
                foodName: "Mixed Greens Salad",
                calories: 20.7,
                protein: 1.6,
                carbs: 3.2,
                fat: 0.3,
                fiber: 1.8,
                servingSize: "90g"
            ),
            NutritionInfo(
                foodName: "Olive Oil Dressing",
                calories: 132.6,
                protein: 0.0,
                carbs: 0.0,
                fat: 15.0,
                fiber: 0.0,
                servingSize: "15g"
            )
        ]
    )

    private static let scrambledEggsMeal = MealAnalysisResult(
        mealName: "Scrambled Eggs and Toast",
        items: [
            NutritionInfo(
                foodName: "Scrambled Eggs",
                calories: 178.8,
                protein: 13.2,
                carbs: 1.9,
                fat: 13.2,
                fiber: 0.0,
                servingSize: "120g"
            ),
            NutritionInfo(
                foodName: "Whole Wheat Toast",
                calories: 158.4,
                protein: 7.1,
                carbs: 28.7,
                fat: 2.1,
                fiber: 4.2,
                servingSize: "60g"
            )
        ]
    )

    private static let sampleMeals: [MealAnalysisResult] = [
        chickenAndRiceMeal,
        salmonSaladMeal,
        scrambledEggsMeal
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
