// FILE: NutriTrack/App/AppDependencies.swift

import Foundation

struct AppDependencies {
    let foodAnalysisService: any FoodAnalysisService

    static let live = AppDependencies(
        foodAnalysisService: FoodAnalysisServiceLive.makeDefault()
    )

    static let mock = AppDependencies(
        foodAnalysisService: FoodAnalysisServiceMock()
    )
}
