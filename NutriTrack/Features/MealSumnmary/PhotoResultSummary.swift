//
//  PhotoResultSummary.swift
//  NutriTrack
//

import SwiftUI

struct PhotoResultSummary: View {
    let meal: MealEntry
    var onDone: () -> Void = {}
    var onDismiss: () -> Void = {}

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    private var mealTitle: String {
        let hour = Calendar.current.component(.hour, from: meal.timestamp)
        switch hour {
        case 5..<11: return "Breakfast"
        case 11..<15: return "Lunch"
        case 15..<18: return "Snack"
        default: return "Dinner"
        }
    }

    private var itemsSummary: String {
        let names = meal.items.map(\.name)
        return names.isEmpty ? "Unknown Meal" : names.joined(separator: ", ")
    }

    private var totals: NutritionInfo {
        meal.totalNutrition
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 12) {
                mealPhotoView

                VStack(alignment: .leading) {
                    Text(mealTitle)
                        .fontWeight(.medium)
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: "181818"))
                        .opacity(0.5)

                    Text(itemsSummary)
                        .fontWeight(.semibold)
                        .font(.system(size: 24))
                        .foregroundStyle(Color(hex: "181818"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                LazyVGrid(columns: columns, spacing: 16) {
                    MacroResultCard(
                        title: "Calories",
                        iconName: "flame",
                        amount: totals.calories,
                        unit: "",
                        themeColor: .teal
                    )

                    MacroResultCard(
                        title: "Protein",
                        iconName: "p.circle",
                        amount: totals.protein,
                        unit: "g",
                        themeColor: .pink
                    )

                    MacroResultCard(
                        title: "Carbs",
                        iconName: "leaf",
                        amount: totals.carbs,
                        unit: "g",
                        themeColor: .orange
                    )

                    MacroResultCard(
                        title: "Fat",
                        iconName: "figure.arms.open",
                        amount: totals.fat,
                        unit: "g",
                        themeColor: .indigo
                    )
                }

                Button(action: onDone) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 50)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .foregroundStyle(.black)

                        Text("Done")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding()
            .navigationTitle("Macro Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(hex: "181818"))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var mealPhotoView: some View {
        Group {
            if let photoRef = meal.photoRef,
               let uiImage = ImageProcessingService.loadMealPhoto(from: photoRef) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color(.systemGray5))
                    .overlay {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 326)
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }
}

#Preview {
    let mockMeal = MealEntry(
        id: UUID(),
        timestamp: Date(),
        photoRef: nil,
        items: [
            FoodItem(
                id: UUID(),
                name: "Eggs",
                nutrition: NutritionInfo(
                    foodName: "Eggs",
                    calories: 90,
                    protein: 10,
                    carbs: 4,
                    fat: 2,
                    fiber: 4,
                    servingSize: "large"
                )
            )
        ]
    )
    PhotoResultSummary(meal: mockMeal)
}
