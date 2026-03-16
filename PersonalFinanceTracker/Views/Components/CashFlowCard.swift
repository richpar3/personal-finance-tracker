import SwiftUI

struct CashFlowCard: View {
    let title: String
    let amount: Double
    let icon: String
    let isPositive: Bool
    let subtitle: String?

    init(title: String, amount: Double, icon: String, isPositive: Bool, subtitle: String? = nil) {
        self.title = title
        self.amount = amount
        self.icon = icon
        self.isPositive = isPositive
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ZStack {
                    Circle()
                        .fill(cardColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(cardColor)
                }
                Spacer()
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(formatCurrency(amount))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(cardColor)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    private var cardColor: Color {
        isPositive ? Color(red: 0.15, green: 0.75, blue: 0.55) : Color(red: 1.0, green: 0.35, blue: 0.35)
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: abs(value))) ?? "$0"
    }
}

struct SavingsRateCard: View {
    let rate: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ZStack {
                    Circle()
                        .fill(rateColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: "percent")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(rateColor)
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("\(Int(rate))%")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(rateColor)
                Text("Savings Rate")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(rateColor)
                        .frame(width: max(0, min(geo.size.width, geo.size.width * (rate / 100))), height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    private var rateColor: Color {
        if rate >= 20 { return Color(red: 0.15, green: 0.75, blue: 0.55) }
        if rate >= 10 { return Color(red: 0.90, green: 0.70, blue: 0.10) }
        return Color(red: 1.0, green: 0.35, blue: 0.35)
    }
}
