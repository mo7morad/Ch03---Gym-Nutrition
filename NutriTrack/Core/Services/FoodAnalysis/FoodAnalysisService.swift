import Foundation
import UIKit

// MARK: - Protocol

/// Contract for food photo analysis.
/// Both the real implementation and the mock conform to this.
/// ViewModels depend on this protocol, never on a concrete type.
protocol FoodAnalysisService {
    /// Analyzes a photo and returns nutrition info for each identified food item.
    /// - Parameter image: The photo captured by the user.
    /// - Returns: Array of `NutritionInfo`, one per identified food item.
    /// - Throws: Any error from the underlying vision or nutrition API.
    func analyze(image: UIImage) async throws -> [NutritionInfo]
}
