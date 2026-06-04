import SwiftUI

struct MealListSectionView: View {
    let dailyMeals: [MealEntry]

    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(dailyMeals) { meal in
                NavigationLink(value: meal.id) {
                    MacroSummaryCard(meal: meal)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .padding(.bottom, 30)
        .navigationDestination(for: UUID.self) { mealID in
            if let meal = dailyMeals.first(where: { $0.id == mealID }) {
                PhotoResultSummary(meal: meal, context: .loggedMeal)
            }
        }
    }
}

#Preview {
    let mockItem1 = FoodItem(id: UUID(), name: "Fried Rice", nutrition: NutritionInfo(foodName: "Fried Rice", calories: 350, protein: 10, carbs: 45, fat: 12, fiber: 3, servingSize: "300g"))
    let mockItem2 = FoodItem(id: UUID(), name: "Boiled Egg", nutrition: NutritionInfo(foodName: "Boiled Egg", calories: 70, protein: 6, carbs: 0, fat: 5, fiber: 0, servingSize: "50g"))
    
    let mockMeal1 = MealEntry(
        id: UUID(),
        timestamp: Date(),
        photoRef: nil,
        items: [mockItem1, mockItem2]
    )
    let mockMeal2 = MealEntry(
        id: UUID(),
        timestamp: Date().addingTimeInterval(14400),
        photoRef: nil,
        items: [mockItem1]
    )
    
    NavigationStack {
        MealListSectionView(dailyMeals: [mockMeal1, mockMeal2])
    }
}
