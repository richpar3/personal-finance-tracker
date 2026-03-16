import SwiftUI

struct AccountsView: View {
    @ObservedObject var viewModel: FinanceViewModel
    @State private var showAddAccount = false
    @State private var selectedAccount: Account?
    @State private var showDeleteConfirm = false

    private var assets: [Account] { viewModel.accounts.filter { !$0.isLiability } }
    private var liabilities: [Account] { viewModel.accounts.filter { $0.isLiability } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Net Worth summary
                    netWorthSummary
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    // Assets section
                    if !assets.isEmpty {
                        accountGroup(title: "Assets", accounts: assets, isLiability: false)
                            .padding(.horizontal, 20)
                    }

                    // Liabilities section
                    if !liabilities.isEmpty {
                        accountGroup(title: "Liabilities", accounts: liabilities, isLiability: true)
                            .padding(.horizontal, 20)
                    }

                    if viewModel.accounts.isEmpty {
                        emptyState
                            .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 100)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Accounts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddAccount = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color(red: 0.25, green: 0.40, blue: 0.95))
                    }
                }
            }
            .sheet(isPresented: $showAddAccount) {
                AddAccountView(viewModel: viewModel)
            }
            .confirmationDialog(
                "Delete Account",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete Account", role: .destructive) {
                    if let account = selectedAccount {
                        viewModel.deleteAccount(account)
                        selectedAccount = nil
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Deleting this account will also remove all associated transactions.")
            }
        }
    }

    // MARK: - Net Worth Summary

    private var netWorthSummary: some View {
        HStack(spacing: 0) {
            summaryItem(title: "Total Assets", value: viewModel.totalAssets, color: Color(red: 0.15, green: 0.75, blue: 0.55))
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(width: 1, height: 50)
            summaryItem(title: "Liabilities", value: viewModel.totalLiabilities, color: Color(red: 1.0, green: 0.35, blue: 0.35))
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(width: 1, height: 50)
            summaryItem(title: "Net Worth", value: viewModel.netWorth, color: Color(red: 0.25, green: 0.40, blue: 0.95))
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    private func summaryItem(title: String, value: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(formatCurrency(abs(value)))
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Account Group

    private func accountGroup(title: String, accounts: [Account], isLiability: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text(formatCurrency(accounts.reduce(0) { $0 + $1.balance }))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(isLiability ? Color(red: 1.0, green: 0.35, blue: 0.35) : Color(red: 0.15, green: 0.75, blue: 0.55))
            }

            ForEach(accounts) { account in
                AccountCard(account: account)
                    .contextMenu {
                        Button(role: .destructive) {
                            selectedAccount = account
                            showDeleteConfirm = true
                        } label: {
                            Label("Delete Account", systemImage: "trash")
                        }
                    }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "creditcard.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No accounts yet")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Add your bank accounts, credit cards, and cash to track your complete financial picture.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                showAddAccount = true
            } label: {
                Label("Add Account", systemImage: "plus")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.25, green: 0.40, blue: 0.95))
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Account Card

struct AccountCard: View {
    let account: Account

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(account.type.color.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: account.type.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(account.type.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(account.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                HStack(spacing: 6) {
                    Text(account.type.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let digits = account.lastFourDigits {
                        Text("•••• \(digits)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(formatCurrency(account.balance))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(account.isLiability ? Color(red: 1.0, green: 0.35, blue: 0.35) : .primary)
                Text(account.isLiability ? "Owed" : "Available")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}
