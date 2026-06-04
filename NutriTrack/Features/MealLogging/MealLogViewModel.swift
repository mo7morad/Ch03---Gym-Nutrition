import Foundation
import UIKit

// MARK: - ViewModel

@Observable
@MainActor
final class MealLogViewModel {

    enum Step {
        case capturing
        case analyzing(UIImage)
        case result([FoodItem], UIImage)
        case failed(UIImage, Error)
    }

    var step: Step = .capturing

    /// Set after a photo is saved on "Done" and cleared once the meal is committed.
    private(set) var uncommittedPhotoRef: String?

    private let analysisService: any FoodAnalysisService
    private let photoStorage: any MealPhotoStorage

    init(
        analysisService: any FoodAnalysisService,
        photoStorage: any MealPhotoStorage = ImageProcessingService()
    ) {
        self.analysisService = analysisService
        self.photoStorage = photoStorage
    }

    // MARK: - Transitions

    func retake() {
        step = .capturing
    }

    func usePhoto(_ image: UIImage) {
        step = .analyzing(image)

        Task {
            do {
                let nutritionInfos = try await analysisService.analyze(image: image)
                let foodItems = nutritionInfos.map {
                    FoodItem(id: UUID(), name: $0.foodName, nutrition: $0)
                }
                step = .result(foodItems, image)
            } catch {
                step = .failed(image, error)
            }
        }
    }

    /// Saves the meal photo to disk and returns a `MealEntry` with `photoRef` set.
    func logMeal() throws -> MealEntry {
        guard case .result(let items, let image) = step else {
            throw MealLogError.noResultToLog
        }

        let photoRef = try photoStorage.saveMealPhoto(image)
        return MealEntry(
            id: UUID(),
            timestamp: .now,
            photoRef: photoRef,
            items: items
        )
    }

    /// Saves the photo, delivers the meal to the caller, and marks it committed on success.
    func confirmAndCommit(_ commit: (MealEntry) -> Void) {
        guard case .result(_, let image) = step else { return }

        do {
            let meal = try confirmMeal()
            markMealCommitted()
            commit(meal)
        } catch {
            step = .failed(image, error)
        }
    }

    func markMealCommitted() {
        uncommittedPhotoRef = nil
    }

    /// Saves the photo and marks it as uncommitted until `markMealCommitted()` is called.
    private func confirmMeal() throws -> MealEntry {
        let meal = try logMeal()
        uncommittedPhotoRef = meal.photoRef
        return meal
    }

    /// Deletes a saved photo that was never committed to the dashboard.
    func cleanupUncommittedPhoto() {
        guard let photoRef = uncommittedPhotoRef else { return }
        try? photoStorage.deleteMealPhoto(at: photoRef)
        uncommittedPhotoRef = nil
    }
}

// MARK: - Step helpers

extension MealLogViewModel.Step {
    var id: String {
        switch self {
        case .capturing:  return "capturing"
        case .analyzing:  return "analyzing"
        case .result:     return "result"
        case .failed:     return "failed"
        }
    }
}

// MARK: - Errors

enum MealLogError: LocalizedError {
    case noResultToLog

    var errorDescription: String? {
        switch self {
        case .noResultToLog:
            return "There is no analyzed meal to save."
        }
    }
}
