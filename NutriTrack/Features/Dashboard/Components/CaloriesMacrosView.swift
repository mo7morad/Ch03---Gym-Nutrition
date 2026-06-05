//
//  CaloriesMacrosView.swift
//  NutriTrack
//

import SwiftUI

struct CaloriesMacrosView: View {
    let calories: Int
    let caloriesTarget: Int
    let macros: [String: Int]
    let macrosTarget: [String: Int]

    @State private var isExpanded = true

    private let macroColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var caloriesRemaining: Int {
        max(caloriesTarget - calories, 0)
    }

    private var caloriesFillFraction: CGFloat {
        guard caloriesTarget > 0 else { return 0 }
        return CGFloat(min(max(calories, 0), caloriesTarget)) / CGFloat(caloriesTarget)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            fuelCard
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Today's Fuel")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color(hex: "181818"))

            Text(Date(), style: .date)
                .font(.system(size: 12))
                .foregroundStyle(Color(hex: "181818"))
                .opacity(0.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Main card

    private var fuelCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            caloriesSection

            if isExpanded {
                macroGrid
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "E8E8E8"))
        }
    }

    private var caloriesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                Text("\(String(caloriesRemaining)) Calories Left")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color(hex: "10937E"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer(minLength: 8)

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.down.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color(hex: "181818"))
                        .opacity(0.4)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
            }

            Text("\(calories) / \(caloriesTarget)")
                .font(.system(size: 12))
                .foregroundStyle(Color(hex: "181818"))
                .opacity(0.5)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(hex: "D6D6D6"))

                    Capsule()
                        .fill(Color(hex: "02C2A3"))
                        .frame(width: geometry.size.width * caloriesFillFraction)
                }
            }
            .frame(height: 12)
        }
    }

    private var macroGrid: some View {
        LazyVGrid(columns: macroColumns, spacing: 12) {
            MacroElement(
                macroValue("Protein"),
                macroTarget("Protein"),
                "D16D8E",
                "Protein"
            )
            MacroElement(
                macroValue("Carbs"),
                macroTarget("Carbs"),
                "D57E3E",
                "Carbs"
            )
            MacroElement(
                macroValue("Fat"),
                macroTarget("Fat"),
                "7F7BDB",
                "Fat"
            )
            MacroElement(
                macroValue("Fiber"),
                macroTarget("Fiber"),
                "8EA950",
                "Fiber"
            )
        }
    }

    private func macroValue(_ key: String) -> Int {
        macros[key] ?? 0
    }

    private func macroTarget(_ key: String) -> Int {
        macrosTarget[key] ?? 0
    }
}

#Preview {
    CaloriesMacrosView(
        calories: 506,
        caloriesTarget: 2009,
        macros: ["Protein": 22, "Carbs": 73, "Fat": 13, "Fiber": 3],
        macrosTarget: ["Protein": 151, "Carbs": 201, "Fat": 67, "Fiber": 28]
    )
    .background(Color(hex: "F3F3F3"))
}
