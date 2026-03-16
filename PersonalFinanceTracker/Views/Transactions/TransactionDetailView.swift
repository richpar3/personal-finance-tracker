import SwiftUI

struct TransactionDetailView: View {
    let transaction: Transaction
    @ObservedObject var viewModel: FinanceViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showEdit = false
    @State private var showDeleteConfirm = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Hero amount card
                heroCard
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                // Details card
                detailsCard
                    .padding(.horizontal, 20)

                // Account card
                accountCard
                    .padding(.horizontal, 20)

                if !transaction.notes.isEmpty {
                    notesCard
                        .padding(.horizontal, 20)
                }

                // Delete button
                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Label("Delete Transaction", systemImage: "trash")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.systemBackground))
                        .foregroundStyle(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 40)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Transaction")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showEdit = true
                }
                .foregroundStyle(Color(red: 0.25, green: 0.40, blue: 0.95))
            }
        }
        .sheet(isPresented: $showEdit) {
            AddTransactionView(viewModel: viewModel, transaction: transaction)
        }
        .confirmationDialog(
            "Delete Transaction",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                viewModel.deleteTransaction(transaction)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \"\(transaction.description)\"? This cannot be undone.")
        }
    }

    // MARK: - Hero Card

    private var heroCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(transaction.category.color.opacity(0.15))
                    .frame(width: 72, height: 72)
                Image(systemName: transaction.category.icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(transaction.category.color)
            }

            VStack(spacing: 6) {
                Text(transaction.description)
                    .font(.title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(transaction.category.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(amountText)
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(amountColor)

            TypeBadge(type: transaction.type)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    // MARK: - Details Card

    private var detailsCard: some View {
        VStack(spacing: 0) {
            DetailRow(label: "Date", value: transaction.formattedDate, icon: "calendar")
            Divider().padding(.leading, 52)
            DetailRow(label: "Category", value: transaction.category.rawValue, icon: transaction.category.icon)
            Divider().padding(.leading, 52)
            DetailRow(label: "Type", value: transaction.type.rawValue, icon: "arrow.left.arrow.right")
            if transaction.isRecurring {
                Divider().padding(.leading, 52)
                DetailRow(label: "Recurring", value: "Yes", icon: "repeat.circle.fill")
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    // MARK: - Account Card

    private var accountCard: some View {
        DetailRow(
            label: "Account / Card",
            value: transaction.accountName,
            icon: "creditcard.fill"
        )
        .padding(.vertical, 4)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    // MARK: - Notes Card

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Notes", systemImage: "note.text")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            Text(transaction.notes)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    private var amountText: String {
        let prefix = transaction.type == .income ? "+" : "-"
        return "\(prefix)\(transaction.formattedAmount)"
    }

    private var amountColor: Color {
        transaction.type == .income
            ? Color(red: 0.15, green: 0.75, blue: 0.55)
            : .primary
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .frame(width: 20)
                .padding(.leading, 16)

            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .padding(.trailing, 16)
        }
        .padding(.vertical, 14)
    }
}

struct TypeBadge: View {
    let type: TransactionType

    var body: some View {
        Text(type.rawValue)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(badgeColor.opacity(0.12))
            .foregroundStyle(badgeColor)
            .clipShape(Capsule())
    }

    private var badgeColor: Color {
        switch type {
        case .expense: return Color(red: 1.0, green: 0.35, blue: 0.35)
        case .income: return Color(red: 0.15, green: 0.75, blue: 0.55)
        case .transfer: return Color(red: 0.25, green: 0.40, blue: 0.95)
        }
    }
}
