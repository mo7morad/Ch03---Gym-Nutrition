import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var profiles: [UserProfile]

    @State private var toggleStreak: Bool = true
    @State private var showMealLog = false
    @State private var dailyMeals: [MealEntry] = []

    private var nutritionGoal: NutritionGoal {
        guard let profile = profiles.first else {
            return NutritionGoal(
                dailyCalories: 2550,
                proteinGrams: 191,
                carbsGrams: 255,
                fibreGrams: 36,
                fatGrams: 85
            )
        }
        return NutritionCalculator.calculate(for: profile)
    }

    private var todaysMeals: [MealEntry] {
        dailyMeals.meals(on: .now)
    }

    private var consumedToday: NutritionInfo {
        todaysMeals.totalNutrition
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Image("AppCharacter")
                        .resizable()
                        .frame(width: 220, height: 150)
                        .padding(.top, 40)

                    CaloriesMacrosView(
                        calories: Int(consumedToday.calories.rounded()),
                        caloriesTarget: Int(nutritionGoal.dailyCalories.rounded()),
                        macros: [
                            "Protein": Int(consumedToday.protein.rounded()),
                            "Carbs": Int(consumedToday.carbs.rounded()),
                            "Fat": Int(consumedToday.fat.rounded()),
                            "Fiber": Int(consumedToday.fiber.rounded())
                        ],
                        macrosTarget: [
                            "Protein": Int(nutritionGoal.proteinGrams.rounded()),
                            "Carbs": Int(nutritionGoal.carbsGrams.rounded()),
                            "Fat": Int(nutritionGoal.fatGrams.rounded()),
                            "Fiber": Int(nutritionGoal.fibreGrams.rounded())
                        ]
                    )

                    MealListSectionView(dailyMeals: todaysMeals)
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

                    Menu {
                        Button {} label: {
                            HStack {
                                Image(systemName: "photo.fill.on.rectangle.fill")
                                Text("Choose Photo")
                            }
                        }

                        Button {
                            showMealLog = true
                        } label: {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Take Photo")
                            }
                        }
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
                                let weekdays = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
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
                                                .foregroundStyle(.white)
                                        }

                                        Text(weekdays[i])
                                    }
                                }
                            }
                            .padding(.horizontal, 40)
                        }
                    }
                    .transition(
                        .move(edge: .top)
                            .combined(with: .move(edge: .leading))
                            .combined(with: .scale)
                            .combined(with: .opacity)
                    )
                }
            }
            .fullScreenCover(isPresented: $showMealLog) {
                MealLogView(
                    onComplete: { meal in
                        dailyMeals.insert(meal, at: 0)
                        showMealLog = false
                    },
                    onCancel: { showMealLog = false },
                    startsWithCamera: true
                )
            }
            .background(Color(hex: "F3F3F3"))
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(PersistenceController.shared.container)
}
