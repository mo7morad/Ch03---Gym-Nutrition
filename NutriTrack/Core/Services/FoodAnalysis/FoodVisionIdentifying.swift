// FILE: NutriTrack/Core/Services/FoodAnalysis/FoodVisionIdentifying.swift

import UIKit

protocol FoodVisionIdentifying: Sendable {
    func identify(image: UIImage) async throws -> [IdentifiedFood]
}
