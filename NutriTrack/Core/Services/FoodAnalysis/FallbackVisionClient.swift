// FILE: NutriTrack/Core/Services/FoodAnalysis/FallbackVisionClient.swift

import UIKit

/// Tries a primary vision provider, then an optional fallback on any failure.
struct FallbackVisionClient: FoodVisionIdentifying, Sendable {
    private let primary: any FoodVisionIdentifying
    private let fallback: (any FoodVisionIdentifying)?

    init(primary: any FoodVisionIdentifying, fallback: (any FoodVisionIdentifying)?) {
        self.primary = primary
        self.fallback = fallback
    }

    func identify(image: UIImage) async throws -> [IdentifiedFood] {
        do {
            return try await primary.identify(image: image)
        } catch {
            guard let fallback else { throw error }
            return try await fallback.identify(image: image)
        }
    }
}
