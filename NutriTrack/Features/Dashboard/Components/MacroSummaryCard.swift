//reusable food card components


import SwiftUI

struct MacroSummaryCard: View{
    let meal: MealEntry
    
    private var itemsSummary: String {
        let names = meal.items.map { $0.name }
        return names.isEmpty ? "No items logged" : names.joined(separator: ", ")
    }
        
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: meal.timestamp)
    }
    
    private var mealTitle: String {
        let hour = Calendar.current.component(.hour, from: meal.timestamp)
        switch hour {
        case 5..<11: return "Breakfast"
        case 11..<15: return "Lunch"
        case 15..<18: return "Snack"
        default: return "Dinner"
        }
    }
    
    var body : some View{
        
      ZStack{
            RoundedRectangle(cornerRadius: 12)
              .foregroundStyle(Color(hex: "E8E8E8"))
              .frame(width: 369, height: 129)
          
          VStack (alignment: .leading, spacing: 9){
              
              HStack{
                  Text(mealTitle)  //link the data
                      .fontWeight(.semibold)
                      .font(.system(size: 22))
                  
                  Spacer()
                  
                  Button{}label: {
                      Image(systemName: "chevron.right.circle.fill")
                          .resizable()
                          .frame(width: 22, height: 22)
                          .foregroundStyle(Color(hex: "181818"))
                          .opacity(0.4)
                  }
                  
              }
              
                  
              
              Text(itemsSummary)  //link the data
                  .fontWeight(.regular)
                  .font(.system(size: 12))
                  .foregroundStyle(Color(hex: "181818"))
                  .opacity(0.5)
              
              
              Divider()
            
              HStack{
                HStack(spacing: 3){
                      Image(systemName: "flame")
                          .resizable()
                          .scaledToFill()
                          .frame(width: 11, height: 11)
                      
                      Text(String(format: "%.0f kcal", meal.totalNutrition.calories)) //link the data
                          .font(.system(size: 11))
                  }
                .fontWeight(.semibold)
                .padding(.trailing, 15)
                .foregroundStyle(Color(hex: "10937E"))
                  
                  HStack(spacing: 3){
                      Image(systemName: "p.circle")
                          .resizable()
                          .scaledToFill()
                          .frame(width: 12, height: 12)
                          
                      
                      Text(String(format: "%.0fg", meal.totalNutrition.protein))
                          .font(.system(size: 11))
                          .font(.system(size: 11))
                  }
                  .foregroundStyle(Color(hex: "D16D8E"))
                  .fontWeight(.semibold)
                  
                  
                  Spacer()
                  
                  Text("09.25") //link the data
                      .font(Font.system(size: 11))
                      .foregroundStyle(Color(hex: "181818"))
                      .opacity(0.5)
              }
              
          }
          .padding(.vertical, 21)
          .padding(.horizontal, 36)
          
        }
    }
}




#Preview {
    // Updated to match your exact FoodItem struct requirement (adding id: UUID())
    let mockItem1 = FoodItem(id: UUID(), name: "Fried Rice", nutrition: NutritionInfo(foodName: "Fried Rice", calories: 350, protein: 10, carbs: 45, fat: 12, fiber: 3, servingSize: "300g"))
    let mockItem2 = FoodItem(id: UUID(), name: "Boiled Egg", nutrition: NutritionInfo(foodName: "Boiled Egg", calories: 70, protein: 6, carbs: 0, fat: 5, fiber: 0, servingSize: "50g"))
    
    let mockMeal = MealEntry(id: UUID(), timestamp: Date(), photoRef: nil, items: [mockItem1, mockItem2])
    
    MacroSummaryCard(meal: mockMeal)
}
