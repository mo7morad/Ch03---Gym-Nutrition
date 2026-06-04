// FILE: NutriTrack/Core/Services/ImageProcessingService.swift

import Foundation
import SwiftUI
import UIKit

// MARK: - Protocol

/// Persists meal photos to the app's Documents directory.
/// `MealEntry.photoRef` stores the returned filename, not the full path.
protocol MealPhotoStorage: Sendable {
    func saveMealPhoto(_ image: UIImage) throws -> String
    func loadMealPhoto(from photoRef: String) -> UIImage?
    func deleteMealPhoto(at photoRef: String) throws
}

// MARK: - Implementation

struct ImageProcessingService: MealPhotoStorage, Sendable {
    private let fileManager: FileManager
    private let compressionQuality: CGFloat

    init(
        fileManager: FileManager = .default,
        compressionQuality: CGFloat = 0.8
    ) {
        self.fileManager = fileManager
        self.compressionQuality = compressionQuality
    }

    /// Saves a JPEG to `Documents/MealPhotos/` and returns the filename for `photoRef`.
    func saveMealPhoto(_ image: UIImage) throws -> String {
        guard let data = image.jpegData(compressionQuality: compressionQuality) else {
            throw ImageProcessingError.encodingFailed
        }

        let directory = try mealPhotosDirectory()
        let filename = UUID().uuidString + ".jpg"
        let fileURL = directory.appendingPathComponent(filename)

        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw ImageProcessingError.writeFailed(underlying: error)
        }

        return filename
    }

    func loadMealPhoto(from photoRef: String) -> UIImage? {
        guard let directory = try? mealPhotosDirectory() else { return nil }

        let fileURL = directory.appendingPathComponent(photoRef)
        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL) else {
            return nil
        }

        return UIImage(data: data)
    }

    func deleteMealPhoto(at photoRef: String) throws {
        guard let directory = try? mealPhotosDirectory() else { return }

        let fileURL = directory.appendingPathComponent(photoRef)
        guard fileManager.fileExists(atPath: fileURL.path) else { return }

        try fileManager.removeItem(at: fileURL)
    }

    // MARK: - Private

    private func mealPhotosDirectory() throws -> URL {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directory = documents.appendingPathComponent("MealPhotos", isDirectory: true)

        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }

        return directory
    }
}

// MARK: - Errors

enum ImageProcessingError: LocalizedError {
    case encodingFailed
    case writeFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Could not prepare the photo for saving."
        case .writeFailed:
            return "Could not save the meal photo."
        }
    }
}

// MARK: - SwiftUI Environment Wiring

struct MealPhotoStorageKey: EnvironmentKey {
    static let defaultValue: any MealPhotoStorage = ImageProcessingService()
}

extension EnvironmentValues {
    var mealPhotoStorage: any MealPhotoStorage {
        get { self[MealPhotoStorageKey.self] }
        set { self[MealPhotoStorageKey.self] = newValue }
    }
}
