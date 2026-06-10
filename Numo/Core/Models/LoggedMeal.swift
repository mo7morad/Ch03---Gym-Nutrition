import Foundation
import SwiftData

/// SwiftData persistence record for a logged meal.
@Model
final class LoggedMeal {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var photoRef: String?
    var mealName: String?
    var itemsData: Data

    init(
        id: UUID,
        timestamp: Date,
        photoRef: String?,
        mealName: String?,
        items: [FoodItemModel]
    ) {
        self.id = id
        self.timestamp = timestamp
        self.photoRef = photoRef
        self.mealName = mealName
        self.itemsData = (try? JSONEncoder().encode(items)) ?? Data()
    }
}
