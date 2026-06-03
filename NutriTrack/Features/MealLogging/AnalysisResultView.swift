import SwiftUI

// AnalysisResultView shows what the mock (or AI) detected in the photo:
// a list of food items and the combined macro totals for the meal.
//
// The view receives data and two callbacks — it has zero business logic.
// "Log Meal" and "Retake" are decisions the ViewModel makes; this view just reports.
struct AnalysisResultView: View {
    let items: [FoodItem]
    let onLog: () -> Void
    let onRetake: () -> Void

    // Reuse MealEntry's computed totalNutrition rather than duplicating the reduce logic.
    private var total: NutritionInfo {
        MealEntry(id: UUID(), timestamp: .now, photoRef: nil, items: items).totalNutrition
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Detected Foods") {
                    ForEach(items) { item in
                        FoodItemRow(item: item)
                    }
                }

                Section("Meal Totals") {
                    NutrientBreakdownView(nutrition: total)
                        .padding(.vertical, 8)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Meal Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Retake", action: onRetake)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Log Meal", action: onLog)
                        .bold()
                }
            }
        }
    }
}

#Preview {
    AnalysisResultView(
        items: [
            FoodItem(id: UUID(), name: "Grilled Chicken",
                     nutrition: NutritionInfo(calories: 320, proteinGrams: 42, carbsGrams: 0, fibreGrams: 0, fatGrams: 14)),
            FoodItem(id: UUID(), name: "Brown Rice",
                     nutrition: NutritionInfo(calories: 215, proteinGrams: 5, carbsGrams: 45, fibreGrams: 2, fatGrams: 2))
        ],
        onLog: {},
        onRetake: {}
    )
}
