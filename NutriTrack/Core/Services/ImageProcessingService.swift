// FILE: NutriTrack/Core/Services/ImageProcessingService.swift

import UIKit

// MARK: - Service

enum ImageProcessingService {

    /// Saves a meal photo to the app documents directory. Returns the filename used as `MealEntry.photoRef`.
    static func saveMealPhoto(_ image: UIImage) throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.85) else {
            throw ImageProcessingError.encodingFailed
        }

        let filename = "\(UUID().uuidString).jpg"
        let url = mealPhotosDirectory().appendingPathComponent(filename)
        try data.write(to: url, options: .atomic)
        return filename
    }

    /// Loads a previously saved meal photo from `photoRef` (filename in MealPhotos).
    static func loadMealPhoto(from photoRef: String) -> UIImage? {
        let url = mealPhotosDirectory().appendingPathComponent(photoRef)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    private static func mealPhotosDirectory() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directory = documents.appendingPathComponent("MealPhotos", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}

// MARK: - Errors

enum ImageProcessingError: LocalizedError {
    case encodingFailed

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Could not save the meal photo."
        }
    }
}
