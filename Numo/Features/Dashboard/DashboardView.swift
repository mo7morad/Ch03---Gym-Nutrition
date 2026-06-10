import SwiftUI
import SwiftData
import UIKit

struct DashboardView: View {
    @Query(sort: \LoggedMeal.timestamp, order: .reverse) private var persistedMeals: [LoggedMeal]
    @Query private var profiles: [UserProfile]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @State private var viewModel = DashboardViewModel()
    @State private var toggleStreak = false
    @State private var toggleSettings = false
    @State private var mealLogPresentation: MealLogPresentation?
    @State private var streakCount = 3

    private enum MealLogPresentation: Identifiable {
        case camera
        case gallery

        var id: Self { self }
    }

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
        viewModel.dailyMeals(from: persistedMeals)
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
                        .accessibilityLabel(AccessibilityLabels.appMascot)

                    CaloriesMacrosView(
                        calories: Int(consumedToday.calories.rounded()),
                        caloriesTarget: Int(
                            nutritionGoal.dailyCalories.rounded()
                        ),
                        macros: [
                            "Protein": Int(consumedToday.protein.rounded()),
                            "Carbs": Int(consumedToday.carbs.rounded()),
                            "Fat": Int(consumedToday.fat.rounded()),
                            "Fiber": Int(consumedToday.fiber.rounded())
                        ],
                        macrosTarget: [
                            "Protein": Int(
                                nutritionGoal.proteinGrams.rounded()
                            ),
                            "Carbs": Int(nutritionGoal.carbsGrams.rounded()),
                            "Fat": Int(nutritionGoal.fatGrams.rounded()),
                            "Fiber": Int(nutritionGoal.fibreGrams.rounded())
                        ]
                    )

                    MealListSectionView(dailyMeals: todaysMeals)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation(.spring()) {
                            toggleStreak.toggle()
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "flame.fill")
                            Text("\(streakCount)")
                        }
                    }
                    .accessibilityLabel(AccessibilityLabels.Dashboard.streakButton(count: streakCount))
                    .accessibilityHint(AccessibilityLabels.Dashboard.streakButtonHint(isExpanded: toggleStreak))
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        toggleSettings.toggle()
                    } label: {
                        Image(systemName: "person.fill")
                    }
                    .accessibilityLabel(AccessibilityLabels.Dashboard.settings)
                    .accessibilityHint(AccessibilityLabels.Dashboard.settingsHint())
                }

                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()

                    Menu {
                        Button {
                            mealLogPresentation = .gallery
                        } label: {
                            HStack {
                                Image(
                                    systemName: "photo.fill.on.rectangle.fill"
                                )
                                Text("Choose Photo")
                            }
                        }
                        .accessibilityLabel(AccessibilityLabels.Dashboard.choosePhoto)
                        .accessibilityHint(AccessibilityLabels.Dashboard.choosePhotoHint())

                        Button {
                            mealLogPresentation = .camera
                        } label: {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Take Photo")
                            }
                        }
                        .accessibilityLabel(AccessibilityLabels.Dashboard.takePhoto)
                        .accessibilityHint(AccessibilityLabels.Dashboard.takePhotoMenuHint())
                    } label: {
                        Label("Add Meal", systemImage: "plus.circle.fill")
                    }
                    .accessibilityLabel(AccessibilityLabels.Dashboard.addMeal)
                    .accessibilityHint(AccessibilityLabels.Dashboard.addMealHint())
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
                            .accessibilityHidden(true)

                        VStack(alignment: .leading) {
                            Text("Weekly Streak")
                                .font(.system(size: 20).bold())
                                .padding(.leading, 40)
                                .accessibilityAddTraits(.isHeader)

                            HStack(spacing: 10) {
                                let weekdays = [
                                    "Mo",
                                    "Tu",
                                    "We",
                                    "Th",
                                    "Fr",
                                    "Sa",
                                    "Su"
                                ]
                                ForEach(0..<7, id: \.self) { i in
                                    VStack {
                                        ZStack {
                                            Rectangle()
                                                .frame(width: 35, height: 75)
                                                .cornerRadius(20)
                                                .foregroundStyle(
                                                    i < streakCount
                                                    ? LinearGradient(colors: [Color(hex: "FFD596"),Color(hex: "FF9C32")],startPoint: .top,endPoint: .bottom)
                                                    : LinearGradient(colors: [Color.white, Color.white],startPoint: .top,endPoint: .bottom)
                                                )
                                            Image(systemName: "flame.fill")
                                                .font(Font.system(size: 22))
                                                .foregroundStyle(
                                                    i < streakCount
                                                    ? Color.white
                                                    : Color(hex: "B8B8B8")
                                                )
                                        }
                                        .accessibilityHidden(true)

                                        Text(weekdays[i])
                                            .bold()
                                            .foregroundStyle(
                                                i<streakCount
                                                ? Color(hex: "FF8400")
                                                : Color(hex: "5F5F5F")
                                            )
                                    }
                                    .accessibilityElement(children: .combine)
                                    .accessibilityLabel(
                                        AccessibilityLabels.Dashboard.streakDay(
                                            weekdays[i],
                                            isActive: i < streakCount
                                        )
                                    )
                                }
                            }
                            .padding(.horizontal, 40)
                            .accessibilityElement(children: .contain)
                            .accessibilityLabel(
                                AccessibilityLabels.Dashboard.weeklyStreakSummary(activeDays: streakCount)
                            )
                        }
                    }
                    .contentShape(Rectangle())
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel(AccessibilityLabels.Dashboard.weeklyStreak)
                    .onTapGesture {
                        // empty to consume a tap so it doesn't close when the box is tapped
                    }
                    .transition(
                        .move(edge: .top)
                        .combined(with: .move(edge: .leading))
                        .combined(with: .scale)
                        .combined(with: .opacity)
                    )
                }
            }
            .fullScreenCover(item: $mealLogPresentation) { presentation in
                MealLogView(
                    onComplete: { meal in
                        viewModel.saveMeal(meal, context: modelContext)
                        mealLogPresentation = nil
                    },
                    onCancel: { mealLogPresentation = nil },
                    startsWithCamera: presentation == .camera,
                    startsWithGallery: presentation == .gallery
                )
            }
            .onTapGesture {
                if toggleStreak {
                    withAnimation(.spring()) { toggleStreak.toggle() }
                }
            }
            .sheet(isPresented: $toggleSettings) {
                Settings()
            }
            .background(Color(hex: "F3F3F3"))
            .onAppear {
                viewModel.refreshCurrentDate()
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    viewModel.refreshCurrentDate()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
                viewModel.refreshCurrentDate()
            }
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(PersistenceController.shared.container)
}
