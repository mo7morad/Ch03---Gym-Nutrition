import SwiftUI


struct MacrosBar: View {
    
    var barHeight: CGFloat = 150
    var barWidth: CGFloat = 75
    var barRadius: CGFloat = 50
    var barBorderWidth: CGFloat = 10
    
    var body: some View {
        
        HStack{
            Text("Nutrition Overview")
                .padding(.horizontal, 32)
                .font(.system(size: 26) .bold())
            Spacer()
        }
        
        HStack(spacing: 17) {
            
            ZStack {
                Rectangle()
                    .fill(Color(hex: "E6E6E6"))
                    .frame(width: barWidth, height: barHeight)
                    .cornerRadius(barRadius)
                Rectangle()
                    .fill(
                        LinearGradient(
                                    colors: [Color(hex: "F0B6B6"), Color(hex: "F07B7B")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                        )
                    .frame(width: barWidth-barBorderWidth, height: barHeight-barBorderWidth)
                    .cornerRadius(barRadius)
            }
            
            ZStack {
                Rectangle()
                    .fill(Color(hex: "E6E6E6"))
                    .frame(width: barWidth, height: barHeight)
                    .cornerRadius(barRadius)
                Rectangle()
                    .fill(
                        LinearGradient(
                                    colors: [Color(hex: "FFE1B2"), Color(hex: "FFB87A")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                        )
                    .frame(width: barWidth-barBorderWidth, height: barHeight-barBorderWidth)
                    .cornerRadius(barRadius)
                Image(systemName: "checkmark.circle")
                    .foregroundStyle(Color(hex: "BD6205"))
                    .font(.system(size: 25) .bold())
            }
            ZStack {
                Rectangle()
                    .fill(Color(hex: "E6E6E6"))
                    .frame(width: barWidth, height: barHeight)
                    .cornerRadius(barRadius)
                Rectangle()
                    .fill(
                        LinearGradient(
                                    colors: [Color(hex: "CFE0C6"), Color(hex: "95CC81")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                        )
                    .frame(width: barWidth-barBorderWidth, height: barHeight-barBorderWidth)
                    .cornerRadius(barRadius)
                

            }
            ZStack {
                Rectangle()
                    .fill(Color(hex: "E6E6E6"))
                    .frame(width: barWidth, height: barHeight)
                    .cornerRadius(barRadius)
                Rectangle()
                    .fill(
                        LinearGradient(
                                    colors: [Color(hex: "D9D9D9"), Color(hex: "878787")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                        )
                    .frame(width: barWidth-barBorderWidth, height: barHeight-barBorderWidth)
                    .cornerRadius(barRadius)
            }
            
        }
        .padding(.horizontal, 50)
    }
}

#Preview {
    MacrosBar()
}
