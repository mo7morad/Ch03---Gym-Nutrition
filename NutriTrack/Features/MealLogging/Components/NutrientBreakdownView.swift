// FILE: NutriTrack/Features/MealLogging/Components/NutrientBreakdownView.swift

import SwiftUI

struct NutrientBreakdownView: View {
    let nutrition: NutritionInfo

    var body: some View {
        VStack(spacing: 14) {
            NutrientLine(label: "Calories", value: "\(Int(nutrition.calories)) kcal", color: .orange)
            NutrientLine(label: "Protein",  value: "\(Int(nutrition.protein))g",  color: .blue)
            NutrientLine(label: "Carbs",    value: "\(Int(nutrition.carbs))g",    color: .green)
            NutrientLine(label: "Fat",      value: "\(Int(nutrition.fat))g",      color: .yellow)
            NutrientLine(label: "Fiber",    value: "\(Int(nutrition.fiber))g",    color: .brown)
        }
    }
}

private struct NutrientLine: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label), \(value)")
    }
}

#Preview {
    NutrientBreakdownView(nutrition: NutritionInfo(
        foodName: "Meal Total",
        calories: 535,
        protein: 47,
        carbs: 45,
        fat: 16,
        fiber: 2,
        servingSize: ""
    ))
    .padding()
}
