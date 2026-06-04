//
//  MacroResultCard.swift
//  NutriTrack
//
//  Created by Ni Ketut Lela Berliani on 03/06/26.
//

import SwiftUI

struct MacroResultCard: View {
    let title: String
    let iconName: String
    let amount: Double
    let unit: String
    let themeColor: Color
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 12)
                .frame(width: 177, height: 111)
                .foregroundStyle(Color(.systemGray6))
            
            VStack(alignment: .leading, spacing: 8){
                HStack (spacing: 4){
                    Image(systemName: iconName)
                    
                    Text(title)
                }
                .fontWeight(.medium)
                .font(.system(size: 16))
//                .foregroundStyle(Color(hex: "10937E"))

                
                Text(String(format: "%.0f%@", amount, unit))
                    .fontWeight(.semibold)
                    .font(.system(size: 32))
                    .foregroundStyle(Color(hex: "181818"))
        
            }
            .padding(19)
            .frame(maxWidth: 177, alignment: .leading)
            
        }
            
    }
}

#Preview {
    // 1. Initialize mock data models
    let mockItem = FoodItem(
        id: UUID(),
        name: "Grilled Chicken Salad",
        nutrition: NutritionInfo(calories: 680, proteinGrams: 45, carbsGrams: 20, fibreGrams: 8, fatGrams: 30)
    )
    
    let mockMeal = MealEntry(
        id: UUID(),
        timestamp: Date(),
        photoRef: nil,
        items: [mockItem]
    )
    
    // 2. Render UI components using the computed totalNutrition property
        
        // Protein Card
        MacroResultCard(
            title: "Protein",
            iconName: "p.circle",
            amount: mockMeal.totalNutrition.proteinGrams,
            unit: "g",
            themeColor: Color(hex: "D16D8E") // Assuming a distinct color for Protein
        )

}
