import SwiftUI

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    @State private var toggleStreak: Bool = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Image("AppCharacter")
                        .resizable()
                        .frame(width: 220, height: 150)
                        .padding(.top, 40)

                    CaloriesMacrosView()

                    if viewModel.dailyMeals.isEmpty {
                        ContentUnavailableView(
                            "No Meals Today",
                            systemImage: "fork.knife",
                            description: Text("Tap Add Meal to log your first meal.")
                        )
                        .padding(.vertical, 24)
                    } else {
                        MealListSectionView(dailyMeals: viewModel.dailyMeals)
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        withAnimation(.spring()) {
                            toggleStreak.toggle()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "flame")
                        }
                    }
                    Text("1")
                        .offset(x: -12)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "person.fill")
                }

                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()

                    Button {
                        viewModel.presentMealLog()
                    } label: {
                        Label("Add Meal", systemImage: "plus.circle.fill")
                    }
                    .contentShape(Rectangle())
                }
            }
            .overlay(alignment: .top) {
                if toggleStreak {
                    ZStack {
                        Rectangle()
                            .frame(height: 160)
                            .opacity(0)
                            .glassEffect(in: RoundedRectangle(cornerRadius: 30))
                            .padding(.horizontal, 20)
                            .blur(radius: 1.2)

                        VStack(alignment: .leading) {
                            Text("Weekly Streak")
                                .font(.system(size: 20).bold())
                                .padding(.leading, 40)

                            HStack(spacing: 10) {
                                let weekdays: [String] = [
                                    "Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"
                                ]
                                ForEach(0..<7, id: \.self) { i in
                                    VStack {
                                        ZStack {
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
        .fullScreenCover(isPresented: $viewModel.isPresentingMealLog) {
            MealLogView(
                onComplete: { meal in
                    viewModel.addMeal(meal)
                    viewModel.dismissMealLog()
                },
                onCancel: {
                    viewModel.dismissMealLog()
                }
            )
        }
    }
}

#Preview {
    DashboardView()
        .environment(\.foodAnalysisService, FoodAnalysisServiceMock())
        .environment(\.mealPhotoStorage, ImageProcessingService())
}
