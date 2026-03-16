import SwiftUI
import Charts

struct DashboardView: View {
    @ObservedObject var viewModel: FinanceViewModel
    @State private var showAddTransaction = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Period selector
                    periodSelector

                    // Net Worth Card
                    NetWorthCard(viewModel: viewModel)
                        .padding(.horizontal, 20)

                    // Cash Flow Stats
                    cashFlowRow
                        .padding(.horizontal, 20)

                    // Mini Bar Chart
                    miniCashFlowChart
                        .padding(.horizontal, 20)

                    // Account Balances
                    accountsSection
                        .padding(.horizontal, 20)

                    // Recent Transactions
                    recentTransactionsSection
                        .padding(.horizontal, 20)

                    Spacer(minLength: 100)
                }
                .padding(.top, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Overview")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddTransaction = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.25, green: 0.40, blue: 0.95))
                                .frame(width: 36, height: 36)
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddTransaction) {
                AddTransactionView(viewModel: viewModel)
            }
        }
    }

    // MARK: - Period Selector

    private var periodSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FinanceViewModel.TimePeriod.allCases, id: \.self) { period in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.selectedPeriod = period
                        }
                    } label: {
                        Text(period.rawValue)
                            .font(.subheadline)
                            .fontWeight(viewModel.selectedPeriod == period ? .semibold : .regular)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                viewModel.selectedPeriod == period
                                    ? Color(red: 0.25, green: 0.40, blue: 0.95)
                                    : Color(.systemBackground)
                            )
                            .foregroundStyle(
                                viewModel.selectedPeriod == period ? .white : .secondary
                            )
                            .clipShape(Capsule())
                            .shadow(
                                color: viewModel.selectedPeriod == period
                                    ? Color(red: 0.25, green: 0.40, blue: 0.95).opacity(0.3)
                                    : .clear,
                                radius: 6, x: 0, y: 3
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Cash Flow Row

    private var cashFlowRow: some View {
        HStack(spacing: 12) {
            CashFlowCard(
                title: "Income",
                amount: viewModel.totalIncome,
                icon: "arrow.down.circle.fill",
                isPositive: true
            )
            .frame(maxWidth: .infinity)

            CashFlowCard(
                title: "Expenses",
                amount: viewModel.totalExpenses,
                icon: "arrow.up.circle.fill",
                isPositive: false
            )
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Mini Cash Flow Chart

    private var miniCashFlowChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Cash Flow")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                HStack(spacing: 12) {
                    legendItem(color: Color(red: 0.15, green: 0.75, blue: 0.55), label: "Income")
                    legendItem(color: Color(red: 1.0, green: 0.35, blue: 0.35), label: "Expenses")
                }
            }

            Chart {
                ForEach(viewModel.monthlyTrend) { data in
                    BarMark(
                        x: .value("Month", data.month),
                        y: .value("Income", data.income),
                        width: .ratio(0.4)
                    )
                    .foregroundStyle(Color(red: 0.15, green: 0.75, blue: 0.55).gradient)
                    .cornerRadius(4)
                    .offset(x: -8)

                    BarMark(
                        x: .value("Month", data.month),
                        y: .value("Expenses", data.expenses),
                        width: .ratio(0.4)
                    )
                    .foregroundStyle(Color(red: 1.0, green: 0.35, blue: 0.35).gradient)
                    .cornerRadius(4)
                    .offset(x: 8)
                }
            }
            .frame(height: 160)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text("$\(Int(doubleValue / 1000))k")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                        .foregroundStyle(Color(.systemGray5))
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel()
                        .font(.caption2)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    // MARK: - Accounts Section

    private var accountsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Accounts")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                NavigationLink {
                    AccountsView(viewModel: viewModel)
                } label: {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundStyle(Color(red: 0.25, green: 0.40, blue: 0.95))
                }
            }

            ForEach(viewModel.accounts.prefix(3)) { account in
                AccountRowMini(account: account)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    // MARK: - Recent Transactions

    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                NavigationLink {
                    TransactionListView(viewModel: viewModel)
                } label: {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundStyle(Color(red: 0.25, green: 0.40, blue: 0.95))
                }
            }

            if viewModel.recentTransactions.isEmpty {
                emptyTransactionsState
            } else {
                ForEach(viewModel.recentTransactions) { transaction in
                    TransactionRowView(transaction: transaction)
                    if transaction.id != viewModel.recentTransactions.last?.id {
                        Divider().padding(.leading, 58)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    private var emptyTransactionsState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray.fill")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            Text("No transactions yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button {
                showAddTransaction = true
            } label: {
                Text("Add your first transaction")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(red: 0.25, green: 0.40, blue: 0.95))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

struct AccountRowMini: View {
    let account: Account

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(account.type.color.opacity(0.15))
                    .frame(width: 38, height: 38)
                Image(systemName: account.type.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(account.type.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(account.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(account.type.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(formatCurrency(account.balance))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(account.isLiability ? Color(red: 1.0, green: 0.35, blue: 0.35) : .primary)
                if account.isLiability {
                    Text("Owed")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}
