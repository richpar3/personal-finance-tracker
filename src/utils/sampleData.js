import { generateId } from './formatters'

export function generateSampleData() {
  const checkingId = generateId()
  const savingsId  = generateId()
  const creditId   = generateId()

  const accounts = [
    { id: checkingId, name: 'Chase Checking',     type: 'checking',   balance: 3500,  currency: 'USD', lastFourDigits: '4521', notes: '', createdAt: new Date().toISOString() },
    { id: savingsId,  name: 'High-Yield Savings', type: 'savings',    balance: 15000, currency: 'USD', lastFourDigits: '8834', notes: '', createdAt: new Date().toISOString() },
    { id: creditId,   name: 'Visa Rewards',       type: 'creditCard', balance: 850,   currency: 'USD', lastFourDigits: '9012', notes: '', createdAt: new Date().toISOString() },
  ]

  const DAY = 86400000
  const now = Date.now()

  const makeDate = (offsetDays) => new Date(now + offsetDays * DAY).toISOString()

  const expenses = [
    [-1,  'food',          42.50,   'Dinner at Olive Garden',  creditId,   'Visa Rewards'],
    [-2,  'groceries',    128.75,   'Weekly grocery run',      checkingId, 'Chase Checking'],
    [-3,  'transport',     55.00,   'Monthly transit pass',    checkingId, 'Chase Checking'],
    [-4,  'entertainment', 15.99,   'Netflix subscription',    creditId,   'Visa Rewards'],
    [-5,  'food',          12.50,   'Lunch - Chipotle',        creditId,   'Visa Rewards'],
    [-6,  'shopping',      89.99,   'New running shoes',       creditId,   'Visa Rewards'],
    [-7,  'health',        25.00,   'Pharmacy prescription',   checkingId, 'Chase Checking'],
    [-8,  'food',           8.75,   'Morning coffee',          creditId,   'Visa Rewards'],
    [-9,  'utilities',     95.00,   'Electric bill',           checkingId, 'Chase Checking'],
    [-10, 'food',          35.00,   'Pizza night',             creditId,   'Visa Rewards'],
    [-12, 'subscriptions',  9.99,   'Spotify Premium',         creditId,   'Visa Rewards'],
    [-14, 'transport',     45.00,   'Gas fill-up',             checkingId, 'Chase Checking'],
    [-15, 'groceries',     94.30,   'Costco run',              checkingId, 'Chase Checking'],
    [-17, 'food',          22.00,   'Sushi takeout',           creditId,   'Visa Rewards'],
    [-18, 'shopping',      45.00,   'Amazon purchase',         creditId,   'Visa Rewards'],
    [-20, 'entertainment', 32.00,   'Movie tickets',           creditId,   'Visa Rewards'],
    [-22, 'health',       120.00,   'Gym membership',          checkingId, 'Chase Checking'],
    [-24, 'food',          18.50,   'Breakfast cafe',          creditId,   'Visa Rewards'],
    [-25, 'transport',     28.00,   'Uber rides',              creditId,   'Visa Rewards'],
    [-28, 'housing',     1800.00,   'Monthly rent',            checkingId, 'Chase Checking'],
    [-33, 'food',          55.00,   'Dinner out',              creditId,   'Visa Rewards'],
    [-36, 'groceries',    110.20,   'Weekly groceries',        checkingId, 'Chase Checking'],
    [-40, 'transport',     48.00,   'Monthly transit',         checkingId, 'Chase Checking'],
    [-42, 'utilities',     88.00,   'Internet bill',           checkingId, 'Chase Checking'],
    [-48, 'food',          30.00,   'Brunch',                  creditId,   'Visa Rewards'],
    [-55, 'shopping',     150.00,   'Clothing haul',           creditId,   'Visa Rewards'],
    [-58, 'housing',     1800.00,   'Monthly rent',            checkingId, 'Chase Checking'],
    [-60, 'health',        60.00,   'Doctor visit copay',      checkingId, 'Chase Checking'],
    [-65, 'entertainment', 25.00,   'Concert tickets',         creditId,   'Visa Rewards'],
    [-70, 'groceries',     98.50,   'Weekly groceries',        checkingId, 'Chase Checking'],
  ]

  const incomes = [
    [-1,  'salary',    3500.00, 'Bi-weekly paycheck',        checkingId, 'Chase Checking'],
    [-5,  'freelance',  450.00, 'Freelance design project',  checkingId, 'Chase Checking'],
    [-15, 'salary',    3500.00, 'Bi-weekly paycheck',        checkingId, 'Chase Checking'],
    [-20, 'bonus',      200.00, 'Performance bonus',         checkingId, 'Chase Checking'],
    [-30, 'salary',    3500.00, 'Bi-weekly paycheck',        checkingId, 'Chase Checking'],
    [-45, 'salary',    3500.00, 'Bi-weekly paycheck',        checkingId, 'Chase Checking'],
    [-50, 'freelance',  300.00, 'Logo design project',       checkingId, 'Chase Checking'],
    [-60, 'salary',    3500.00, 'Bi-weekly paycheck',        checkingId, 'Chase Checking'],
    [-75, 'salary',    3500.00, 'Bi-weekly paycheck',        checkingId, 'Chase Checking'],
  ]

  const makeTx = (type) => ([offset, category, amount, description, accountId, accountName]) => ({
    id: generateId(),
    date: makeDate(offset),
    category,
    amount,
    accountId,
    accountName,
    description,
    type,
    notes: '',
    isRecurring: false,
    tags: [],
    createdAt: new Date().toISOString(),
  })

  return {
    accounts,
    transactions: [...expenses.map(makeTx('expense')), ...incomes.map(makeTx('income'))],
  }
}
