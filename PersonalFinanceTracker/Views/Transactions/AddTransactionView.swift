import SwiftUI

struct AddTransactionView: View {
    @ObservedObject var viewModel: FinanceViewModel
    @Environment(\.dismiss) private var dismiss

    // Required fields
    @State private var date: Date = Date()
    @State private var category: TransactionCategory = .food
    @State private var amount: String = ""
    @State private var selectedAccount: Account?
    @State private var description: String = ""
    @State private var transactionType: TransactionType = .expense
    @State private var notes: String = ""
    @State private var isRecurring: Bool = false

    // UI State
    @State private var showCategoryPicker = false
    @State private var amountFocused = false
    @FocusState private var descriptionFocused: Bool
    @State private var showError = false
    @State private var errorMessage = ""

    var isEditing: Bool = false
    var existingTransaction: Transaction?

    init(viewModel: FinanceViewModel, transaction: Transaction? = nil) {
        self.viewModel = viewModel
        self.existingTransaction = transaction
        self.isEditing = transaction != nil
        if let tx = transaction {
            _date = State(initialValue: tx.date)
            _category = State(initialValue: tx.category)
            _amount = State(initialValue: String(tx.amount))
            _description = State(initialValue: tx.description)
            _transactionType = State(initialValue: tx.type)
            _notes = State(initialValue: tx.notes)
            _isRecurring = State(initialValue: tx.isRecurring)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Type Selector
                    typeSelector
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 24)

                    // Amount Input
                    amountInput
                        .padding(.bottom, 28)

                    // Form Fields
                    formFields
                        .padding(.horizontal, 20)

                    Spacer(minLength: 100)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(isEditing ? "Edit Transaction" : "Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditing ? "Save" : "Add") {
                        saveTransaction()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(isFormValid ? Color(red: 0.25, green: 0.40, blue: 0.95) : .secondary)
                    .disabled(!isFormValid)
                }
            }
            .sheet(isPresented: $showCategoryPicker) {
                CategoryPickerView(selectedCategory: $category, type: transactionType)
            }
            .alert("Missing Information", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                if selectedAccount == nil {
                    selectedAccount = viewModel.accounts.first
                }
            }
        }
    }

    // MARK: - Type Selector

    private var typeSelector: some View {
        HStack(spacing: 0) {
            ForEach(TransactionType.allCases, id: \.self) { type in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        transactionType = type
                        if type == .income && !category.isIncome {
                            category = .salary
                        } else if type == .expense && category.isIncome {
                            category = .food
                        }
                    }
                } label: {
                    Text(type.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            transactionType == type
                                ? typeColor(type)
                                : Color.clear
                        )
                        .foregroundStyle(transactionType == type ? .white : .secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(4)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Amount Input

    private var amountInput: some View {
        VStack(spacing: 8) {
            Text("Amount")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("$")
                    .font(.system(size: 32, weight: .light, design: .rounded))
                    .foregroundStyle(.secondary)
                TextField("0.00", text: $amount)
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 200)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .onTapGesture {
                amountFocused = true
            }
        }
    }

    // MARK: - Form Fields

    private var formFields: some View {
        VStack(spacing: 16) {
            // Date field
            FormFieldCard {
                DatePicker(
                    "Date",
                    selection: $date,
                    displayedComponents: [.date]
                )
                .font(.subheadline)
                .fontWeight(.medium)
            }

            // Category
            FormFieldCard {
                Button {
                    showCategoryPicker = true
                } label: {
                    HStack {
                        Label {
                            Text("Category")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                        } icon: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(category.color.opacity(0.15))
                                    .frame(width: 28, height: 28)
                                Image(systemName: category.icon)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(category.color)
                            }
                        }
                        Spacer()
                        HStack(spacing: 6) {
                            Text(category.rawValue)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            // Account picker
            FormFieldCard {
                HStack {
                    Label {
                        Text("Account")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    } icon: {
                        Image(systemName: "creditcard.fill")
                            .foregroundStyle(Color(red: 0.25, green: 0.40, blue: 0.95))
                    }
                    Spacer()
                    Picker("", selection: $selectedAccount) {
                        ForEach(viewModel.accounts) { account in
                            Text(account.name).tag(Optional(account))
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                }
            }

            // Description
            FormFieldCard {
                HStack(alignment: .top) {
                    Label {
                        TextField("Description", text: $description)
                            .font(.subheadline)
                            .focused($descriptionFocused)
                    } icon: {
                        Image(systemName: "text.alignleft")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Notes (optional)
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

            // Recurring toggle
            FormFieldCard {
                Toggle(isOn: $isRecurring) {
                    Label {
                        Text("Recurring")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    } icon: {
                        Image(systemName: "repeat.circle.fill")
                            .foregroundStyle(Color(red: 0.25, green: 0.40, blue: 0.95))
                    }
                }
                .tint(Color(red: 0.25, green: 0.40, blue: 0.95))
            }
        }
    }

    // MARK: - Helpers

    private var isFormValid: Bool {
        !amount.isEmpty &&
        Double(amount) != nil &&
        Double(amount)! > 0 &&
        !description.isEmpty &&
        selectedAccount != nil
    }

    private func typeColor(_ type: TransactionType) -> Color {
        switch type {
        case .expense: return Color(red: 1.0, green: 0.35, blue: 0.35)
        case .income: return Color(red: 0.15, green: 0.75, blue: 0.55)
        case .transfer: return Color(red: 0.25, green: 0.40, blue: 0.95)
        }
    }

    private func saveTransaction() {
        guard let amountValue = Double(amount), amountValue > 0 else {
            errorMessage = "Please enter a valid amount."
            showError = true
            return
        }
        guard !description.isEmpty else {
            errorMessage = "Please add a description."
            showError = true
            return
        }
        guard let account = selectedAccount else {
            errorMessage = "Please select an account."
            showError = true
            return
        }

        let transaction = Transaction(
            id: existingTransaction?.id ?? UUID(),
            date: date,
            category: category,
            amount: amountValue,
            accountId: account.id,
            accountName: account.name,
            description: description,
            type: transactionType,
            notes: notes,
            isRecurring: isRecurring
        )

        if isEditing {
            viewModel.updateTransaction(transaction)
        } else {
            viewModel.addTransaction(transaction)
        }
        dismiss()
    }
}

// MARK: - FormFieldCard

struct FormFieldCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Category Picker Sheet

struct CategoryPickerView: View {
    @Binding var selectedCategory: TransactionCategory
    let type: TransactionType
    @Environment(\.dismiss) private var dismiss

    private var categories: [TransactionCategory] {
        switch type {
        case .income: return TransactionCategory.incomeCategories
        case .expense: return TransactionCategory.expenseCategories
        case .transfer: return TransactionCategory.allCases
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(categories) { category in
                        Button {
                            selectedCategory = category
                            dismiss()
                        } label: {
                            VStack(spacing: 8) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(category.color.opacity(selectedCategory == category ? 0.25 : 0.12))
                                        .frame(width: 56, height: 56)
                                    Image(systemName: category.icon)
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundStyle(category.color)
                                }
                                .overlay {
                                    if selectedCategory == category {
                                        RoundedRectangle(cornerRadius: 14)
                                            .strokeBorder(category.color, lineWidth: 2)
                                    }
                                }

                                Text(category.rawValue)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(selectedCategory == category ? category.color : .secondary)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 4)
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
}
