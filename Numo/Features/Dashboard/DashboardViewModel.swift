import Foundation
import SwiftData

@Observable
@MainActor
final class DashboardViewModel {
    private(set) var currentDate = Date()

    func refreshCurrentDate() {
        currentDate = .now
    }

    func dailyMeals(from persistedMeals: [LoggedMeal]) -> [MealEntry] {
        persistedMeals
            .map(\.mealEntry)
            .meals(on: currentDate)
            .sorted { $0.timestamp > $1.timestamp }
    }

    func saveMeal(_ meal: MealEntry, context: ModelContext) {
        context.insert(LoggedMeal.make(from: meal))
        do {
            try context.save()
        } catch {
            print("Failed to save meal: \(error)")
        }
    }
}
