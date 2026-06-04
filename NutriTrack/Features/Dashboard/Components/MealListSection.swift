import SwiftUI

struct MealListSectionView: View {
    let dailyMeals: [MealEntry]
    
    var body : some View{
        NavigationStack{
                
                LazyVStack (spacing: 16){
                    ForEach(dailyMeals) { meal in
                        MacroSummaryCard(meal: meal)
                    }
                }
                .padding(.vertical)
        }
    }
}

#Preview {
    let mockItem1 = FoodItem(
        id: UUID(),
        name: "Fried Rice",
        nutrition: NutritionInfo(calories: 350, proteinGrams: 10, carbsGrams: 45, fibreGrams: 3, fatGrams: 12)
    )
    let mockItem2 = FoodItem(
        id: UUID(),
        name: "Boiled Egg",
        nutrition: NutritionInfo(calories: 70, proteinGrams: 6, carbsGrams: 0, fibreGrams: 0, fatGrams: 5)
    )
    
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
    
    return MealListSectionView(dailyMeals: [mockMeal1, mockMeal2])
}
