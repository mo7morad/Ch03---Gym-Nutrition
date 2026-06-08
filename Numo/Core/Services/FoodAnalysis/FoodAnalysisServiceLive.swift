// FILE: NutriTrack/Core/Services/FoodAnalysis/FoodAnalysisServiceLive.swift

import Foundation
import UIKit

// MARK: - Live Implementation

final class FoodAnalysisServiceLive: FoodAnalysisService, @unchecked Sendable {

    private let client: AnthropicMealAnalysisClient

    init(client: AnthropicMealAnalysisClient) {
        self.client = client
    }

    func analyze(image: UIImage) async throws -> MealAnalysisResult {
        try await client.analyze(image: image)
    }
}

// MARK: - Factory

extension FoodAnalysisServiceLive {
    static func makeDefault() -> FoodAnalysisServiceLive {
        let apiKey = SecretLoader.load("ANTHROPIC_API_KEY", placeholder: "YOUR_ANTHROPIC_API_KEY")
        return FoodAnalysisServiceLive(
            client: AnthropicMealAnalysisClient(apiKey: apiKey)
        )
    }
}
