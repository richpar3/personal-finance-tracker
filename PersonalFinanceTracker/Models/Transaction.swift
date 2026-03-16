import Foundation

enum TransactionType: String, Codable, CaseIterable {
    case expense = "Expense"
    case income = "Income"
    case transfer = "Transfer"
}

struct Transaction: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date
    var category: TransactionCategory
    var amount: Double
    var accountId: UUID
    var accountName: String
    var description: String
    var type: TransactionType
    var notes: String = ""
    var isRecurring: Bool = false
    var tags: [String] = []
    var createdAt: Date = Date()

    var signedAmount: Double {
        switch type {
        case .expense: return -abs(amount)
        case .income: return abs(amount)
        case .transfer: return -abs(amount)
        }
    }

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: abs(amount))) ?? "$\(amount)"
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

extension Transaction {
    static var sampleTransactions: [Transaction] = []
}
