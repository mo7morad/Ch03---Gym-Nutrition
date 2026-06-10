
import SwiftUI

struct AnalysisResultView: View {
    let items: [FoodItemModel]
    let onLog: () -> Void
    let onRetake: () -> Void

    private var total: NutritionInfo {
        MealEntry(id: UUID(), timestamp: .now, photoRef: nil, mealName: nil, items: items).totalNutrition
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Detected Foods") {
                    ForEach(items) { item in
                        FoodItemRow(item: item)
                    }
                }
                .accessibilityLabel(AccessibilityLabels.MealLog.detectedFoods)

                Section("Meal Totals") {
                    NutrientBreakdownView(nutrition: total)
                        .padding(.vertical, 8)
                }
                .accessibilityLabel(AccessibilityLabels.MealLog.mealTotals)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Meal Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Retake", action: onRetake)
                        .accessibilityLabel(AccessibilityLabels.MealLog.retake)
                        .accessibilityHint(AccessibilityLabels.MealLog.retakeHint())
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Log Meal", action: onLog)
                        .bold()
                        .accessibilityLabel(AccessibilityLabels.MealLog.logMeal)
                        .accessibilityHint(AccessibilityLabels.MealLog.logMealHint())
                }
            }
        }
    }
}

#Preview {
    AnalysisResultView(
        items: [
            FoodItemModel(
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
            ),
            FoodItemModel(
                id: UUID(),
                name: "Brown Rice",
                nutrition: NutritionInfo(
                    foodName: "Brown Rice",
                    calories: 215,
                    protein: 5,
                    carbs: 45,
                    fat: 2,
                    fiber: 2,
                    servingSize: "180g"
                )
            )
        ],
        onLog: {},
        onRetake: {}
    )
}
