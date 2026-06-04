//
//  PhotoResultSummary.swift
//  NutriTrack
//
//  Created by Ni Ketut Lela Berliani on 03/06/26.
//

import SwiftUI

struct PhotoResultSummary: View {
    let meal : MealEntry
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    //computed property to matched the data
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
        let names = meal.items.map { $0.name }
        return names.isEmpty ? "Unknown Meal" : names.joined(separator: ", ")
    }
    
    
    var body: some View {
        //photo
        
        NavigationStack {
            
            VStack (alignment: .center, spacing: 12){
                RoundedRectangle(cornerRadius: 25) //linked with image later
                    .frame(width: 362, height: 326)
                
                
                    VStack(alignment: .leading){
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
        
                //cards
                LazyVGrid(columns: columns, spacing: 16) {
                                
                    MacroResultCard(
                        title: "Calories",
                        iconName: "flame",
                        amount: 680,
                        unit: "",
                        themeColor: .teal
                    )
                    
                    MacroResultCard(
                        title: "Protein",
                        iconName: "p.circle",
                        amount: 24,
                        unit: "g",
                        themeColor: .pink
                    )
                    
                    MacroResultCard(
                        title: "Carbs",
                        iconName: "leaf",
                        amount: 78,
                        unit: "g",
                        themeColor: .orange
                    )
                    
                    MacroResultCard(
                        title: "Fat",
                        iconName: "figure.arms.open",
                        amount: 30,
                        unit: "g",
                        themeColor: .indigo
                    )
                }
                
                Button{}label:{
                    ZStack{
                        RoundedRectangle(cornerRadius: 50)
                            .frame(width: 362, height: 52)
                            .foregroundStyle(.black)
                            
                        
                        Text("Done")
                            .font(Font.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
            
            }
            .padding()
            .navigationTitle(Text("Macro Result"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                    // Trigger the dismiss action when tapped
    //                    dismiss()
                    } label: {
                        HStack(spacing: 4) {
                        Image(systemName: "xmark")
                        .fontWeight(.semibold)
                        
                    }
                    .foregroundStyle(Color(hex: "181818"))
                    }
                }
            }
        }
    }
}

#Preview {
    // Instantiating mock data required by the compiler for canvas rendering
    let mockMeal = MealEntry(id: UUID(), timestamp: Date(), photoRef: nil, items: [FoodItem(id: UUID(), name: "Eggs", nutrition: NutritionInfo(foodName: "Eggs", calories: 90, protein: 10, carbs: 4, fat: 2, fiber: 4, servingSize: "large"))])
    PhotoResultSummary(meal: mockMeal)
    
}
