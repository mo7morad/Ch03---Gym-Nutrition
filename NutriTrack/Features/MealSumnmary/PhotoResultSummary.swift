//
//  PhotoResultSummary.swift
//  NutriTrack
//

import SwiftUI

struct PhotoResultSummary: View {
    enum Context {
        case newMeal
        case loggedMeal
    }

    let meal: MealEntry
    var context: Context = .newMeal
    var onDone: () -> Void = {}
    var onDismiss: () -> Void = {}
    var onEdit: (() -> Void)? = nil

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    private var totals: NutritionInfo {
        meal.totalNutrition
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    mealPhotoView

                    Text(meal.mealHeadline)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Color(hex: "181818"))

                    macroGrid

                    if context == .loggedMeal {
                        ingredientsSection
                        loggedConfirmation
                    }

                    if context == .newMeal {
                        doneButton
                    }
                }
                .padding()
            }
            .background(Color(hex: "F3F3F3"))
            .navigationTitle(meal.mealPeriodTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(hex: "181818"))
                    }
                }

                if context == .loggedMeal {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Edit") {
                            onEdit?()
                        }
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: "181818"))
                    }
                }
            }
        }
    }

    // MARK: - Photo

    @ViewBuilder
    private var mealPhotoView: some View {
        ZStack(alignment: .bottomLeading) {
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

            if context == .loggedMeal, meal.photoRef != nil {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(.black.opacity(0.35), in: Circle())
                    .padding(16)
                    .accessibilityLabel("Delete photo")
            }
        }
    }

    // MARK: - Macros

    private var macroGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            MacroResultCard(
                title: "Calories",
                iconName: "flame.fill",
                amount: totals.calories,
                unit: "kcal",
                themeColor: Color(hex: "10937E")
            )

            MacroResultCard(
                title: "Protein",
                iconName: "p.circle.fill",
                amount: totals.protein,
                unit: "g",
                themeColor: Color(hex: "D16D8E")
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

            MacroResultCard(
                title: "Fiber",
                iconName: "leaf.circle.fill",
                amount: totals.fiber,
                unit: "g",
                themeColor: Color(hex: "8A9B3B")
            )
        }
    }

    // MARK: - Logged meal extras

    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ingredients")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(hex: "181818"))

            Text(meal.ingredientsLabel)
                .font(.system(size: 14))
                .foregroundStyle(Color(hex: "181818"))
                .opacity(0.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var loggedConfirmation: some View {
        VStack(spacing: 8) {
            AppCharacter(width: 120)

            Text("Your meal is logged!")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(hex: "181818"))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .padding(.bottom, 24)
    }

    // MARK: - New meal

    private var doneButton: some View {
        Button(action: onDone) {
            Text("Done")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(.black, in: RoundedRectangle(cornerRadius: 50))
        }
        .padding(.top, 8)
    }
}

#Preview("Logged meal") {
    let mockMeal = MealEntry(
        id: UUID(),
        timestamp: Date(),
        photoRef: nil,
        items: [
            FoodItem(
                id: UUID(),
                name: "rice, brown, cooked",
                nutrition: NutritionInfo(
                    foodName: "Rice",
                    calories: 215,
                    protein: 5,
                    carbs: 45,
                    fat: 2,
                    fiber: 4,
                    servingSize: "1 cup"
                )
            ),
            FoodItem(
                id: UUID(),
                name: "chicken, nugget",
                nutrition: NutritionInfo(
                    foodName: "Chicken Nugget",
                    calories: 320,
                    protein: 18,
                    carbs: 20,
                    fat: 20,
                    fiber: 1,
                    servingSize: "6 pieces"
                )
            )
        ]
    )
    PhotoResultSummary(meal: mockMeal, context: .loggedMeal)
}
