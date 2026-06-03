import SwiftUI

// One row in the detected-foods list.
// Receives a FoodItem value — no logic, just display.
struct FoodItemRow: View {
    let item: FoodItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
                .font(.headline)

            HStack(spacing: 12) {
                Label("\(Int(item.nutrition.calories)) kcal", systemImage: "flame.fill")
                    .foregroundStyle(.orange)
                Label("\(Int(item.nutrition.proteinGrams))g protein", systemImage: "p.circle.fill")
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
        nutrition: NutritionInfo(calories: 320, proteinGrams: 42, carbsGrams: 0, fibreGrams: 0, fatGrams: 14)
    ))
    .padding()
}
