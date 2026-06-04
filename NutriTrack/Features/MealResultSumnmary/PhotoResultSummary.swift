//
//  PhotoResultSummary.swift
//  NutriTrack
//
//  Created by Ni Ketut Lela Berliani on 03/06/26.
//

import SwiftUI

struct PhotoResultSummary: View {
    let meal: MealEntry
    let previewImage: UIImage?
    let onDone: () -> Void
    let onDismiss: () -> Void

    @Environment(\.mealPhotoStorage) private var photoStorage

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    init(
        meal: MealEntry,
        previewImage: UIImage? = nil,
        onDone: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.meal = meal
        self.previewImage = previewImage
        self.onDone = onDone
        self.onDismiss = onDismiss
    }

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
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    mealPhotoView

                    VStack(alignment: .leading, spacing: 4) {
                        Text(mealTitle)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)

                        Text(itemsSummary)
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.primary)
                    }

                    LazyVGrid(columns: columns, spacing: 16) {
                        MacroResultCard(
                            title: "Calories",
                            iconName: "flame.fill",
                            amount: totals.calories,
                            unit: "",
                            themeColor: .teal
                        )

                        MacroResultCard(
                            title: "Protein",
                            iconName: "p.circle.fill",
                            amount: totals.protein,
                            unit: "g",
                            themeColor: .pink
                        )

                        MacroResultCard(
                            title: "Carbs",
                            iconName: "leaf.fill",
                            amount: totals.carbs,
                            unit: "g",
                            themeColor: .orange
                        )

                        MacroResultCard(
                            title: "Fat",
                            iconName: "drop.fill",
                            amount: totals.fat,
                            unit: "g",
                            themeColor: .indigo
                        )
                    }

                    Button(action: onDone) {
                        Text("Done")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 44)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.primary)
                    .padding(.top, 8)
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Macro Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
    }

    @ViewBuilder
    private var mealPhotoView: some View {
        Group {
            if let previewImage {
                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFill()
            } else if let photoRef = meal.photoRef,
                      let savedImage = photoStorage.loadMealPhoto(from: photoRef) {
                Image(uiImage: savedImage)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray5))
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 280)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityLabel("Meal photo")
    }
}

#Preview("Photo Result Summary") {
    let mockItem = FoodItem(
        id: UUID(),
        name: "Nugget Chilli Pepper",
        nutrition: NutritionInfo(
            foodName: "Nugget Chilli Pepper",
            calories: 680,
            protein: 24,
            carbs: 78,
            fat: 30,
            fiber: 5,
            servingSize: "1 serving"
        )
    )

    let mockMeal = MealEntry(
        id: UUID(),
        timestamp: Date(),
        photoRef: nil,
        items: [mockItem]
    )

    PhotoResultSummary(
        meal: mockMeal,
        onDone: {},
        onDismiss: {}
    )
}
