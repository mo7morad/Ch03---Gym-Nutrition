//
//  CaloriesMacrosView.swift
//  NutriTrack
//

import SwiftUI

struct CaloriesMacrosView: View {
    // MARK: - NEW LOGIC (Unchanged)
    let calories: Int
    let caloriesTarget: Int
    let macros: [String: Int]
    let macrosTarget: [String: Int]

    @State private var isExpanded = true

    private var caloriesRemaining: Int {
        max(caloriesTarget - calories, 0)
    }

    private var caloriesFillFraction: CGFloat {
        guard caloriesTarget > 0 else { return 0 }
        return CGFloat(min(max(calories, 0), caloriesTarget)) / CGFloat(caloriesTarget)
    }

    // MARK: - PREVIOUS UI LAYOUT REVERSED
    var body: some View {
        VStack(spacing: 0) {
            header
            fuelCard
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Today's Fuel")
                    .font(.system(size: 28, weight: .bold))
                    .accessibilityAddTraits(.isHeader)
                
                Text(Date(), style: .date)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color(hex: "181818"))
                    .opacity(0.5)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(AccessibilityLabels.Dashboard.todaysFuel)
            .padding(.leading, 15)
            .padding(.vertical, 20)
            Spacer()
        }
    }

    private var fuelCard: some View {
        VStack {
            VStack {
                caloriesSection
                
                // Macros
                if isExpanded {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 2)
                        .padding(.top, 10)
                    
                    macroGrid
                        .transition(.move(edge: .top).combined(with: .scale).combined(with: .opacity))
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 26)
        .padding(.bottom, isExpanded ? 10 : 26)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "E8E8E8"))
                .frame(width: 369)
        )
        .padding(.horizontal, 20)
    }

    private var caloriesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                Text("\(String(caloriesRemaining)) Calories Left")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color(hex: "10937E"))
                    .bold()
                Spacer()
                Button {
                    withAnimation(.spring()) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.down.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color(hex: "181818"))
                        .opacity(0.4)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .accessibilityLabel(
                    isExpanded
                    ? AccessibilityLabels.Dashboard.collapseMacros
                    : AccessibilityLabels.Dashboard.expandMacros
                )
            }
            .padding(.bottom, 3)
            
            // Calories Subheading
            HStack {
                Text("\(calories) / \(caloriesTarget)")
                    .font(.system(size: 12))
                    .opacity(0.5)
                Spacer()
            }
            .padding(.bottom, 4)
            
            
            ZStack {
                Rectangle()
                    .frame(height: 25)
                    .foregroundStyle(Color(hex: "D6D6D6"))
                    .cornerRadius(35)
                
                GeometryReader { geometry in
                    let width = geometry.size.width
                    let progressLeft = 1.0 - caloriesFillFraction
                    
                    Rectangle()
                        .frame(height: 16)
                        .foregroundStyle(Color(hex: "02C2A3"))
                        .cornerRadius(32)
                        .padding(.horizontal, 5)
                        .offset(x: -CGFloat(progressLeft) * width)
                }
                .frame(height: 16)
                .cornerRadius(32)
                .padding(.horizontal, 5)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AccessibilityLabels.caloriesRemaining(caloriesRemaining))
            .accessibilityValue(AccessibilityLabels.caloriesProgress(consumed: calories, target: caloriesTarget))
        }
    }

    private var macroGrid: some View {
        Grid() {
            GridRow {
                
                MacroElement(
                    macroValue("Protein"),
                    macroTarget("Protein"),
                    "D16D8E",
                    "Protein"
                )
                .padding(.trailing, 10)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 110, height: 2)
                }
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 2, height: 110)
                
                MacroElement(
                    macroValue("Carbs"),
                    macroTarget("Carbs"),
                    "D57E3E",
                    "Carbs"
                )
                .padding(.leading, 10)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 110, height: 2)
                }
            }
            GridRow {
                MacroElement(
                    macroValue("Fat"),
                    macroTarget("Fat"),
                    "7F7BDB",
                    "Fat"
                )
                .padding(.trailing, 10)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 2, height: 110)
                
                MacroElement(
                    macroValue("Fiber"),
                    macroTarget("Fiber"),
                    "8EA950",
                    "Fiber"
                )
                .padding(.leading, 10)
            }
        }
    }

    // MARK: - NEW LOGIC (Unchanged)
    private func macroValue(_ key: String) -> Int {
        macros[key] ?? 0
    }

    private func macroTarget(_ key: String) -> Int {
        macrosTarget[key] ?? 0
    }
}

#Preview {
    CaloriesMacrosView(
        calories: 1500,
        caloriesTarget: 2550,
        macros: ["Protein": 80, "Carbs": 80, "Fat": 80, "Fiber": 80],
        macrosTarget: ["Protein": 200, "Carbs": 200, "Fat": 200, "Fiber": 200]
    )
}
