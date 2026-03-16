import SwiftUI
import Charts

struct SpendingTrendChart: View {
    @ObservedObject var viewModel: FinanceViewModel
    @State private var selectedPoint: FinanceViewModel.DailySpending?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Daily Spending")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text("Last 30 Days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if viewModel.dailySpending.allSatisfy({ $0.amount == 0 }) {
                emptyState
            } else {
                Chart(viewModel.dailySpending) { day in
                    AreaMark(
                        x: .value("Day", day.date),
                        y: .value("Amount", day.amount)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.25, green: 0.40, blue: 0.95).opacity(0.3),
                                Color(red: 0.25, green: 0.40, blue: 0.95).opacity(0.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value("Day", day.date),
                        y: .value("Amount", day.amount)
                    )
                    .foregroundStyle(Color(red: 0.25, green: 0.40, blue: 0.95))
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .interpolationMethod(.catmullRom)

                    if let selected = selectedPoint, selected.id == day.id {
                        PointMark(
                            x: .value("Day", day.date),
                            y: .value("Amount", day.amount)
                        )
                        .foregroundStyle(Color(red: 0.25, green: 0.40, blue: 0.95))
                        .symbolSize(80)
                    }
                }
                .frame(height: 160)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 7)) { value in
                        AxisValueLabel(format: .dateTime.day())
                            .font(.caption2)
                    }
                    AxisMarks(values: .stride(by: .day, count: 7)) {
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                            .foregroundStyle(Color(.systemGray5))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text("$\(Int(doubleValue))")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                            .foregroundStyle(Color(.systemGray5))
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            Text("No spending data")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
    }
}

// MARK: - Net Worth Trend Chart

struct NetWorthTrendChart: View {
    @ObservedObject var viewModel: FinanceViewModel

    private var cumulativeData: [(month: String, netWorth: Double, date: Date)] {
        var running = viewModel.netWorth
        var result: [(month: String, netWorth: Double, date: Date)] = []

        // Go back in time, subtracting cash flows
        let reversed = viewModel.monthlyTrend.reversed()
        for data in reversed {
            result.insert((month: data.month, netWorth: running, date: data.date), at: 0)
            running -= data.cashFlow
        }
        return result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Net Worth Trend")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text("6 Months")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Chart(cumulativeData, id: \.month) { item in
                AreaMark(
                    x: .value("Month", item.month),
                    y: .value("Net Worth", item.netWorth)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.55, green: 0.25, blue: 0.90).opacity(0.25),
                            Color(red: 0.25, green: 0.40, blue: 0.95).opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Month", item.month),
                    y: .value("Net Worth", item.netWorth)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.25, green: 0.40, blue: 0.95),
                            Color(red: 0.55, green: 0.25, blue: 0.90)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .lineStyle(StrokeStyle(lineWidth: 2.5))
                .interpolationMethod(.catmullRom)
            }
            .frame(height: 150)
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
}
