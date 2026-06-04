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
        .padding(.bottom, 30)
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
    
    MealListSectionView(dailyMeals: [mockMeal1, mockMeal2])
}
