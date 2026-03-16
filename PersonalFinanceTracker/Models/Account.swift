import SwiftUI

enum AccountType: String, CaseIterable, Codable {
    case checking = "Checking"
    case savings = "Savings"
    case creditCard = "Credit Card"
    case cash = "Cash"
    case investment = "Investment"
    case loan = "Loan"
    case other = "Other"

    var icon: String {
        switch self {
        case .checking: return "building.columns.fill"
        case .savings: return "banknote.fill"
        case .creditCard: return "creditcard.fill"
        case .cash: return "dollarsign.circle.fill"
        case .investment: return "chart.pie.fill"
        case .loan: return "arrow.left.arrow.right.circle.fill"
        case .other: return "wallet.pass.fill"
        }
    }

    var color: Color {
        switch self {
        case .checking: return Color(red: 0.20, green: 0.60, blue: 0.95)
        case .savings: return Color(red: 0.15, green: 0.75, blue: 0.55)
        case .creditCard: return Color(red: 0.95, green: 0.35, blue: 0.35)
        case .cash: return Color(red: 0.90, green: 0.70, blue: 0.10)
        case .investment: return Color(red: 0.55, green: 0.35, blue: 0.85)
        case .loan: return Color(red: 1.0, green: 0.45, blue: 0.25)
        case .other: return Color(red: 0.55, green: 0.60, blue: 0.65)
        }
    }

    var isLiability: Bool {
        self == .creditCard || self == .loan
    }
}

struct Account: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var type: AccountType
    var balance: Double
    var currency: String = "USD"
    var lastFourDigits: String?
    var color: String = "#4A90D9"
    var notes: String = ""
    var createdAt: Date = Date()

    var isLiability: Bool { type.isLiability }

    var netValue: Double {
        isLiability ? -abs(balance) : balance
    }

    static var sampleAccounts: [Account] = [
        Account(name: "Chase Checking", type: .checking, balance: 3500.00, lastFourDigits: "4521"),
        Account(name: "Savings Account", type: .savings, balance: 12000.00, lastFourDigits: "8834"),
        Account(name: "Visa Credit Card", type: .creditCard, balance: 1250.00, lastFourDigits: "9012")
    ]
}
