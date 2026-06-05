//
//  MacroElement.swift
//  NutriTrack
//

import SwiftUI

struct MacroElement: View {
    let progress: Int
    let target: Int
    let color: String
    let macrotype: String

    init(_ progress: Int, _ target: Int, _ hexColor: String, _ macrotype: String) {
        self.progress = progress
        self.target = target
        self.color = hexColor
        self.macrotype = macrotype
    }

    private var remaining: Int {
        max(target - progress, 0)
    }

    private var fillFraction: CGFloat {
        guard target > 0 else { return 0 }
        return CGFloat(min(max(progress, 0), target)) / CGFloat(target)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(remaining)g")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color(hex: color))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text("\(macrotype) Left")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color(hex: color))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text("\(progress) / \(target)g")
                .font(.system(size: 12))
                .foregroundStyle(Color(hex: "181818"))
                .opacity(0.5)

            macroProgressBar
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(macrotype)")
        .accessibilityValue("\(progress) of \(target) grams consumed, \(remaining) grams remaining")
    }

    private var macroProgressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(hex: "D6D6D6"))

                Capsule()
                    .fill(Color(hex: color))
                    .frame(width: geometry.size.width * fillFraction)
            }
        }
        .frame(height: 8)
    }
}
