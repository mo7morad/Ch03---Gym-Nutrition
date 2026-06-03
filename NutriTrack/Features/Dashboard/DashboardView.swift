import SwiftUI

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    @State private var toggleStreak: Bool = true
    
    let mockMeal1 = MealEntry(id: UUID(), timestamp: Date(), photoRef: nil, items: [FoodItem(id: UUID(), name: "Fried Rice", nutrition: NutritionInfo(foodName: "Fried Rice", calories: 90, protein: 10, carbs: 4, fat: 2, fiber: 4, servingSize: "large"))])
    
    let mockMeal2 = MealEntry(id: UUID(), timestamp: Date(), photoRef: nil, items: [FoodItem(id: UUID(), name: "Eggs", nutrition: NutritionInfo(foodName: "Eggs", calories: 90, protein: 10, carbs: 4, fat: 2, fiber: 4, servingSize: "large"))])
    
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack {
                    Image("AppCharacter")
                        .resizable()
                        .frame(width: 220, height: 150)
                        .padding(.top, 40)
                    
                    CaloriesMacrosView()
                    
                    MealListSectionView(dailyMeals: [mockMeal1, mockMeal2])
                    
                }
            }
            .toolbar{
                // Streak Toolbar
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button{
                        withAnimation(.spring()) {
                            toggleStreak.toggle()
                        }
                    } label:{
                        HStack{
                            Image(systemName: "flame")
                        }
                    }
                    Text("1")
                        .offset(x: -12)
                }
                
                
                // Profile Toolbar
                ToolbarItem(placement: .topBarTrailing){
                    Image(systemName: "person.fill")
                }
                
                
                // Add Meal Toolbar
                ToolbarItemGroup(placement: .bottomBar){
                    Spacer()
                    
                    Menu {
                        
                        // Take Photo
                        Button{
                            
                        } label:{
                            HStack{
                                Image(systemName: "photo.fill.on.rectangle.fill")
                                Text("Choose Photo")
                            }
                            
                        }
                        
                        // Choose Photo
                        Button{
                            
                        } label:{
                            HStack{
                                Image(systemName: "camera.fill")
                                Text("Take Photo")
                            }
                        }
                        
                        
                    } label: {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Meal  ")
                    }
                    .contentShape(Rectangle())
                    
                }
            }
            .overlay(alignment: .top){
                if(toggleStreak){
                    ZStack{

                        Rectangle()
                            .frame(height: 160)
                            .opacity(0)
                            .glassEffect(in: RoundedRectangle(cornerRadius: 30))
                            .padding(.horizontal, 20)
                            .blur(radius:1.2)
                        
                        VStack(alignment: .leading){
                            Text("Weekly Streak")
                                .font(.system(size: 20) .bold())
                                .padding(.leading, 40)
                            
                            HStack(spacing: 10){
                                let weekdays: [String] = [
                                    "Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"
                                ]
                                ForEach(0..<7, id: \.self){ i in
                                    VStack{
                                        ZStack{
                                            Rectangle()
                                                .frame(width: 35, height: 75)
                                                .cornerRadius(20)
                                                .foregroundStyle(
                                                    LinearGradient(
                                                        colors: [
                                                            Color(hex: "FFD596"),
                                                            Color(hex: "FF9C32")
                                                        ],
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    )
                                                )
                                            Image(systemName: "flame.fill")
                                                .foregroundStyle(Color.white)
                                        }
                                        
                                        Text(weekdays[i])
                                    }
                                }
                            }
                            .padding(.horizontal, 40)
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .move(edge: .leading)).combined(with: .scale).combined(with: .opacity))
                }
                
            }
            .background(Color(hex: "F3F3F3"))
        }
    }
    
}

#Preview {
    DashboardView()
}
