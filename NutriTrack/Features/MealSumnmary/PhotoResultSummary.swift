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

    private var totals: NutritionInfo {
        meal.totalNutrition
    }

    private var photoHeight: CGFloat {
        context == .loggedMeal ? 220 : 280
    }

    @Environment(\.dismiss) private var dismiss

    var body: some View {
//        ZStack (alignment: .bottomLeading){
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 15) {
                    mealPhotoView
                    
                    Text(meal.mealHeadline)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color(hex: "181818"))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    macroGrid
                    
                    if context == .loggedMeal {
                        ingredientsSection
                    }
                    
                    if context == .newMeal {
                        doneButton
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 120)
            
                    
            }
            
            .ignoresSafeArea(.all, edges: .bottom)
            .scrollBounceBehavior(.basedOnSize)
    
            .overlay (alignment: .bottomLeading){
            Image("MealLoggedHappy")
                .resizable()
                .scaledToFit()
                .frame(width: 400, height: 190)
                .offset(x: -100, y: 100)
                .ignoresSafeArea(.all, edges: .bottom)
            }
            
            
//        }
        
        .scrollBounceBehavior(.basedOnSize)
        .background(Color(hex: "F3F3F3"))
        .preferredColorScheme(.light)
        .navigationTitle(meal.mealPeriodTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(context == .loggedMeal)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: close) {
                    Image(systemName: context == .loggedMeal ? "chevron.left" : "xmark")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: "181818"))
                }
                .accessibilityLabel(context == .loggedMeal ? "Back" : "Close")
            }
        }
    }

    private func close() {
        if context == .loggedMeal {
            dismiss()
        } else {
            onDismiss()
        }
    }

    // MARK: - Photo

    @ViewBuilder
    private var mealPhotoView: some View {
        Group {
            if let photoRef = meal.photoRef,
               let uiImage = ImageProcessingService.loadMealPhoto(from: photoRef) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray5))
                    .overlay {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: photoHeight)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .accessibilityLabel(meal.photoRef == nil ? "Meal photo placeholder" : "Meal photo")
    }

    // MARK: - Macros

    private var macroGrid: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                MacroResultCard(
                    title: "Calories", iconName: "heart",
                    amount: totals.calories,
                    unit: "kcal",
                    themeColor: Color(hex: "10937E")
                )
                MacroResultCard(
                    title: "Protein", iconName: "heart",
                    amount: totals.protein,
                    unit: "g",
                    themeColor: Color(hex: "D16D8E")
                )
            }

            HStack(spacing: 12) {
                MacroResultCard(
                    title: "Carbs", iconName: "heart",
                    amount: totals.carbs,
                    unit: "g",
                    themeColor: .orange
                )
                MacroResultCard(
                    title: "Fat", iconName: "heart",
                    amount: totals.fat,
                    unit: "g",
                    themeColor: .indigo
                )
            }

            HStack(spacing: 12) {
                MacroResultCard(
                    title: "Fiber", iconName: "",
                    amount: totals.fiber,
                    unit: "g",
                    themeColor: Color(hex: "8A9B3B")
                )
                Color.clear
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Logged meal extras

    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ingredients")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(hex: "181818"))
                .accessibilityAddTraits(.isHeader)

            Text(meal.ingredientsLabel)
                .font(.system(size: 14))
                .foregroundStyle(Color(hex: "181818"))
                .opacity(0.5)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
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
        .accessibilityLabel("Done")
        .accessibilityHint("Logs this meal")
    }
}

#Preview("Logged meal") {
    NavigationStack {
        PhotoResultSummary(meal: MealEntry(
            id: UUID(),
            timestamp: Date(),
            photoRef: nil,
            items: [
                FoodItem(
                    id: UUID(),
                    name: "rice, white, cooked",
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
                    name: "chicken, leg, cooked",
                    nutrition: NutritionInfo(
                        foodName: "Chicken leg",
                        calories: 320,
                        protein: 18,
                        carbs: 20,
                        fat: 20,
                        fiber: 1,
                        servingSize: "1 leg"
                    )
                )
            ]
        ), context: .loggedMeal)
    }
}
