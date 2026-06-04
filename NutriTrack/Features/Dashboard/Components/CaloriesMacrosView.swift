//
//  CaloriesMacrosView.swift
//  NutriTrack
//
//  Created by David Paul Ong on 02/06/26.
//

import SwiftUI

struct CaloriesMacrosView: View {
    let calories: Int
    let caloriesTarget: Int
    let macros: [String: Int]
    let macrosTarget: [String: Int]

    @State private var isExpanded: Bool = true
    
    var body: some View {
        HStack{
            VStack(alignment:.leading){
                Text("Today's Fuel")
                    .font(.system(size: 28, weight: .bold))
                
                Text(Date(), style: .date)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color(hex: "181818"))
                    .opacity(0.5)
            }
            .padding(.leading, 15)
            .padding(.top, 20)
            Spacer()
        }
        
        VStack{
            VStack{
                
                // Calories Heading
                HStack {
                    Text("\(caloriesTarget - calories) Calories Left")
                        .font(.system(size: 22))
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
                }
                .padding(.bottom, 3)
                
                // Calories Subheading
                HStack{
                    Text("\(calories) / \(caloriesTarget)")
                        .font(.system(size: 12))
                        .opacity(0.5)
                    Spacer()
                }
                .padding(.bottom, 4)
                
                // Progress Bar
                ZStack{
                    Rectangle()
                        .frame(height: 25)
                        .foregroundStyle(Color(hex: "D6D6D6"))
                        .cornerRadius(35)
                    
                    GeometryReader{ geometry in
                        let width = geometry.size.width
                        let progressLeft = (Double(caloriesTarget) - Double(calories))/Double(caloriesTarget)
                        Rectangle()
                            .frame(height: 16)
                            .foregroundStyle(Color(hex: "02C2A3"))
                            .cornerRadius(32)
                            .padding(.horizontal, 5)
                            .offset(x: -CGFloat(progressLeft) * width)
                    }
                    .frame(height: 16)
                    .cornerRadius(32) // what even dude
                    .padding(.horizontal, 5)
                }
                
                // Macros
            if isExpanded{
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 2)
                    .padding(.top, 10)
                
                Grid(){
                    GridRow{
                        MacroElement(
                            _progress: macros["Protein"]!,
                            _target: macrosTarget["Protein"]!,
                            _hex_color: "D16D8E",
                            _macrotype: "Protein")
                        .padding(.trailing, 10)
                        .overlay(alignment: .bottom){
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width:110, height: 2)
                        }
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 2, height: 110)
                        
                        MacroElement(
                            _progress: macros["Carbs"]!,
                            _target: macrosTarget["Carbs"]!,
                            _hex_color: "D57E3E",
                            _macrotype: "Carbs")
                        .padding(.leading, 10)
                        .overlay(alignment: .bottom){
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width:110, height: 2)
                        }
                        
                       }
                    GridRow{
                        MacroElement(
                            _progress: macros["Fat"]!,
                            _target: macrosTarget["Fat"]!,
                            _hex_color: "7F7BDB",
                            _macrotype: "Fat")
                        .padding(.trailing, 10)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 2, height: 110)
                        
                        MacroElement(
                            _progress: macros["Fiber"]!,
                            _target: macrosTarget["Fiber"]!,
                            _hex_color: "8EA950",
                            _macrotype: "Fiber")
                        .padding(.leading, 10)
                        
                       }
                    }
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
    }



#Preview {
    CaloriesMacrosView(
        calories: 1500,
        caloriesTarget: 2550,
        macros: ["Carbs": 80, "Protein": 80, "Fat": 80, "Fiber": 80],
        macrosTarget: ["Carbs": 200, "Protein": 200, "Fat": 200, "Fiber": 200]
    )
}
