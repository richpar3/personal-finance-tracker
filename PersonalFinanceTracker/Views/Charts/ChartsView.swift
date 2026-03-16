import SwiftUI
import Charts

struct ChartsView: View {
    @ObservedObject var viewModel: FinanceViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Period selector
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
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // Summary stats
                    summaryStats
                        .padding(.horizontal, 20)

                    // Net Worth Trend
                    NetWorthTrendChart(viewModel: viewModel)
                        .padding(.horizontal, 20)

                    // Category donut
                    CategorySpendingChart(viewModel: viewModel)
                        .padding(.horizontal, 20)

                    // Spending trend
                    SpendingTrendChart(viewModel: viewModel)
                        .padding(.horizontal, 20)

                    // Income vs Expenses bar
                    incomeVsExpensesChart
                        .padding(.horizontal, 20)

                    // Top categories list
                    topCategoriesBreakdown
                        .padding(.horizontal, 20)

                    Spacer(minLength: 100)
                }
                .padding(.top, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Summary Stats

    private var summaryStats: some View {
        HStack(spacing: 12) {
            statCard(
                title: "Cash Flow",
                value: viewModel.cashFlow,
                icon: "arrow.left.arrow.right",
                isPositive: viewModel.cashFlow >= 0
            )
            .frame(maxWidth: .infinity)

            statCard(
                title: "Savings Rate",
                value: viewModel.savingsRate,
                icon: "percent",
                isPositive: viewModel.savingsRate >= 10,
                isCurrency: false
            )
            .frame(maxWidth: .infinity)
        }
    }

    private func statCard(title: String, value: Double, icon: String, isPositive: Bool, isCurrency: Bool = true) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isPositive ? Color(red: 0.15, green: 0.75, blue: 0.55) : Color(red: 1.0, green: 0.35, blue: 0.35))
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if isCurrency {
                Text(formatCurrency(abs(value)))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(isPositive ? Color(red: 0.15, green: 0.75, blue: 0.55) : Color(red: 1.0, green: 0.35, blue: 0.35))
            } else {
                Text("\(Int(value))%")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(isPositive ? Color(red: 0.15, green: 0.75, blue: 0.55) : Color(red: 1.0, green: 0.35, blue: 0.35))
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    // MARK: - Income vs Expenses

    private var incomeVsExpensesChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Income vs Expenses")
                .font(.headline)
                .fontWeight(.semibold)

            Chart {
                ForEach(viewModel.monthlyTrend) { data in
                    BarMark(
                        x: .value("Month", data.month),
                        y: .value("Amount", data.income)
                    )
                    .foregroundStyle(Color(red: 0.15, green: 0.75, blue: 0.55).gradient)
                    .cornerRadius(6)
                    .annotation(position: .top) {
                        if data.income > 0 {
                            Text("$\(Int(data.income / 1000))k")
                                .font(.system(size: 8))
                                .foregroundStyle(.secondary)
                        }
                    }

                    BarMark(
                        x: .value("Month", data.month),
                        y: .value("Amount", -data.expenses)
                    )
                    .foregroundStyle(Color(red: 1.0, green: 0.35, blue: 0.35).gradient)
                    .cornerRadius(6)
                }

                RuleMark(y: .value("Zero", 0))
                    .foregroundStyle(Color(.systemGray4))
                    .lineStyle(StrokeStyle(lineWidth: 1))
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text("$\(Int(abs(doubleValue) / 1000))k")
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

            // Legend
            HStack(spacing: 16) {
                Spacer()
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(red: 0.15, green: 0.75, blue: 0.55))
                        .frame(width: 12, height: 12)
                    Text("Income")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(red: 1.0, green: 0.35, blue: 0.35))
                        .frame(width: 12, height: 12)
                    Text("Expenses")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    // MARK: - Top Categories Breakdown

    private var topCategoriesBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category Breakdown")
                .font(.headline)
                .fontWeight(.semibold)

            if viewModel.expensesByCategory.isEmpty {
                Text("No expense data for this period")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                ForEach(viewModel.expensesByCategory, id: \.category.id) { item in
                    CategoryProgressRow(item: item, total: viewModel.totalExpenses)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Category Progress Row

struct CategoryProgressRow: View {
    let item: (category: TransactionCategory, amount: Double, percentage: Double)
    let total: Double

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(item.category.color.opacity(0.15))
                            .frame(width: 28, height: 28)
                        Image(systemName: item.category.icon)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(item.category.color)
                    }
                    Text(item.category.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 1) {
                    Text(formatCurrency(item.amount))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("\(Int(item.percentage))%")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray6))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(item.category.color)
                        .frame(width: max(0, geo.size.width * (item.percentage / 100)), height: 6)
                }
            }
            .frame(height: 6)
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}
