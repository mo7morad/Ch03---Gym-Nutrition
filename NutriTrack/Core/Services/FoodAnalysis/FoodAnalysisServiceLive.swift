// FILE: NutriTrack/Core/Services/FoodAnalysis/FoodAnalysisServiceLive.swift

import Foundation
import UIKit

// MARK: - Live Implementation

/// The real implementation of `FoodAnalysisService`.
/// Orchestrates the two-step pipeline:
///   1. Gemini Vision → identify foods + gram weights
///   2. USDA FoodData Central → look up macros scaled by weight
///
/// This type is never imported by Views or ViewModels directly.
/// Inject it via the `FoodAnalysisService` protocol.
final class FoodAnalysisServiceLive: FoodAnalysisService, @unchecked Sendable {

    private let visionClient: GeminiVisionClient
    private let nutritionClient: USDANutritionClient

    init(visionClient: GeminiVisionClient, nutritionClient: USDANutritionClient) {
        self.visionClient = visionClient
        self.nutritionClient = nutritionClient
    }

    func analyze(image: UIImage) async throws -> [NutritionInfo] {
        let identifiedFoods = try await visionClient.identify(image: image)

        guard !identifiedFoods.isEmpty else {
            return []
        }

        let lookupItems = identifiedFoods.map { (name: $0.name, weightGrams: $0.estimatedWeightGrams) }
        return try await nutritionClient.lookup(foods: lookupItems)
    }
}

// MARK: - Factory

extension FoodAnalysisServiceLive {
    /// Convenience factory using placeholder API keys.
    /// Call this once at app startup and inject the result everywhere.
    ///
    /// Usage in NutriTrackApp.swift:
    /// ```swift
    /// let foodService = FoodAnalysisServiceLive.makeDefault()
    /// ```
    static func makeDefault() -> FoodAnalysisServiceLive {
        // TODO: Load from config, never commit real keys to source control
        let geminiAPIKey = "YOUR_GEMINI_API_KEY"
        let usdaAPIKey = "YOUR_USDA_API_KEY"

        return FoodAnalysisServiceLive(
            visionClient: GeminiVisionClient(apiKey: geminiAPIKey),
            nutritionClient: USDANutritionClient(apiKey: usdaAPIKey)
        )
    }
}
