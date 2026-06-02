//
//  MacroElement.swift
//  NutriTrack
//
//  Created by David Paul Ong on 02/06/26.
//

import SwiftUI

struct MacroElement: View {
    
    var progress: Int
    var target: Int
    var color: String
    var macrotype: String
    
    init (_progress: Int, _target:Int, _hex_color: String, _macrotype: String) {
        progress = _progress
        target = _target
        color = _hex_color
        macrotype = _macrotype
    }
    
    var body: some View {
        VStack(alignment: .leading){
            // Protein Macro Main Text
            Group{
                Text("\(target - progress)g")
                Text("\(macrotype) Left")
            }
                .font(.system(size: 22))
                .foregroundStyle(Color(hex: color))
                .bold()

            // Protein Macro Subheading
            Text("\(progress) / \(target)g")
                .font(.system(size: 12))
                .foregroundStyle(Color(hex:"181818"))
                .opacity(0.5)
            
            // Progress bar
            ZStack{
                Rectangle()
                    .frame(height: 25)
                    .foregroundStyle(Color(hex: "D6D6D6"))
                    .cornerRadius(35)
                GeometryReader{ geometry in
                    let width = geometry.size.width
                    let progressLeft = (Double(target) - Double(progress))/Double(target)
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
//        .padding(.trailing, 10)
        .padding(.top, 15)
        .padding(.bottom, 30)
    }
}


