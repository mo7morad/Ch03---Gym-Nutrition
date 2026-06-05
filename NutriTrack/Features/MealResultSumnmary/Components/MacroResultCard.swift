//
//  MacroResultCard.swift
//  NutriTrack
//
//  Created by Ni Ketut Lela Berliani on 03/06/26.
//

import SwiftUI

struct MacroResultCard: View {
    let title: String
    let amount: Double
    let unit: String
    let themeColor: Color

    private var formattedAmount: String {
        unit.isEmpty ? String(format: "%.0f", amount) : String(format: "%.0f%@", amount, unit)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(themeColor)

            Text(formattedAmount)
                .font(.title2.weight(.semibold))
                .foregroundStyle(themeColor)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "E8E8E8"))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(formattedAmount)")
    }
}

#Preview("Macro Result Cards") {
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    LazyVGrid(columns: columns, spacing: 16) {
        MacroResultCard(
            title: "Calories",
            amount: 680,
            unit: "kcal",
            themeColor: .teal
        )

        MacroResultCard(
            title: "Protein",
            amount: 24,
            unit: "g",
            themeColor: .pink
        )

        MacroResultCard(
            title: "Carbs",
            amount: 78,
            unit: "g",
            themeColor: .orange
        )

        MacroResultCard(
            title: "Fat",
            amount: 30,
            unit: "g",
            themeColor: .indigo
        )
    }
    .padding(16)
    .background(Color(hex: "F3F3F3"))
}
