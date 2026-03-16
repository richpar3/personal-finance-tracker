import SwiftUI
import Combine
import Supabase

@MainActor
class FinanceViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var accounts: [Account] = []
    @Published var selectedPeriod: TimePeriod = .month
    @Published var isSyncing: Bool = false
    @Published var syncError: String? = nil
    @Published var currentUser: User? = nil
    @Published var isLoadingAuth: Bool = true

    private let transactionsKey = "pft_transactions"
    private let accountsKey = "pft_accounts"

    enum TimePeriod: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case quarter = "Quarter"
        case year = "Year"
        case all = "All"

        var dateRange: (start: Date, end: Date) {
            let now = Date()
            let calendar = Calendar.current
            switch self {
            case .week:
                let start = calendar.date(byAdding: .weekOfYear, value: -1, to: now)!
                return (start, now)
            case .month:
                let start = calendar.date(byAdding: .month, value: -1, to: now)!
                return (start, now)
            case .quarter:
                let start = calendar.date(byAdding: .month, value: -3, to: now)!
                return (start, now)
            case .year:
                let start = calendar.date(byAdding: .year, value: -1, to: now)!
                return (start, now)
            case .all:
                return (Date.distantPast, now)
            }
        }
    }

    init() {
        Task { await observeAuthState() }
    }

    // MARK: - Auth State

    private func observeAuthState() async {
        for await (event, session) in supabase.auth.authStateChanges {
            currentUser = session?.user
            isLoadingAuth = false
            switch event {
            case .initialSession:
                if session != nil {
                    loadLocalData()
                    await syncFromSupabase()
                }
            case .signedIn:
                loadLocalData()
                await syncFromSupabase()
            case .signedOut:
                transactions = []
                accounts = []
                clearLocalData()
            default:
                break
            }
        }
    }

    // MARK: - Auth Actions

    func signIn(email: String, password: String) async throws {
        try await SupabaseService.shared.signIn(email: email, password: password)
    }

    func signUp(email: String, password: String) async throws {
        try await SupabaseService.shared.signUp(email: email, password: password)
    }

    func signOut() async {
        do {
            try await SupabaseService.shared.signOut()
        } catch {
            syncError = error.localizedDescription
        }
    }

    // MARK: - Supabase Sync

    func syncFromSupabase() async {
        isSyncing = true
        syncError = nil
        do {
            async let remoteAccounts     = SupabaseService.shared.fetchAccounts()
            async let remoteTransactions = SupabaseService.shared.fetchTransactions()

            let (fetchedAccounts, fetchedTransactions) = try await (remoteAccounts, remoteTransactions)

            if fetchedAccounts.isEmpty {
                // First sign-in: seed sample data and push to Supabase
                seedSampleData()
                try await pushAllToSupabase()
            } else {
                accounts     = fetchedAccounts
                transactions = fetchedTransactions
                saveLocalData()
            }
        } catch {
            syncError = error.localizedDescription
        }
        isSyncing = false
    }

    private func pushAllToSupabase() async throws {
        for account in accounts {
            try await SupabaseService.shared.insertAccount(account)
        }
        for transaction in transactions {
            try await SupabaseService.shared.insertTransaction(transaction)
        }
    }

    // MARK: - Computed Properties

    var netWorth: Double {
        accounts.reduce(0) { $0 + $1.netValue }
    }

    var totalAssets: Double {
        accounts.filter { !$0.isLiability }.reduce(0) { $0 + $1.balance }
    }

    var totalLiabilities: Double {
        accounts.filter { $0.isLiability }.reduce(0) { $0 + $1.balance }
    }

    var filteredTransactions: [Transaction] {
        let range = selectedPeriod.dateRange
        return transactions.filter { $0.date >= range.start && $0.date <= range.end }
            .sorted { $0.date > $1.date }
    }

    var totalIncome: Double {
        filteredTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }

    var totalExpenses: Double {
        filteredTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }

    var cashFlow: Double { totalIncome - totalExpenses }

    var savingsRate: Double {
        guard totalIncome > 0 else { return 0 }
        return (cashFlow / totalIncome) * 100
    }

    var recentTransactions: [Transaction] {
        Array(transactions.sorted { $0.date > $1.date }.prefix(5))
    }

    // MARK: - Category Breakdown

    var expensesByCategory: [(category: TransactionCategory, amount: Double, percentage: Double)] {
        let expenses = filteredTransactions.filter { $0.type == .expense }
        let total = expenses.reduce(0) { $0 + $1.amount }
        var categoryMap: [TransactionCategory: Double] = [:]
        for tx in expenses { categoryMap[tx.category, default: 0] += tx.amount }
        return categoryMap
            .map { (category: $0.key, amount: $0.value, percentage: total > 0 ? ($0.value / total) * 100 : 0) }
            .sorted { $0.amount > $1.amount }
    }

    var topSpendingCategory: TransactionCategory? { expensesByCategory.first?.category }

    // MARK: - Monthly Trend Data

    struct MonthlyData: Identifiable {
        let id = UUID()
        let month: String
        let income: Double
        let expenses: Double
        let cashFlow: Double
        let date: Date
    }

    var monthlyTrend: [MonthlyData] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return (0...5).reversed().compactMap { i -> MonthlyData? in
            guard let date = calendar.date(byAdding: .month, value: -i, to: Date()) else { return nil }
            let start = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
            let end   = calendar.date(byAdding: .month, value: 1, to: start)!
            let monthTx  = transactions.filter { $0.date >= start && $0.date < end }
            let income   = monthTx.filter { $0.type == .income  }.reduce(0) { $0 + $1.amount }
            let expenses = monthTx.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
            return MonthlyData(month: formatter.string(from: date), income: income,
                               expenses: expenses, cashFlow: income - expenses, date: date)
        }.reversed()
    }

    // MARK: - Daily Spending (last 30 days)

    struct DailySpending: Identifiable {
        let id = UUID()
        let day: String
        let amount: Double
        let date: Date
    }

    var dailySpending: [DailySpending] {
        let calendar  = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return (0...29).reversed().compactMap { i -> DailySpending? in
            guard let date = calendar.date(byAdding: .day, value: -i, to: Date()) else { return nil }
            let start  = calendar.startOfDay(for: date)
            let end    = calendar.date(byAdding: .day, value: 1, to: start)!
            let amount = transactions
                .filter { $0.type == .expense && $0.date >= start && $0.date < end }
                .reduce(0) { $0 + $1.amount }
            return DailySpending(day: formatter.string(from: date), amount: amount, date: date)
        }.reversed()
    }

    // MARK: - CRUD Operations

    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        updateAccountBalance(for: transaction, adding: true)
        saveLocalData()
        Task {
            do {
                try await SupabaseService.shared.insertTransaction(transaction)
                if let account = accounts.first(where: { $0.id == transaction.accountId }) {
                    try await SupabaseService.shared.updateAccount(account)
                }
            } catch { syncError = error.localizedDescription }
        }
    }

    func deleteTransaction(_ transaction: Transaction) {
        updateAccountBalance(for: transaction, adding: false)
        transactions.removeAll { $0.id == transaction.id }
        saveLocalData()
        Task {
            do {
                try await SupabaseService.shared.deleteTransaction(id: transaction.id)
                if let account = accounts.first(where: { $0.id == transaction.accountId }) {
                    try await SupabaseService.shared.updateAccount(account)
                }
            } catch { syncError = error.localizedDescription }
        }
    }

    func updateTransaction(_ updated: Transaction) {
        guard let index = transactions.firstIndex(where: { $0.id == updated.id }) else { return }
        let old = transactions[index]
        updateAccountBalance(for: old, adding: false)
        transactions[index] = updated
        updateAccountBalance(for: updated, adding: true)
        saveLocalData()
        Task {
            do {
                try await SupabaseService.shared.updateTransaction(updated)
                let affectedIds = Set([old.accountId, updated.accountId])
                for account in accounts where affectedIds.contains(account.id) {
                    try await SupabaseService.shared.updateAccount(account)
                }
            } catch { syncError = error.localizedDescription }
        }
    }

    func addAccount(_ account: Account) {
        accounts.append(account)
        saveLocalData()
        Task {
            do { try await SupabaseService.shared.insertAccount(account) }
            catch { syncError = error.localizedDescription }
        }
    }

    func deleteAccount(_ account: Account) {
        accounts.removeAll { $0.id == account.id }
        transactions.removeAll { $0.accountId == account.id }
        saveLocalData()
        Task {
            do { try await SupabaseService.shared.deleteAccount(id: account.id) }
            catch { syncError = error.localizedDescription }
        }
    }

    func updateAccount(_ updated: Account) {
        guard let index = accounts.firstIndex(where: { $0.id == updated.id }) else { return }
        accounts[index] = updated
        saveLocalData()
        Task {
            do { try await SupabaseService.shared.updateAccount(updated) }
            catch { syncError = error.localizedDescription }
        }
    }

    private func updateAccountBalance(for transaction: Transaction, adding: Bool) {
        guard let index = accounts.firstIndex(where: { $0.id == transaction.accountId }) else { return }
        let delta = adding ? transaction.signedAmount : -transaction.signedAmount
        accounts[index].balance += delta
    }

    // MARK: - Local Persistence (offline cache)

    private func saveLocalData() {
        if let encoded = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(encoded, forKey: transactionsKey)
        }
        if let encoded = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(encoded, forKey: accountsKey)
        }
    }

    private func loadLocalData() {
        if let data    = UserDefaults.standard.data(forKey: transactionsKey),
           let decoded = try? JSONDecoder().decode([Transaction].self, from: data) {
            transactions = decoded
        }
        if let data    = UserDefaults.standard.data(forKey: accountsKey),
           let decoded = try? JSONDecoder().decode([Account].self, from: data) {
            accounts = decoded
        }
    }

    private func clearLocalData() {
        UserDefaults.standard.removeObject(forKey: transactionsKey)
        UserDefaults.standard.removeObject(forKey: accountsKey)
    }

    // MARK: - Sample Data

    private func seedSampleData() {
        let checkingId = UUID()
        let savingsId  = UUID()
        let creditId   = UUID()

        accounts = [
            Account(id: checkingId, name: "Chase Checking",      type: .checking,    balance: 3500.00,  lastFourDigits: "4521"),
            Account(id: savingsId,  name: "High-Yield Savings",  type: .savings,     balance: 15000.00, lastFourDigits: "8834"),
            Account(id: creditId,   name: "Visa Rewards",        type: .creditCard,  balance: 850.00,   lastFourDigits: "9012"),
        ]

        let calendar  = Calendar.current
        var sampleTx: [Transaction] = []

        let expenseData: [(Int, TransactionCategory, Double, String)] = [
            (-1, .food, 42.50, "Dinner at Olive Garden"),
            (-2, .groceries, 128.75, "Weekly grocery run"),
            (-3, .transport, 55.00, "Monthly transit pass"),
            (-4, .entertainment, 15.99, "Netflix subscription"),
            (-5, .food, 12.50, "Lunch - Chipotle"),
            (-6, .shopping, 89.99, "New running shoes"),
            (-7, .health, 25.00, "Pharmacy prescription"),
            (-8, .food, 8.75, "Morning coffee"),
            (-9, .utilities, 95.00, "Electric bill"),
            (-10, .food, 35.00, "Pizza night"),
            (-12, .subscriptions, 9.99, "Spotify Premium"),
            (-14, .transport, 45.00, "Gas fill-up"),
            (-15, .groceries, 94.30, "Costco run"),
            (-17, .food, 22.00, "Sushi takeout"),
            (-18, .shopping, 45.00, "Amazon purchase"),
            (-20, .entertainment, 32.00, "Movie tickets"),
            (-22, .health, 120.00, "Gym membership"),
            (-24, .food, 18.50, "Breakfast cafe"),
            (-25, .transport, 28.00, "Uber rides"),
            (-28, .housing, 1800.00, "Monthly rent"),
        ]
        for (offset, category, amount, desc) in expenseData {
            let date      = calendar.date(byAdding: .day, value: offset, to: Date())!
            let accountId = [checkingId, creditId].randomElement()!
            sampleTx.append(Transaction(date: date, category: category, amount: amount,
                                        accountId: accountId,
                                        accountName: accountId == checkingId ? "Chase Checking" : "Visa Rewards",
                                        description: desc, type: .expense))
        }

        let incomeData: [(Int, TransactionCategory, Double, String)] = [
            (-1,  .salary,   3500.00, "Bi-weekly paycheck"),
            (-15, .salary,   3500.00, "Bi-weekly paycheck"),
            (-5,  .freelance, 450.00, "Freelance design project"),
            (-20, .bonus,     200.00, "Performance bonus"),
            (-30, .salary,   3500.00, "Bi-weekly paycheck"),
            (-45, .salary,   3500.00, "Bi-weekly paycheck"),
        ]
        for (offset, category, amount, desc) in incomeData {
            let date = calendar.date(byAdding: .day, value: offset, to: Date())!
            sampleTx.append(Transaction(date: date, category: category, amount: amount,
                                        accountId: checkingId, accountName: "Chase Checking",
                                        description: desc, type: .income))
        }

        transactions = sampleTx
        saveLocalData()
    }
}
