import Foundation
import Supabase

// MARK: - Codable row types (snake_case columns ↔ camelCase Swift via SDK decoder)

struct AccountRow: Codable {
    var id: String
    var userId: String
    var name: String
    var type: String
    var balance: Double
    var currency: String
    var lastFourDigits: String?
    var color: String
    var notes: String
    var createdAt: String?
}

struct TransactionRow: Codable {
    var id: String
    var userId: String
    var date: String
    var category: String
    var amount: Double
    var accountId: String
    var accountName: String
    var description: String
    var type: String
    var notes: String
    var isRecurring: Bool
    var tags: [String]
    var createdAt: String?
}

// MARK: - Service

class SupabaseService {
    static let shared = SupabaseService()
    private init() {}

    // MARK: Auth

    func signIn(email: String, password: String) async throws {
        try await supabase.auth.signIn(email: email, password: password)
    }

    func signUp(email: String, password: String) async throws {
        try await supabase.auth.signUp(email: email, password: password)
    }

    func signOut() async throws {
        try await supabase.auth.signOut()
    }

    private func currentUserId() async throws -> String {
        try await supabase.auth.session.user.id.uuidString
    }

    // MARK: Accounts

    func fetchAccounts() async throws -> [Account] {
        let rows: [AccountRow] = try await supabase
            .from("accounts")
            .select()
            .execute()
            .value
        return rows.compactMap { Account(from: $0) }
    }

    func insertAccount(_ account: Account) async throws {
        let userId = try await currentUserId()
        var row = AccountRow(from: account)
        row.userId = userId
        try await supabase
            .from("accounts")
            .insert(row)
            .execute()
    }

    func updateAccount(_ account: Account) async throws {
        let userId = try await currentUserId()
        var row = AccountRow(from: account)
        row.userId = userId
        try await supabase
            .from("accounts")
            .update(row)
            .eq("id", value: account.id.uuidString)
            .execute()
    }

    func deleteAccount(id: UUID) async throws {
        try await supabase
            .from("accounts")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }

    // MARK: Transactions

    func fetchTransactions() async throws -> [Transaction] {
        let rows: [TransactionRow] = try await supabase
            .from("transactions")
            .select()
            .execute()
            .value
        return rows.compactMap { Transaction(from: $0) }
    }

    func insertTransaction(_ transaction: Transaction) async throws {
        let userId = try await currentUserId()
        var row = TransactionRow(from: transaction)
        row.userId = userId
        try await supabase
            .from("transactions")
            .insert(row)
            .execute()
    }

    func updateTransaction(_ transaction: Transaction) async throws {
        let userId = try await currentUserId()
        var row = TransactionRow(from: transaction)
        row.userId = userId
        try await supabase
            .from("transactions")
            .update(row)
            .eq("id", value: transaction.id.uuidString)
            .execute()
    }

    func deleteTransaction(id: UUID) async throws {
        try await supabase
            .from("transactions")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
}

// MARK: - ISO 8601 helpers

private let isoFormatter: ISO8601DateFormatter = {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return f
}()

private func parseDate(_ string: String) -> Date {
    isoFormatter.date(from: string) ?? Date()
}

private func formatDate(_ date: Date) -> String {
    isoFormatter.string(from: date)
}

// MARK: - Account conversions

extension Account {
    init?(from row: AccountRow) {
        guard
            let id   = UUID(uuidString: row.id),
            let type = AccountType(rawValue: row.type)
        else { return nil }

        self.id             = id
        self.name           = row.name
        self.type           = type
        self.balance        = row.balance
        self.currency       = row.currency
        self.lastFourDigits = row.lastFourDigits
        self.color          = row.color
        self.notes          = row.notes
        self.createdAt      = row.createdAt.map { parseDate($0) } ?? Date()
    }
}

extension AccountRow {
    init(from account: Account) {
        self.id             = account.id.uuidString
        self.userId         = ""   // set by caller before insert/update
        self.name           = account.name
        self.type           = account.type.rawValue
        self.balance        = account.balance
        self.currency       = account.currency
        self.lastFourDigits = account.lastFourDigits
        self.color          = account.color
        self.notes          = account.notes
        self.createdAt      = formatDate(account.createdAt)
    }
}

// MARK: - Transaction conversions

extension Transaction {
    init?(from row: TransactionRow) {
        guard
            let id        = UUID(uuidString: row.id),
            let accountId = UUID(uuidString: row.accountId),
            let type      = TransactionType(rawValue: row.type),
            let category  = TransactionCategory(rawValue: row.category)
        else { return nil }

        self.id          = id
        self.date        = parseDate(row.date)
        self.category    = category
        self.amount      = row.amount
        self.accountId   = accountId
        self.accountName = row.accountName
        self.description = row.description
        self.type        = type
        self.notes       = row.notes
        self.isRecurring = row.isRecurring
        self.tags        = row.tags
        self.createdAt   = row.createdAt.map { parseDate($0) } ?? Date()
    }
}

extension TransactionRow {
    init(from tx: Transaction) {
        self.id          = tx.id.uuidString
        self.userId      = ""   // set by caller before insert/update
        self.date        = formatDate(tx.date)
        self.category    = tx.category.rawValue
        self.amount      = tx.amount
        self.accountId   = tx.accountId.uuidString
        self.accountName = tx.accountName
        self.description = tx.description
        self.type        = tx.type.rawValue
        self.notes       = tx.notes
        self.isRecurring = tx.isRecurring
        self.tags        = tx.tags
        self.createdAt   = formatDate(tx.createdAt)
    }
}
