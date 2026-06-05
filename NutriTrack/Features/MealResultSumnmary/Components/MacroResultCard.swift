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

    private var formattedAmount: String {
        unit.isEmpty ? String(format: "%.0f", amount) : String(format: "%.0f%@", amount, unit)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: iconName)
                    .foregroundStyle(themeColor)

                Text(title)
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline.weight(.medium))

            Text(formattedAmount)
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color(hex: "181818"))
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
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
            iconName: "flame.fill",
            amount: 680,
            unit: "",
            themeColor: .teal
        )

        MacroResultCard(
            title: "Protein",
            iconName: "p.circle.fill",
            amount: 24,
            unit: "g",
            themeColor: .pink
        )

        MacroResultCard(
            title: "Carbs",
            iconName: "leaf.fill",
            amount: 78,
            unit: "g",
            themeColor: .orange
        )

        MacroResultCard(
            title: "Fat",
            iconName: "drop.fill",
            amount: 30,
            unit: "g",
            themeColor: .indigo
        )
    }
    .padding(16)
    .background(Color(hex: "F3F3F3"))
}
