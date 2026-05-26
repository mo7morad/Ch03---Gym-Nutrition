import SwiftUI

struct MealListSectionView: View {
    let food: [FoodItem] = [
        FoodItem(
                    id: UUID(),
                    name: "Breakie",
                    nutrition: NutritionInfo(
                        calories: 100,
                        proteinGrams: 80,
                        carbsGrams: 50,
                        fibreGrams: 100,
                        fatGrams: 10
                    )
                ),
                FoodItem(
                    id: UUID(),
                    name: "Lunch",
                    nutrition: NutritionInfo(
                        calories: 450,
                        proteinGrams: 30,
                        carbsGrams: 60,
                        fibreGrams: 8,
                        fatGrams: 15
                    )
                ),
                FoodItem(
                    id: UUID(),
                    name: "Dinner",
                    nutrition: NutritionInfo(
                        calories: 600,
                        proteinGrams: 40,
                        carbsGrams: 70,
                        fibreGrams: 5,
                        fatGrams: 20
                    )
                )
    ]
    
    var body: some View {
        ScrollView{
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16){
                ForEach(food, id: \.id){ food in
                    MacroSummaryCard(food: food)
                }
            }
            .padding()
        }
    }
}

#Preview {
    MealListSectionView()
}
