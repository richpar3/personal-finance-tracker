import SwiftUI
import Charts

struct CategorySpendingChart: View {
    @ObservedObject var viewModel: FinanceViewModel
    @State private var selectedSlice: TransactionCategory?

    private var chartData: [(category: TransactionCategory, amount: Double, percentage: Double)] {
        Array(viewModel.expensesByCategory.prefix(6))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending by Category")
                .font(.headline)
                .fontWeight(.semibold)

            if chartData.isEmpty {
                emptyChart
            } else {
                HStack(spacing: 20) {
                    // Donut chart
                    ZStack {
                        Chart(chartData, id: \.category.id) { item in
                            SectorMark(
                                angle: .value("Amount", item.amount),
                                innerRadius: .ratio(0.55),
                                outerRadius: selectedSlice == item.category ? .ratio(1.0) : .ratio(0.9),
                                angularInset: 2
                            )
                            .foregroundStyle(item.category.color)
                            .cornerRadius(4)
                        }
                        .chartAngleSelection(value: .constant(nil))
                        .frame(width: 140, height: 140)

                        // Center label
                        VStack(spacing: 2) {
                            if let selected = selectedSlice, let item = chartData.first(where: { $0.category == selected }) {
                                Text("\(Int(item.percentage))%")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                Text(selected.rawValue.components(separatedBy: " ").first ?? "")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            } else {
                                Text("\(Int(viewModel.totalExpenses / 1000 * 10) / 10)k")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                Text("Total")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    // Legend
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(chartData, id: \.category.id) { item in
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedSlice = selectedSlice == item.category ? nil : item.category
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(item.category.color)
                                        .frame(width: 8, height: 8)
                                    Text(item.category.rawValue)
                                        .font(.caption)
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                    Spacer()
                                    Text(formatCurrency(item.amount))
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    private var emptyChart: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "chart.pie")
                    .font(.system(size: 36))
                    .foregroundStyle(.secondary)
                Text("No spending data")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 20)
            Spacer()
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
