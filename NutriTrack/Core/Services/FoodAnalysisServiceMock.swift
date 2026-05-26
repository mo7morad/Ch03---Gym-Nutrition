import UIKit

// Active implementation used while the real AI service is not built yet.
// It ignores the image entirely and always returns the same two food items
// after a simulated 1.5-second network delay.
struct FoodAnalysisServiceMock: FoodAnalysisService {
    func analyze(image: UIImage) async throws -> [FoodItem] {
        try await Task.sleep(for: .seconds(1.5))
        return [
            FoodItem(
                id: UUID(),
                name: "Grilled Chicken",
                nutrition: NutritionInfo(calories: 320, proteinGrams: 42, carbsGrams: 0, fibreGrams: 0, fatGrams: 14)
            ),
            FoodItem(
                id: UUID(),
                name: "Brown Rice",
                nutrition: NutritionInfo(calories: 215, proteinGrams: 5, carbsGrams: 45, fibreGrams: 2, fatGrams: 2)
            )
        ]
    }
}
