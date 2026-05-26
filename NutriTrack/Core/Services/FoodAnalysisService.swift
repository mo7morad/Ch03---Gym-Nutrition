import UIKit

// The protocol every food analysis implementation must conform to.
// By coding to a protocol, we can swap the mock for the real AI service later
// without changing any of the views or ViewModels that depend on it.
protocol FoodAnalysisService {
    func analyze(image: UIImage) async throws -> [FoodItem]
}
