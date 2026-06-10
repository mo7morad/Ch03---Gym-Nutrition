// FILE: NutriTrack/Features/MealLogging/Components/FoodItemRow.swift

import SwiftUI

struct FoodItemRow: View {
    let item: FoodItemModel

    private var displayName: String {
        let label = item.nutrition.foodName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !label.isEmpty { return label }
        return item.name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(displayName)
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            AccessibilityLabels.foodItem(
                name: displayName,
                calories: Int(item.nutrition.calories),
                protein: Int(item.nutrition.protein)
            )
        )
    }
}

#Preview {
    FoodItemRow(item: FoodItemModel(
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
