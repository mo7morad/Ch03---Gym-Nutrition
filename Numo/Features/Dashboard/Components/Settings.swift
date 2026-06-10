//
//  SwiftUIView.swift
//  NutriTrack
//
//  Created by David Paul Ong on 05/06/26.
//

import SwiftUI

struct Settings: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack{
            
            Form {
                Section {
                    Text("Notification")
                    
                }
                
                Section{
                    Text("History")
                    Text("Food Log")
                }
                
                Section {
                    Text("Health Details")
                    Text("Change Goal")
                    Text("Units of Measure")
                }
            }
            .navigationTitle(Text("Settings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
            }
        }
//        VStack{
//            HStack{
//                Image(systemName: "x.circle")
//                    .resizable()
//                    .frame(width:20, height:20)
//                    .background(Color.blue)
//                    .clipShape(Circle())
//                    .padding(20)
//                Spacer()
//
//            }
//
//            Rectangle()
//                .frame(height: 100)
//
//        }
//        .frame(maxHeight: .infinity)
//        .glassEffect(in: RoundedRectangle(cornerRadius: 1))
    }
}

#Preview {
    Settings()
}
