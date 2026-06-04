// FILE: NutriTrack/Core/Services/FoodAnalysis/FoodAnalysisService.swift

import Foundation
import SwiftUI
import UIKit

// MARK: - Protocol

/// Contract for food photo analysis.
/// ViewModels depend on this protocol, never on a concrete type.
protocol FoodAnalysisService {
    /// Analyzes a photo and returns nutrition info for each identified food item.
    /// - Parameter image: The photo captured by the user.
    /// - Returns: Array of `NutritionInfo`, one per identified food item.
    /// - Throws: Any error from the underlying vision or nutrition API.
    func analyze(image: UIImage) async throws -> [NutritionInfo]
}

// MARK: - SwiftUI Environment Wiring

struct FoodAnalysisServiceKey: EnvironmentKey {
    static let defaultValue: any FoodAnalysisService = FoodAnalysisServiceMock()
}

extension EnvironmentValues {
    var foodAnalysisService: any FoodAnalysisService {
        get { self[FoodAnalysisServiceKey.self] }
        set { self[FoodAnalysisServiceKey.self] = newValue }
    }
}
