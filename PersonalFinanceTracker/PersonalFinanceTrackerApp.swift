import SwiftUI

@main
struct PersonalFinanceTrackerApp: App {
    @StateObject private var viewModel = FinanceViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
