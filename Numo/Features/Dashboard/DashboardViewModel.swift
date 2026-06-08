import Foundation

@Observable
@MainActor
final class DashboardViewModel {
    var meals: [MealEntry] = []
    var isPresentingMealLog = false

    var dailyMeals: [MealEntry] {
        meals
            .filter { Calendar.current.isDateInToday($0.timestamp) }
            .sorted { $0.timestamp > $1.timestamp }
    }

    func presentMealLog() {
        isPresentingMealLog = true
    }

    func dismissMealLog() {
        isPresentingMealLog = false
    }

    func addMeal(_ meal: MealEntry) {
        meals.insert(meal, at: 0)
    }
}
