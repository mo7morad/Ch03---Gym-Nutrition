import Foundation
import SwiftData

// UserProfile is a @Model class (not a struct) because SwiftData — Apple's persistence
// framework — can only manage reference types. The @Model macro auto-generates all the
// boilerplate needed to store and fetch this object from the local database.
@Model
final class UserProfile {
    var name: String
    var age: Int
    var sex: Sex
    var weightKg: Double
    var heightCm: Double
    var goal: Goal

    // Enums stored in a @Model class must be Codable so SwiftData can serialize them.
    enum Sex: String, Codable {
        case male, female
    }

    enum Goal: String, Codable {
        case lose, maintain, gain
    }

    init(name: String, age: Int, sex: Sex, weightKg: Double, heightCm: Double, goal: Goal) {
        self.name = name
        self.age = age
        self.sex = sex
        self.weightKg = weightKg
        self.heightCm = heightCm
        self.goal = goal
    }
}
