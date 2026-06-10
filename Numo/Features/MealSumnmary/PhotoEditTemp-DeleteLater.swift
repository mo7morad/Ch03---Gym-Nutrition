////
////  PhotoEditResult.swift
////  Numo
////
////  Created by David Paul Ong on 08/06/26.
////
//
//import SwiftUI
//
//struct PhotoEditResult: View {
//    @Environment(\.dismiss) private var dismiss
//    
//    @State private var navigateToSummary = false
//    @State var viewModel: MealLogViewModel
//    
//    enum Context {
//        case newMeal
//        case loggedMeal
//    }
//    
//    let meal: MealEntry
//    var context: Context = .newMeal
//    var onDone: () -> Void = {}
//    var onDismiss: () -> Void = {}
//        
//    var body: some View {
//        NavigationStack{
//            VStack {
//                ForEach(meal.items){ item in
//                    Text(item.name)
//                }
//            }.toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button(action: close) {
//                        Image(systemName: "xmark")
//                            .fontWeight(.semibold)
//                            .foregroundStyle(Color(hex: "181818"))
//                    }
//                    .accessibilityLabel(context == .loggedMeal ? "Back" : "Close")
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button{
//                        navigateToSummary = true
//                    } label: {
//                        Image(systemName: "checkmark")
//                            .fontWeight(.semibold)
//                            .foregroundStyle(Color(hex: "181818"))
//                            
//                    }
//                    .navigationDestination(isPresented: $navigateToSummary){
//                        PhotoResultSummary(
//                            meal: meal,
//                            context: .newMeal,
//                            onDone: {
//                                onDone()
//                            },
//                            onDismiss: {
//                                onDismiss()
//                            }
//                        )
//                    }
//                    .accessibilityLabel(context == .loggedMeal ? "Back" : "Close")
//                }
//            }
//        }
//        
//    }
//    
//    private func close() {
//        if context == .loggedMeal {
//            dismiss()
//        } else {
//            onDismiss()
//        }
//    }
//}
//
//
//
//#Preview {
//    PhotoEditResult(
//        meal: MealEntry(id: UUID(), timestamp: .now, items: [
//            FoodItemModel(
//                id: UUID(),
//                name: "rice, white, cooked",
//                nutrition: NutritionInfo(
//                    foodName: "Rice",
//                    calories: 215,
//                    protein: 5,
//                    carbs: 45,
//                    fat: 2,
//                    fiber: 4,
//                    servingSize: "1 cup"
//                )
//            ),
//            FoodItemModel(
//                id: UUID(),
//                name: "chicken, leg, cooked",
//                nutrition: NutritionInfo(
//                    foodName: "Chicken leg",
//                    calories: 320,
//                    protein: 18,
//                    carbs: 20,
//                    fat: 20,
//                    fiber: 1,
//                    servingSize: "1 leg"
//                )
//            )
//
//        ])
//    )
//}
////
////  PhotoEditResult.swift
////  Numo
////
////  Created by David Paul Ong on 08/06/26.
////
//
//import SwiftUI
//
//struct PhotoEditResult: View {
//    @Environment(\.dismiss) private var dismiss
//    
//    @State private var navigateToSummary = false
//    @State var viewModel: MealLogViewModel
//    
//    enum Context {
//        case newMeal
//        case loggedMeal
//    }
//    
//    let meal: MealEntry
//    var context: Context = .newMeal
//    var onDone: () -> Void = {}
//    var onDismiss: () -> Void = {}
//        
//    var body: some View {
//        NavigationStack{
//            VStack {
//                ForEach(meal.items){ item in
//                    Text(item.name)
//                }
//            }.toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button(action: close) {
//                        Image(systemName: "xmark")
//                            .fontWeight(.semibold)
//                            .foregroundStyle(Color(hex: "181818"))
//                    }
//                    .accessibilityLabel(context == .loggedMeal ? "Back" : "Close")
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button{
//                        navigateToSummary = true
//                    } label: {
//                        Image(systemName: "checkmark")
//                            .fontWeight(.semibold)
//                            .foregroundStyle(Color(hex: "181818"))
//                            
//                    }
//                    .navigationDestination(isPresented: $navigateToSummary){
//                        PhotoResultSummary(
//                            meal: meal,
//                            context: .newMeal,
//                            onDone: {
//                                onDone()
//                            },
//                            onDismiss: {
//                                onDismiss()
//                            }
//                        )
//                    }
//                    .accessibilityLabel(context == .loggedMeal ? "Back" : "Close")
//                }
//            }
//        }
//        
//    }
//    
//    private func close() {
//        if context == .loggedMeal {
//            dismiss()
//        } else {
//            onDismiss()
//        }
//    }
//}
//
//
//
//#Preview {
//    PhotoEditResult(
//        meal: MealEntry(id: UUID(), timestamp: .now, items: [
//            FoodItemModel(
//                id: UUID(),
//                name: "rice, white, cooked",
//                nutrition: NutritionInfo(
//                    foodName: "Rice",
//                    calories: 215,
//                    protein: 5,
//                    carbs: 45,
//                    fat: 2,
//                    fiber: 4,
//                    servingSize: "1 cup"
//                )
//            ),
//            FoodItemModel(
//                id: UUID(),
//                name: "chicken, leg, cooked",
//                nutrition: NutritionInfo(
//                    foodName: "Chicken leg",
//                    calories: 320,
//                    protein: 18,
//                    carbs: 20,
//                    fat: 20,
//                    fiber: 1,
//                    servingSize: "1 leg"
//                )
//            )
//
//        ])
//    )
//}
