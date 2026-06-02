//
//  CaloriesMacrosView.swift
//  NutriTrack
//
//  Created by David Paul Ong on 02/06/26.
//

import SwiftUI

struct CaloriesMacrosView: View {
    @State private var isExpanded: Bool = true
    var body: some View {
        VStack{
            VStack{
                
                // Calories Heading
                HStack {
                    Text("760 Calories Left")
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
                    }
                }
                .padding(.bottom, 3)
                
                // Calories Subheading
                HStack{
                    Text("1789 / 2550kcal")
                        .font(.system(size: 12))
                        .opacity(0.5)
                    Spacer()
                }
                .padding(.bottom, 4)
                
                // Progress Bar
                ZStack{
                    Rectangle()
                        .frame(height: 26)
                        .foregroundStyle(Color(hex: "D6D6D6"))
                        .cornerRadius(35)
                    Rectangle()
                        .frame(height: 17)
                        .foregroundStyle(Color(hex: "02C2A3"))
                        .cornerRadius(32)
                        .padding(.horizontal, 5)
                }
                
                // Macros
            if isExpanded{
//                        VStack{
//                            Divider()
//                            // Top Macro Row
//                            HStack{
//                                VStack(alignment: .center){
//                                    VStack(alignment: .leading){
//                                        // Protein Macro Main Text
//                                        VStack(alignment: .leading){
//                                            Text("28g")
//                                            Text("Protein Left")
//                                        }
//                                            .font(.system(size: 22))
//                                            .foregroundStyle(Color(hex: "D16D8E"))
//                                            .bold()
//
//                                        // Protein Macro Subheading
//                                        Text("92 / 120g")
//
//                                    }
//                                    // Progress bar
//                                    ZStack{
//                                        Rectangle()
//                                            .frame(height: 26)
//                                            .foregroundStyle(Color(hex: "D6D6D6"))
//                                            .cornerRadius(35)
//                                        Rectangle()
//                                            .frame(height: 17)
//                                            .foregroundStyle(Color(hex: "02C2A3"))
//                                            .cornerRadius(32)
//                                            .padding(.horizontal, 5)
//                                    }
//                                    .background(Color.red)
//                                }
//
//
//
//                                Spacer()
//                                Divider()
//                                    .frame(height: 100)
//                                Spacer()
//
//                                VStack(alignment: .leading){
//                                    Text("28g")
//                                    Text("Protein Left")
//                                }
//                                    .font(.system(size: 22))
//                                    .foregroundStyle(Color(hex: "D16D8E"))
//                                    .bold()
//
//                            }
//
//                            HStack{
//                                HStack{
//                                    Text("Protein: 17g")
//                                        .font(.system(size: 12))
//                                        .opacity(0.5)
//                                    Spacer()
//                                }
//                                Spacer()
//                                Divider()
//                                    .frame(height: 100)
//                                Spacer()
//                                HStack{
//                                    Text("Carbohydrates: 34g")
//                                        .font(.system(size: 12))
//                                        .opacity(0.5)
//                                    Spacer()
//                                }
//                            }
//
//                        }
//                        .transition(.move(edge: .top).combined(with: .opacity))

                Grid{
                    GridRow{
                        VStack{
                            // Protein Macro Main Text
                            VStack(alignment: .leading){
                                Text("28g")
                                Text("Protein Left")
                            }
                                .font(.system(size: 22))
                                .foregroundStyle(Color(hex: "D16D8E"))
                                .bold()

                            // Protein Macro Subheading
                            Text("92 / 120g")
                            
                            // Progress bar
                            ZStack{
                                Rectangle()
                                    .frame(height: 26)
                                    .foregroundStyle(Color(hex: "D6D6D6"))
                                    .cornerRadius(35)
                                Rectangle()
                                    .frame(height: 17)
                                    .foregroundStyle(Color(hex: "02C2A3"))
                                    .cornerRadius(32)
                                    .padding(.horizontal, 5)
                            }
                            .background(Color.red)

                        }
                        VStack{
                            // Protein Macro Main Text
                            VStack(alignment: .leading){
                                Text("28g")
                                Text("Protein Left")
                            }
                                .font(.system(size: 22))
                                .foregroundStyle(Color(hex: "D16D8E"))
                                .bold()

                            // Protein Macro Subheading
                            Text("92 / 120g")
                            
                            // Progress bar
                            ZStack{
                                Rectangle()
                                    .frame(height: 26)
                                    .foregroundStyle(Color(hex: "D6D6D6"))
                                    .cornerRadius(35)
                                Rectangle()
                                    .frame(height: 17)
                                    .foregroundStyle(Color(hex: "02C2A3"))
                                    .cornerRadius(32)
                                    .padding(.horizontal, 5)
                            }
                            .background(Color.red)

                        }
                        }
                    GridRow{
                        VStack{
                            // Protein Macro Main Text
                            VStack(alignment: .leading){
                                Text("28g")
                                Text("Protein Left")
                            }
                                .font(.system(size: 22))
                                .foregroundStyle(Color(hex: "D16D8E"))
                                .bold()

                            // Protein Macro Subheading
                            Text("92 / 120g")
                            
                            // Progress bar
                            ZStack{
                                Rectangle()
                                    .frame(height: 26)
                                    .foregroundStyle(Color(hex: "D6D6D6"))
                                    .cornerRadius(35)
                                Rectangle()
                                    .frame(height: 17)
                                    .foregroundStyle(Color(hex: "02C2A3"))
                                    .cornerRadius(32)
                                    .padding(.horizontal, 5)
                            }
                            .background(Color.red)

                        }
                        VStack{
                            // Protein Macro Main Text
                            VStack(alignment: .leading){
                                Text("28g")
                                Text("Protein Left")
                            }
                                .font(.system(size: 22))
                                .foregroundStyle(Color(hex: "D16D8E"))
                                .bold()

                            // Protein Macro Subheading
                            Text("92 / 120g")
                            
                            // Progress bar
                            ZStack{
                                Rectangle()
                                    .frame(height: 26)
                                    .foregroundStyle(Color(hex: "D6D6D6"))
                                    .cornerRadius(35)
                                Rectangle()
                                    .frame(height: 17)
                                    .foregroundStyle(Color(hex: "02C2A3"))
                                    .cornerRadius(32)
                                    .padding(.horizontal, 5)
                            }
                            .background(Color.red)

                        }
                        }


                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 26)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "E8E8E8"))
        )
        .padding(.horizontal, 20) // outer margin from screen edges
                
        }
    }



#Preview {
    CaloriesMacrosView()
}
