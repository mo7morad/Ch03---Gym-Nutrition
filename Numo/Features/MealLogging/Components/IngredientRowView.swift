//
//  IngredientsRowView.swift
//  Numo
//
//  Created by Ni Ketut Lela Berliani on 10/06/26.
//

import SwiftUI

struct IngredientRowView: View {
    @State var ingredient: FoodItemModel
    var onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Ingredient Name Pill
            TextField("Ingredient", text: $ingredient.name)
                .font(.system(size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(Capsule())
            
            // Amount Pill
            TextField("Amount", text: Binding(
                get: { String(ingredient.nutrition.servingSize) },
                set: { ingredient.nutrition.servingSize = String($0)}
            ))
                .font(.system(size: 15))
                .frame(width: 65)
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(Capsule())
            
            // Unit Label
            Text("g")
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            // Delete Button
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color.gray.opacity(0.8))
            }
        }
    }
}
