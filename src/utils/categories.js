export const CATEGORIES = {
  // Expense
  food:         { label: 'Food & Dining',      emoji: '🍽️', color: '#FF8C42', isIncome: false },
  groceries:    { label: 'Groceries',           emoji: '🛒', color: '#4CAF50', isIncome: false },
  transport:    { label: 'Transportation',      emoji: '🚗', color: '#2196F3', isIncome: false },
  housing:      { label: 'Housing & Rent',      emoji: '🏠', color: '#9C27B0', isIncome: false },
  utilities:    { label: 'Utilities',           emoji: '⚡', color: '#FFC107', isIncome: false },
  health:       { label: 'Health & Medical',    emoji: '💊', color: '#F44336', isIncome: false },
  entertainment:{ label: 'Entertainment',       emoji: '🎬', color: '#E91E63', isIncome: false },
  shopping:     { label: 'Shopping',            emoji: '🛍️', color: '#FF4081', isIncome: false },
  education:    { label: 'Education',           emoji: '📚', color: '#03A9F4', isIncome: false },
  travel:       { label: 'Travel',              emoji: '✈️', color: '#1565C0', isIncome: false },
  subscriptions:{ label: 'Subscriptions',       emoji: '📱', color: '#7B1FA2', isIncome: false },
  personalCare: { label: 'Personal Care',       emoji: '🧴', color: '#F48FB1', isIncome: false },
  insurance:    { label: 'Insurance',           emoji: '🛡️', color: '#546E7A', isIncome: false },
  gifts:        { label: 'Gifts & Donations',   emoji: '🎁', color: '#EF5350', isIncome: false },
  taxes:        { label: 'Taxes & Fees',        emoji: '📄', color: '#78909C', isIncome: false },
  // Income
  salary:       { label: 'Salary',              emoji: '💼', color: '#26BF8C', isIncome: true },
  freelance:    { label: 'Freelance',           emoji: '💻', color: '#43A047', isIncome: true },
  investment:   { label: 'Investment Returns',  emoji: '📈', color: '#1B5E20', isIncome: true },
  bonus:        { label: 'Bonus',               emoji: '🏆', color: '#F9A825', isIncome: true },
  refund:       { label: 'Refund',              emoji: '↩️', color: '#81C784', isIncome: true },
  // Other
  other:        { label: 'Other',               emoji: '📋', color: '#9E9E9E', isIncome: null },
}

export const EXPENSE_CATEGORIES = Object.entries(CATEGORIES)
  .filter(([, v]) => v.isIncome === false)
  .map(([k]) => k)

export const INCOME_CATEGORIES = Object.entries(CATEGORIES)
  .filter(([, v]) => v.isIncome === true)
  .map(([k]) => k)

export const ACCOUNT_TYPES = {
  checking:   { label: 'Checking',     emoji: '🏦', color: '#2196F3' },
  savings:    { label: 'Savings',      emoji: '💰', color: '#26BF8C' },
  creditCard: { label: 'Credit Card',  emoji: '💳', color: '#FF5959' },
  cash:       { label: 'Cash',         emoji: '💵', color: '#FFC107' },
  investment: { label: 'Investment',   emoji: '📊', color: '#9C27B0' },
  loan:       { label: 'Loan',         emoji: '📋', color: '#FF7043' },
  other:      { label: 'Other',        emoji: '👜', color: '#78909C' },
}

export const LIABILITY_TYPES = ['creditCard', 'loan']
