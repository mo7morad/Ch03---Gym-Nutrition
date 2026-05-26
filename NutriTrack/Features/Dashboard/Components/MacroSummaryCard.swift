//reusable food card components


import SwiftUI

struct MacroSummaryCard: View{
    let food: FoodItem
    
    var body : some View{
        ZStack{
            RoundedRectangle(cornerRadius: 35)
                .fill(Color("foodCard"))
            ZStack(alignment: .center){
                Image("pan-break")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 116, height: 156
                    )
                    .cornerRadius(58)
                
                VStack(spacing:2){
                    Text(food.name)
                        .font(.system(size: 18))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(.white))
                    
                    Text("\(food.nutrition.calories, specifier: "%.0f") kcal")
                        .font(.system(size: 15))
                        .fontWeight(.light)
                        .foregroundStyle(Color(.white))
                }
                
                
                
            }
        }
        .frame(width: 172, height: 211)
    }
}




#Preview {
    MacroSummaryCard(
        food: FoodItem(
            id: UUID(),
            name: "Breakie",
            nutrition: NutritionInfo(
                calories: 100,
                proteinGrams: 80,
                carbsGrams: 50,
                fibreGrams: 100,
                fatGrams: 10
            )
        )
    )
}
