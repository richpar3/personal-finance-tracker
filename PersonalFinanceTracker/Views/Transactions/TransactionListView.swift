import SwiftUI

struct TransactionListView: View {
    @ObservedObject var viewModel: FinanceViewModel
    @State private var showAddTransaction = false
    @State private var searchText = ""
    @State private var selectedFilter: TransactionType? = nil
    @State private var selectedCategoryFilter: TransactionCategory? = nil
    @State private var showFilterSheet = false

    private var displayedTransactions: [Transaction] {
        var txs = viewModel.transactions.sorted { $0.date > $1.date }

        if let filter = selectedFilter {
            txs = txs.filter { $0.type == filter }
        }
        if let catFilter = selectedCategoryFilter {
            txs = txs.filter { $0.category == catFilter }
        }
        if !searchText.isEmpty {
            txs = txs.filter {
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.category.rawValue.localizedCaseInsensitiveContains(searchText) ||
                $0.accountName.localizedCaseInsensitiveContains(searchText)
            }
        }
        return txs
    }

    private var groupedTransactions: [(key: String, value: [Transaction])] {
        let grouped = Dictionary(grouping: displayedTransactions) { tx -> String in
            let formatter = DateFormatter()
            if Calendar.current.isDateInToday(tx.date) { return "Today" }
            if Calendar.current.isDateInYesterday(tx.date) { return "Yesterday" }
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: tx.date)
        }
        return grouped.sorted { a, b in
            guard let firstA = a.value.first, let firstB = b.value.first else { return false }
            return firstA.date > firstB.date
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Filter chips
            filterChips

            // Transaction list
            if displayedTransactions.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(groupedTransactions, id: \.key) { group in
                        Section {
                            ForEach(group.value) { transaction in
                                NavigationLink {
                                    TransactionDetailView(
                                        transaction: transaction,
                                        viewModel: viewModel
                                    )
                                } label: {
                                    TransactionRowView(transaction: transaction)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.deleteTransaction(transaction)
                                    } label: {
                                        Label("Delete", systemImage: "trash.fill")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        // Edit action handled via detail view
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(Color(red: 0.25, green: 0.40, blue: 0.95))
                                }
                            }
                        } header: {
                            sectionHeader(for: group)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .searchable(text: $searchText, prompt: "Search transactions")
        .navigationTitle("Transactions")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 8) {
                    Button {
                        showFilterSheet = true
                    } label: {
                        Image(systemName: hasActiveFilter ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .foregroundStyle(hasActiveFilter ? Color(red: 0.25, green: 0.40, blue: 0.95) : .primary)
                    }

                    Button {
                        showAddTransaction = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color(red: 0.25, green: 0.40, blue: 0.95))
                    }
                }
            }
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView(viewModel: viewModel)
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterSheetView(
                selectedType: $selectedFilter,
                selectedCategory: $selectedCategoryFilter
            )
        }
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(label: "All", isSelected: selectedFilter == nil) {
                    selectedFilter = nil
                    selectedCategoryFilter = nil
                }
                ForEach(TransactionType.allCases, id: \.self) { type in
                    FilterChip(label: type.rawValue, isSelected: selectedFilter == type) {
                        selectedFilter = selectedFilter == type ? nil : type
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color(.systemBackground))
    }

    private var hasActiveFilter: Bool {
        selectedFilter != nil || selectedCategoryFilter != nil
    }

    // MARK: - Section Header

    private func sectionHeader(for group: (key: String, value: [Transaction])) -> some View {
        let total = group.value.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        return HStack {
            Text(group.key)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            Spacer()
            if total > 0 {
                Text("-\(formatCurrency(total))")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: searchText.isEmpty ? "tray.fill" : "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(searchText.isEmpty ? "No transactions yet" : "No results found")
                .font(.headline)
                .foregroundStyle(.secondary)
            if searchText.isEmpty {
                Button {
                    showAddTransaction = true
                } label: {
                    Label("Add Transaction", systemImage: "plus")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(red: 0.25, green: 0.40, blue: 0.95))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color(red: 0.25, green: 0.40, blue: 0.95) : Color(.systemGray6))
                .foregroundStyle(isSelected ? .white : .secondary)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Filter Sheet

struct FilterSheetView: View {
    @Binding var selectedType: TransactionType?
    @Binding var selectedCategory: TransactionCategory?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Transaction Type") {
                    ForEach(TransactionType.allCases, id: \.self) { type in
                        HStack {
                            Text(type.rawValue)
                            Spacer()
                            if selectedType == type {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color(red: 0.25, green: 0.40, blue: 0.95))
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedType = selectedType == type ? nil : type
                        }
                    }
                }

                Section("Category") {
                    ForEach(TransactionCategory.allCases) { category in
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(category.color.opacity(0.15))
                                    .frame(width: 28, height: 28)
                                Image(systemName: category.icon)
                                    .font(.system(size: 12))
                                    .foregroundStyle(category.color)
                            }
                            Text(category.rawValue)
                                .font(.subheadline)
                            Spacer()
                            if selectedCategory == category {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color(red: 0.25, green: 0.40, blue: 0.95))
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                    }
                }

                Section {
                    Button("Clear All Filters") {
                        selectedType = nil
                        selectedCategory = nil
                        dismiss()
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle("Filter")
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
