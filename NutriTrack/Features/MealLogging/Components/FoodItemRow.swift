// FILE: NutriTrack/Features/MealLogging/Components/FoodItemRow.swift

import SwiftUI

struct FoodItemRow: View {
    let item: FoodItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
                .font(.headline)

            HStack(spacing: 12) {
                Label("\(Int(item.nutrition.calories)) kcal", systemImage: "flame.fill")
                    .foregroundStyle(.orange)
                Label("\(Int(item.nutrition.protein))g protein", systemImage: "p.circle.fill")
                    .foregroundStyle(.blue)
            }
            .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    FoodItemRow(item: FoodItem(
        id: UUID(),
        name: "Grilled Chicken",
        nutrition: NutritionInfo(
            foodName: "Grilled Chicken",
            calories: 320,
            protein: 42,
            carbs: 0,
            fat: 14,
            fiber: 0,
            servingSize: "200g"
        )
    ))
    .padding()
}
