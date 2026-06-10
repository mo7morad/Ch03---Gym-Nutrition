//
//  ManualLogging.swift
//  Numo
//
//  Created by Ni Ketut Lela Berliani on 10/06/26.
//

import SwiftUI

struct DescribeMealView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var navigateToSummary = false
    
    
    enum Context {
        case newMeal
        case loggedMeal
    }
    
    @State var meal: MealEntry
    var context: Context = .newMeal
    var onDone: () -> Void = {}
    var onDismiss: () -> Void = {}
    @State var viewModel: MealLogViewModel
    
    init(meal: MealEntry, context: Context, onDone: @escaping () -> Void, onDismiss: @escaping () -> Void, viewModel: MealLogViewModel) {
        self.meal = meal
        self.context = context
        self.onDone = onDone
        self.onDismiss = onDismiss
        self.viewModel = viewModel
    }
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Background
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    customNavigationBar
                    
                    photoPickerSection
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Meal Type")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        TextField("Meal Type", text: Binding(
                            get: { meal.mealPeriodTitle },
                            set: { meal.mealPeriodTitle = $0 }
                        ))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(Capsule())
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Meal Name")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        TextField("Meal Name", text: Binding(
                            get: { meal.mealName ?? "" },
                            set: { meal.mealName = $0 }
                        ))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(Capsule())
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Ingredients")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(meal.items) { ingredient in
                            IngredientRowView(ingredient: ingredient) {
                                // Delete action logic here
                                if let index = meal.items.firstIndex(where: { $0.id == ingredient.id }) {
                                    meal.items.remove(at: index)
                                }
                            }
                        }
                    }
                    
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                
                // Add Ingredients Floating Button
                Button(action: { meal.items.append(
                    FoodItemModel(
                        id: UUID(),
                        name: "",
                        nutrition: NutritionInfo(
                            foodName: "",
                            calories: 0,
                            protein: 0,
                            carbs: 0,
                            fat: 0,
                            fiber: 0,
                            servingSize: "0 cup"
                        )
                    )
                )}) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color(red: 0.05, green: 0.15, blue: 0.25))
                        Text("Add Ingredients")
                            .foregroundColor(.black)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.95))
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
                .padding(.bottom, 30)
                
                bottomOverlay
            }
            
//            // Bottom Graphic & Add Button overlay
//            bottomOverlay
        }
        

    }
    
    private func close() {
        if context == .loggedMeal {
            dismiss()
        } else {
            onDismiss()
        }
    }
    
    // MARK: - Subviews
    
    private var customNavigationBar: some View {
        HStack {
            Button(action: {close()}) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            
            Spacer()
            
            Text("Describe")
                .font(.headline)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: {navigateToSummary = true}) {
                Image(systemName: "checkmark")
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color(red: 0.35, green: 0.73, blue: 0.65)) // Teal color
                    .clipShape(Circle())
            }
        }
        .padding(.top, 10)
        .navigationDestination(isPresented: $navigateToSummary){
            PhotoResultSummary(
                meal: meal,
                context: .newMeal,
                onDone: {
                    onDone()
                },
                onDismiss: {
                    onDismiss()
                }
            )
        }
        .accessibilityLabel(context == .loggedMeal ? "Back" : "Close")

    
    }

    
    private var photoPickerSection: some View {
        HStack {
            Spacer()
            Button(action: {}) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("Take Photo")
                }
                .foregroundColor(.gray)
                .font(.system(size: 14, weight: .medium))
            }
            
            Divider()
                .frame(height: 15)
                .padding(.horizontal, 10)
            
            Button(action: {}) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                    Text("Choose Photo")
                }
                .foregroundColor(.gray)
                .font(.system(size: 14, weight: .medium))
            }
            Spacer()
        }
        .frame(height: 120)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var bottomOverlay: some View {
        ZStack(alignment: .bottom) {
            //Mascot Icon
            Image("MascotManualLogging")
            .offset(x: -100, y: 80)
            .frame(width: 180, height: 180)
        }
        .frame(maxWidth: .infinity)
    }
}


struct DescribeMealView_Previews: PreviewProvider {
    
    static var previews: some View {
        @Environment(\.foodAnalysisService) var foodAnalysisService
        DescribeMealView(
            meal: MealEntry(id: UUID(), timestamp: Date(), photoRef: nil, mealName: "Super Chicken", items: [
                FoodItemModel(
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
                FoodItemModel(
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
            ]), context: .loggedMeal, onDone: {print("done")}, onDismiss:{print("dismiss")}, viewModel: MealLogViewModel(analysisService: foodAnalysisService)
        )
    }
}
