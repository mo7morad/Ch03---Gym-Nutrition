import Foundation

struct AppDependencies {
    let foodAnalysisService: any FoodAnalysisService

    // Production
    static let live = AppDependencies(
        foodAnalysisService: FoodAnalysisServiceLive.makeDefault()
    )

    // Development / no API keys yet
    static let mock = AppDependencies(
        foodAnalysisService: FoodAnalysisServiceMock()
    )
}
