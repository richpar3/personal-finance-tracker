import SwiftUI

struct NetWorthCard: View {
    @ObservedObject var viewModel: FinanceViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Net Worth")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.8))
                    Text(formatCurrency(viewModel.netWorth))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                Spacer()
                Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.white.opacity(0.3))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)

            // Assets / Liabilities
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ASSETS")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.7))
                        .tracking(1.2)
                    Text(formatCurrency(viewModel.totalAssets))
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Rectangle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 1, height: 36)

                VStack(alignment: .trailing, spacing: 4) {
                    Text("LIABILITIES")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.7))
                        .tracking(1.2)
                    Text(formatCurrency(viewModel.totalLiabilities))
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.25, green: 0.40, blue: 0.95),
                    Color(red: 0.55, green: 0.25, blue: 0.90)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color(red: 0.25, green: 0.40, blue: 0.95).opacity(0.35), radius: 16, x: 0, y: 8)
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: abs(value))) ?? "$0"
    }
}
