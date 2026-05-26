import SwiftUI

// Displays a full macro breakdown for a NutritionInfo value.
// Used in AnalysisResultView to show the totals for the whole meal.
struct NutrientBreakdownView: View {
    let nutrition: NutritionInfo

    var body: some View {
        VStack(spacing: 14) {
            NutrientLine(label: "Calories",  value: "\(Int(nutrition.calories)) kcal", color: .orange)
            NutrientLine(label: "Protein",   value: "\(Int(nutrition.proteinGrams))g",  color: .blue)
            NutrientLine(label: "Carbs",     value: "\(Int(nutrition.carbsGrams))g",    color: .green)
            NutrientLine(label: "Fat",       value: "\(Int(nutrition.fatGrams))g",      color: .yellow)
            NutrientLine(label: "Fibre",     value: "\(Int(nutrition.fibreGrams))g",    color: .brown)
        }
    }
}

// Private implementation detail — not exported outside this file.
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
    }
}

#Preview {
    NutrientBreakdownView(nutrition: NutritionInfo(
        calories: 535, proteinGrams: 47, carbsGrams: 45, fibreGrams: 2, fatGrams: 16
    ))
    .padding()
}
