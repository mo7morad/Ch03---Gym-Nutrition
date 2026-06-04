// FILE: NutriTrack/App/AppDependencies.swift

import Foundation

struct AppDependencies {
    let foodAnalysisService: any FoodAnalysisService
    let mealPhotoStorage: any MealPhotoStorage

    static let live = AppDependencies(
        foodAnalysisService: FoodAnalysisServiceLive.makeDefault(),
        mealPhotoStorage: ImageProcessingService()
    )

    static let mock = AppDependencies(
        foodAnalysisService: FoodAnalysisServiceMock(),
        mealPhotoStorage: ImageProcessingService()
    )
}
