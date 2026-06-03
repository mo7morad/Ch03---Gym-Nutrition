import Foundation
import UIKit

// MARK: - Models and Protocols

/// Represents the nutritional content of a single food item.
/// Returned by `FoodAnalysisService` and used throughout the app.
/// This is a value type — no SwiftData, no @Model.
struct NutritionInfo: Equatable, Hashable, Codable, Sendable {
    let foodName: String

    /// Kilocalories per serving
    let calories: Double

    /// Grams of protein per serving
    let protein: Double

    /// Grams of total carbohydrates per serving
    let carbs: Double

    /// Grams of total fat per serving
    let fat: Double
    
    /// Grams of dietary fiber per serving
    let fiber: Double

    /// Human-readable serving size, e.g. "174g" or "1 cup (195g)"
    let servingSize: String
}

// MARK: - Computed Helpers

extension NutritionInfo {
    /// Total macronutrient grams (protein + carbs + fat)
    var totalMacroGrams: Double {
        protein + carbs + fat
    }

    /// Returns zero-safe macro percentages as fractions (0.0 to 1.0)
    var proteinFraction: Double {
        totalMacroGrams > 0 ? protein / totalMacroGrams : 0
    }

    var carbsFraction: Double {
        totalMacroGrams > 0 ? carbs / totalMacroGrams : 0
    }

    var fatFraction: Double {
        totalMacroGrams > 0 ? fat / totalMacroGrams : 0
    }
}

