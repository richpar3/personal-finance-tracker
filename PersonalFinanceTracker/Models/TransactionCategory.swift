import SwiftUI

enum TransactionCategory: String, CaseIterable, Codable, Identifiable {
    // Expenses
    case food = "Food & Dining"
    case groceries = "Groceries"
    case transport = "Transportation"
    case housing = "Housing & Rent"
    case utilities = "Utilities"
    case health = "Health & Medical"
    case entertainment = "Entertainment"
    case shopping = "Shopping"
    case education = "Education"
    case travel = "Travel"
    case subscriptions = "Subscriptions"
    case personalCare = "Personal Care"
    case insurance = "Insurance"
    case gifts = "Gifts & Donations"
    case taxes = "Taxes & Fees"
    // Income
    case salary = "Salary"
    case freelance = "Freelance"
    case investment = "Investment Returns"
    case bonus = "Bonus"
    case refund = "Refund"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .groceries: return "cart.fill"
        case .transport: return "car.fill"
        case .housing: return "house.fill"
        case .utilities: return "bolt.fill"
        case .health: return "cross.case.fill"
        case .entertainment: return "tv.fill"
        case .shopping: return "bag.fill"
        case .education: return "book.fill"
        case .travel: return "airplane"
        case .subscriptions: return "repeat.circle.fill"
        case .personalCare: return "sparkles"
        case .insurance: return "shield.fill"
        case .gifts: return "gift.fill"
        case .taxes: return "doc.text.fill"
        case .salary: return "briefcase.fill"
        case .freelance: return "laptopcomputer"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .bonus: return "star.fill"
        case .refund: return "arrow.uturn.left.circle.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .food: return Color(red: 1.0, green: 0.45, blue: 0.25)
        case .groceries: return Color(red: 0.35, green: 0.78, blue: 0.40)
        case .transport: return Color(red: 0.20, green: 0.60, blue: 0.95)
        case .housing: return Color(red: 0.55, green: 0.35, blue: 0.85)
        case .utilities: return Color(red: 1.0, green: 0.75, blue: 0.10)
        case .health: return Color(red: 1.0, green: 0.30, blue: 0.40)
        case .entertainment: return Color(red: 1.0, green: 0.50, blue: 0.70)
        case .shopping: return Color(red: 0.95, green: 0.35, blue: 0.65)
        case .education: return Color(red: 0.20, green: 0.75, blue: 0.85)
        case .travel: return Color(red: 0.10, green: 0.65, blue: 0.90)
        case .subscriptions: return Color(red: 0.60, green: 0.40, blue: 0.90)
        case .personalCare: return Color(red: 0.95, green: 0.55, blue: 0.75)
        case .insurance: return Color(red: 0.30, green: 0.50, blue: 0.75)
        case .gifts: return Color(red: 1.0, green: 0.40, blue: 0.40)
        case .taxes: return Color(red: 0.50, green: 0.55, blue: 0.60)
        case .salary: return Color(red: 0.15, green: 0.75, blue: 0.55)
        case .freelance: return Color(red: 0.20, green: 0.80, blue: 0.60)
        case .investment: return Color(red: 0.10, green: 0.65, blue: 0.45)
        case .bonus: return Color(red: 0.90, green: 0.70, blue: 0.10)
        case .refund: return Color(red: 0.35, green: 0.70, blue: 0.45)
        case .other: return Color(red: 0.55, green: 0.60, blue: 0.65)
        }
    }

    var isIncome: Bool {
        switch self {
        case .salary, .freelance, .investment, .bonus, .refund:
            return true
        default:
            return false
        }
    }

    static var expenseCategories: [TransactionCategory] {
        allCases.filter { !$0.isIncome }
    }

    static var incomeCategories: [TransactionCategory] {
        allCases.filter { $0.isIncome }
    }
}
