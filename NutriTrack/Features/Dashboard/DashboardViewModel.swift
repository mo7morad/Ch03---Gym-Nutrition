import Foundation

@Observable
@MainActor
final class DashboardViewModel {
    var isPresentingMealLog = false

    func presentMealLog() {
        isPresentingMealLog = true
    }

    func dismissMealLog() {
        isPresentingMealLog = false
    }
}
