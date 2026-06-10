import Foundation

extension LoggedMeal {
    var mealEntry: MealEntry {
        let items = (try? JSONDecoder().decode([FoodItemModel].self, from: itemsData)) ?? []
        return MealEntry(
            id: id,
            timestamp: timestamp,
            photoRef: photoRef,
            mealName: mealName,
            items: items
        )
    }

    static func make(from entry: MealEntry) -> LoggedMeal {
        LoggedMeal(
            id: entry.id,
            timestamp: entry.timestamp,
            photoRef: entry.photoRef,
            mealName: entry.mealName,
            items: entry.items
        )
    }
}
