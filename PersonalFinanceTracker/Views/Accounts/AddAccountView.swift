import SwiftUI

struct AddAccountView: View {
    @ObservedObject var viewModel: FinanceViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var accountType: AccountType = .checking
    @State private var balance: String = ""
    @State private var lastFourDigits: String = ""
    @State private var notes: String = ""
    @FocusState private var nameFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Account type selector
                    accountTypeGrid
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                    // Balance input
                    balanceInput
                        .padding(.bottom, 8)

                    // Form fields
                    formFields
                        .padding(.horizontal, 20)

                    Spacer(minLength: 80)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Add Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        saveAccount()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(isFormValid ? Color(red: 0.25, green: 0.40, blue: 0.95) : .secondary)
                    .disabled(!isFormValid)
                }
            }
            .onAppear { nameFocused = true }
        }
    }

    // MARK: - Account Type Grid

    private var accountTypeGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(AccountType.allCases, id: \.self) { type in
                Button {
                    accountType = type
                } label: {
                    VStack(spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(accountType == type ? type.color : type.color.opacity(0.12))
                                .frame(width: 50, height: 50)
                            Image(systemName: type.icon)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(accountType == type ? .white : type.color)
                        }
                        Text(type.rawValue)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(accountType == type ? type.color : .secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    // MARK: - Balance Input

    private var balanceInput: some View {
        VStack(spacing: 6) {
            Text(accountType.isLiability ? "Current Balance Owed" : "Current Balance")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("$")
                    .font(.system(size: 28, weight: .light, design: .rounded))
                    .foregroundStyle(.secondary)
                TextField("0.00", text: $balance)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 180)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Form Fields

    private var formFields: some View {
        VStack(spacing: 14) {
            FormFieldCard {
                HStack {
                    Label {
                        TextField("Account Name", text: $name)
                            .font(.subheadline)
                            .focused($nameFocused)
                    } icon: {
                        Image(systemName: "tag.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if accountType == .creditCard || accountType == .checking || accountType == .savings {
                FormFieldCard {
                    HStack {
                        Label {
                            TextField("Last 4 digits (optional)", text: $lastFourDigits)
                                .font(.subheadline)
                                .keyboardType(.numberPad)
                                .onChange(of: lastFourDigits) { _, newValue in
                                    if newValue.count > 4 {
                                        lastFourDigits = String(newValue.prefix(4))
                                    }
                                }
                        } icon: {
                            Image(systemName: "creditcard")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            FormFieldCard {
                HStack(alignment: .top) {
                    Label {
                        TextField("Notes (optional)", text: $notes, axis: .vertical)
                            .font(.subheadline)
                            .lineLimit(3)
                    } icon: {
                        Image(systemName: "note.text")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var isFormValid: Bool {
        !name.isEmpty && Double(balance) != nil
    }

    private func saveAccount() {
        guard let balanceValue = Double(balance), !name.isEmpty else { return }
        let account = Account(
            name: name,
            type: accountType,
            balance: balanceValue,
            lastFourDigits: lastFourDigits.isEmpty ? nil : lastFourDigits,
            notes: notes
        )
        viewModel.addAccount(account)
        dismiss()
    }
}
