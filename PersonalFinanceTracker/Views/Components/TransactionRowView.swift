import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 14) {
            // Category icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(transaction.category.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: transaction.category.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(transaction.category.color)
            }

            // Details
            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.description)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Text(transaction.category.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("•")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(transaction.accountName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Amount + Date
            VStack(alignment: .trailing, spacing: 3) {
                Text(amountText)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(amountColor)
                Text(shortDate)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var amountText: String {
        let prefix = transaction.type == .income ? "+" : "-"
        return "\(prefix)\(transaction.formattedAmount)"
    }

    private var amountColor: Color {
        transaction.type == .income
            ? Color(red: 0.15, green: 0.75, blue: 0.55)
            : Color.primary
    }

    private var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: transaction.date)
    }
}
