import SwiftUI

@main
struct PersonalFinanceTrackerApp: App {
    @StateObject private var viewModel = FinanceViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if viewModel.isLoadingAuth {
                    SplashView()
                } else if viewModel.currentUser == nil {
                    AuthView()
                        .environmentObject(viewModel)
                } else {
                    ContentView()
                        .environmentObject(viewModel)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.currentUser?.id)
            .animation(.easeInOut(duration: 0.3), value: viewModel.isLoadingAuth)
        }
    }
}

// Minimal splash shown while the SDK resolves the initial session
private struct SplashView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.06, green: 0.06, blue: 0.10),
                         Color(red: 0.10, green: 0.12, blue: 0.22)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.25, green: 0.40, blue: 0.95),
                                     Color(red: 0.55, green: 0.25, blue: 0.90)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                ProgressView().tint(.white)
            }
        }
    }
}
