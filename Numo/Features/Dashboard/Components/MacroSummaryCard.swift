//reusable food card components

import SwiftUI

struct MacroSummaryCard: View {
    let meal: MealEntry

    private var itemsSummary: String {
        meal.ingredientsLabel
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: meal.timestamp)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Text(meal.mealPeriodTitle)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color(hex: "181818"))

                Spacer(minLength: 8)

                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Color(hex: "181818"))
                    .opacity(0.4)
            }

            Text(itemsSummary)
                .font(.system(size: 12))
                .foregroundStyle(Color(hex: "181818"))
                .opacity(0.5)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            Divider()
                .overlay(Color(hex: "181818").opacity(0.12))

            HStack(alignment: .center) {
                Label {
                    Text(String(format: "%.0f kcal", meal.totalNutrition.calories))
                } icon: {
                    Image(systemName: "flame.fill")
                }
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color(hex: "10937E"))

                Label {
                    Text(String(format: "%.0fg", meal.totalNutrition.protein))
                } icon: {
                    Image(systemName: "p.circle.fill")
                }
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color(hex: "D16D8E"))

                Spacer()

                Text(timeString)
                    .font(.system(size: 11))
                    .foregroundStyle(Color(hex: "181818"))
                    .opacity(0.5)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "E8E8E8"))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            AccessibilityLabels.mealSummary(
                period: meal.mealPeriodTitle,
                items: itemsSummary,
                calories: meal.totalNutrition.calories,
                protein: meal.totalNutrition.protein,
                time: timeString
            )
        )
    }
}

#Preview {
    let mockItem1 = FoodItemModel(
        id: UUID(),
        name: "rice, white, cooked",
        nutrition: NutritionInfo(
            foodName: "White rice",
            calories: 350,
            protein: 10,
            carbs: 45,
            fat: 12,
            fiber: 3,
            servingSize: "300g"
        )
    )
    let mockItem2 = FoodItemModel(
        id: UUID(),
        name: "chicken, breast, cooked",
        nutrition: NutritionInfo(
            foodName: "Chicken breast",
            calories: 70,
            protein: 6,
            carbs: 0,
            fat: 5,
            fiber: 0,
            servingSize: "50g"
        )
    )

    MacroSummaryCard(
        meal: MealEntry(
            id: UUID(),
            timestamp: Date(),
            photoRef: nil,
            mealName: nil,
            items: [mockItem1, mockItem2]
        )
    )
    .padding(16)
    .background(Color(hex: "F3F3F3"))
}
