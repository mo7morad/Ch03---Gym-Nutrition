//
//  ManualLogging.swift
//  Numo
//
//  Created by Ni Ketut Lela Berliani on 10/06/26.
//

import SwiftUI

struct DescribeMealView: View {
    // Sample state data matching your screenshot
    @State private var ingredients = [
        FoodItemModel(
            id: UUID(),
            name: "Rice",
            nutrition: NutritionInfo(foodName: "Rice", calories: 20, protein: 20, carbs: 20, fat: 20, fiber: 20, servingSize: "120")
        ),
        FoodItemModel(
            id: UUID(),
            name: "Chicken Nugget",
            nutrition: NutritionInfo(foodName: "Chicken Nugget", calories: 20, protein: 20, carbs: 20, fat: 20, fiber: 20, servingSize: "30")
        )
    ]
    
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
                        
                        Text("Breakfast")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(Capsule())
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Meal Name")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Nugget Chili Pepper Salt")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(Capsule())
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Ingredients")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(ingredients) { ingredient in
                            IngredientRowView(ingredient: ingredient) {
                                // Delete action logic here
                                if let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
                                    ingredients.remove(at: index)
                                }
                            }
                        }
                    }
                    
                    
                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 20)
            }
            
            // Bottom Graphic & Add Button overlay
            bottomOverlay
        }
    }
    
    // MARK: - Subviews
    
    private var customNavigationBar: some View {
        HStack {
            Button(action: { /* Back Action */ }) {
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
            
            Button(action: { /* Save Action */ }) {
                Image(systemName: "checkmark")
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color(red: 0.35, green: 0.73, blue: 0.65)) // Teal color
                    .clipShape(Circle())
            }
        }
        .padding(.top, 10)
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
            
            // Add Ingredients Floating Button
            Button(action: { /* Add Ingredient Action */ }) {
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
        }
        .frame(maxWidth: .infinity)
    }
}


struct DescribeMealView_Previews: PreviewProvider {
    static var previews: some View {
        DescribeMealView()
    }
}
