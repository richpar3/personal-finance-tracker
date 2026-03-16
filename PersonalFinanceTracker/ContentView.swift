import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @State private var selectedTab: Int = 0
    @State private var showAddTransaction = false

    var body: some View {
        ZStack(alignment: .bottom) {
            if viewModel.isDemoMode {
                demoBanner
                    .zIndex(1)
                    .frame(maxHeight: .infinity, alignment: .top)
            }

            TabView(selection: $selectedTab) {
                DashboardView(viewModel: viewModel)
                    .tag(0)

                TransactionListView(viewModel: viewModel)
                    .tag(1)

                ChartsView(viewModel: viewModel)
                    .tag(2)

                AccountsView(viewModel: viewModel)
                    .tag(3)
            }

            // Custom Tab Bar
            customTabBar
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView(viewModel: viewModel)
        }
    }

    // MARK: - Custom Tab Bar

    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabBarButton(icon: "house.fill", label: "Overview", tag: 0)
            tabBarButton(icon: "list.bullet.rectangle.fill", label: "Transactions", tag: 1)

            // Center FAB
            Button {
                showAddTransaction = true
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.25, green: 0.40, blue: 0.95),
                                    Color(red: 0.55, green: 0.25, blue: 0.90)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .shadow(
                            color: Color(red: 0.25, green: 0.40, blue: 0.95).opacity(0.4),
                            radius: 12, x: 0, y: 4
                        )
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                }
                .offset(y: -12)
            }

            tabBarButton(icon: "chart.bar.fill", label: "Analytics", tag: 2)
            tabBarButton(icon: "creditcard.fill", label: "Accounts", tag: 3)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: -4)
        )
    }

    private var demoBanner: some View {
        HStack(spacing: 6) {
            Image(systemName: "eye.slash.fill")
                .font(.caption)
            Text("Demo Mode — your real data is hidden")
                .font(.caption)
                .fontWeight(.medium)
            Spacer()
            Button {
                viewModel.setDemoMode(false)
            } label: {
                Text("Exit")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.white.opacity(0.25))
                    .clipShape(Capsule())
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.orange)
        .ignoresSafeArea(edges: .top)
    }

    private func tabBarButton(icon: String, label: String, tag: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                selectedTab = tag
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: selectedTab == tag ? .bold : .regular))
                    .foregroundStyle(
                        selectedTab == tag
                            ? Color(red: 0.25, green: 0.40, blue: 0.95)
                            : Color(.systemGray3)
                    )
                Text(label)
                    .font(.system(size: 10, weight: selectedTab == tag ? .semibold : .regular))
                    .foregroundStyle(
                        selectedTab == tag
                            ? Color(red: 0.25, green: 0.40, blue: 0.95)
                            : Color(.systemGray3)
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 2)
        }
    }
}
