import SwiftUI

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    
    let mockMeal1 = MealEntry(id: UUID(), timestamp: Date(), photoRef: nil, items: [FoodItem(id: UUID(), name: "Fried Rice", nutrition: NutritionInfo(calories: 350, proteinGrams: 10, carbsGrams: 45, fibreGrams: 3, fatGrams: 12))])
    let mockMeal2 = MealEntry(id: UUID(), timestamp: Date(), photoRef: nil, items: [FoodItem(id: UUID(), name: "Boiled Egg", nutrition: NutritionInfo(calories: 70, proteinGrams: 6, carbsGrams: 0, fibreGrams: 0, fatGrams: 5))])
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack {
                    Image("AppCharacter")
                        .resizable()
                        .frame(width: 220, height: 150)
                        .padding(.top, 40)
                    
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
                    
                    CaloriesMacrosView()
                    
                    HStack{
                        Text("Today's Meal")
                            .font(.system(size: 28, weight: .bold))
                            .padding(.leading, 15)
                            .padding(.top, 20)
                        Spacer()
                    }
                    
                    MealListSectionView(dailyMeals: [mockMeal1, mockMeal2])
                    
                }
            }
            .toolbar{
                ToolbarItemGroup(placement: .topBarLeading) {
                    HStack{
                        Image(systemName: "flame")
                    }
                    Text("1")
                        .offset(x: -12)
                }
                
                
                ToolbarItem(placement: .topBarTrailing){
                    Image(systemName: "person.fill")
                }
                
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
            .background(Color(hex: "F3F3F3"))
        }
    }
    
}

#Preview {
    DashboardView()
}
