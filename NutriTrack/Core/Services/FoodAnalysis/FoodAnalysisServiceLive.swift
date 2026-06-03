import Foundation
import UIKit

// MARK: - Live Implementation

/// The real implementation of `FoodAnalysisService`.
/// Orchestrates the two-step pipeline:
///   1. Gemini Vision → identify foods + portion descriptions
///   2. Nutritionix → look up macros for each food
///
/// This type is never imported by Views or ViewModels directly.
/// Inject it via the `FoodAnalysisService` protocol.
final class FoodAnalysisServiceLive: FoodAnalysisService {

    private let visionClient: GeminiVisionClient
    private let nutritionClient: NutritionixClient

    // TODO: Move keys to a secure backend proxy before App Store submission.
    // For now, inject credentials at composition root (NutriTrackApp.swift).
    init(visionClient: GeminiVisionClient, nutritionClient: NutritionixClient) {
        self.visionClient = visionClient
        self.nutritionClient = nutritionClient
    }

    func analyze(image: UIImage) async throws -> [NutritionInfo] {
        // Step 1: Ask Gemini to identify what's in the photo
        let identifiedFoods = try await visionClient.identify(image: image)

        guard !identifiedFoods.isEmpty else {
            // Gemini saw no food — not an error, just nothing to return
            return []
        }

        // Step 2: Ask Nutritionix for macros, using the portion descriptions Gemini gave us
        let foodsForLookup = identifiedFoods.map { food in
            (name: food.name, portionDescription: food.portionDescription)
        }

        let nutritionData = try await nutritionClient.lookup(foods: foodsForLookup)
        return nutritionData
    }
}

// MARK: - Factory

extension FoodAnalysisServiceLive {
    /// Convenience factory using app-level API credentials.
    /// Call this once at app startup and inject the result everywhere.
    ///
    /// Usage in NutriTrackApp.swift:
    /// ```swift
    /// let foodService = FoodAnalysisServiceLive.makeDefault()
    /// ```
    static func makeDefault() -> FoodAnalysisServiceLive {
        // TODO: Load these from a config file or environment before shipping.
        // Never commit real keys to source control.
        let geminiAPIKey = "YOUR_GEMINI_API_KEY"
        let nutritionixAppID = "YOUR_NUTRITIONIX_APP_ID"
        let nutritionixAppKey = "YOUR_NUTRITIONIX_APP_KEY"

        return FoodAnalysisServiceLive(
            visionClient: GeminiVisionClient(apiKey: geminiAPIKey),
            nutritionClient: NutritionixClient(appID: nutritionixAppID, appKey: nutritionixAppKey)
        )
    }
}
