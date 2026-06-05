//
//  MacroElement.swift
//  NutriTrack
//

import SwiftUI

struct MacroElement: View {
    // MARK: - NEW LOGIC (Unchanged)
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

    // MARK: - PREVIOUS UI LAYOUT REVERSED
    var body: some View {
        VStack(alignment: .leading) {
            // Protein Macro Main 
            Group {
                Text("\(remaining)g") // Hooked to new logic
                Text("\(macrotype) Left")
            }
            .font(.system(size: 22))
            .foregroundStyle(Color(hex: color))
            .bold()

            // Protein Macro Subheading
            Text("\(progress) / \(target)g")
                .font(.system(size: 12))
                .foregroundStyle(Color(hex: "181818"))
                .opacity(0.5)
            
            
            ZStack {
                Rectangle()
                    .frame(height: 25)
                    .foregroundStyle(Color(hex: "D6D6D6"))
                    .cornerRadius(35)
                
                GeometryReader { geometry in
                    let width = geometry.size.width
                    
                    let progressLeft = 1.0 - fillFraction
                    
                    Rectangle()
                        .frame(height: 16)
                        .foregroundStyle(Color(hex: color))
                        .cornerRadius(32)
                        .padding(.horizontal, 5)
                        .offset(x: -CGFloat(progressLeft) * width)
                }
                .frame(height: 16)
                .cornerRadius(32) // what even dude
                .padding(.horizontal, 5)
            }
        }
        .padding(.top, 15)
        .padding(.bottom, 30)
    }
}

//// MARK: - PREVIEW
//#Preview {
//    VStack(spacing: 0) {
//        MacroElement(80, 200, "D16D8E", "Protein")
//        MacroElement(15, 60, "7F7BDB", "Fat")
//    }
//    .padding()
//    // Using the legacy card background color to show how it looks in context
//    .background(Color(hex: "E8E8E8"))
//}
