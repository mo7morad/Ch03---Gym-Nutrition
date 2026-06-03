import Foundation
import SwiftData

// PersistenceController owns the single ModelContainer for the app.
// ModelContainer is SwiftData's equivalent of Core Data's NSPersistentContainer —
// it manages the on-disk schema and vends ModelContext objects for reading/writing.
//
// Why a singleton? The app needs exactly one container. Multiple containers over the
// same schema would create separate database files and break data consistency.
final class PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer

    // mainContext runs on the main actor and is used for all UI-driven reads and writes.
    // @MainActor here matches the isolation on ModelContainer.mainContext so the compiler
    // doesn't complain when this is called from a @MainActor context (e.g. the ViewModel).
    @MainActor
    var mainContext: ModelContext { container.mainContext }

    private init() {
        do {
            container = try ModelContainer(for: UserProfile.self)
        } catch {
            // fatalError is appropriate here: if SwiftData cannot set up the database (SwiftData).
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
