import { useState, useEffect, useMemo, useRef } from 'react'
import { generateSampleData } from '../utils/sampleData'
import { LIABILITY_TYPES } from '../utils/categories'

const KEYS = {
  transactions: 'pft_transactions',
  accounts:     'pft_accounts',
  demoMode:     'pft_demo_mode',
}

function load(key, fallback) {
  try {
    const v = localStorage.getItem(key)
    return v ? JSON.parse(v) : fallback
  } catch { return fallback }
}

function save(key, value) {
  localStorage.setItem(key, JSON.stringify(value))
}

export default function useFinance() {
  const [transactions, setTransactions] = useState([])
  const [accounts,     setAccounts]     = useState([])
  const [isDemoMode,   setIsDemoModeRaw] = useState(false)
  const [selectedPeriod, setSelectedPeriod] = useState('month')
  const [initialized,  setInitialized]  = useState(false)

  // Ref so CRUD callbacks can read current transactions without stale closure
  const txRef = useRef([])
  useEffect(() => { txRef.current = transactions }, [transactions])

  // ── Initial load ──────────────────────────────────────────────────────────
  useEffect(() => {
    const demoMode = localStorage.getItem(KEYS.demoMode) === 'true'
    if (demoMode) {
      const { transactions: t, accounts: a } = generateSampleData()
      setTransactions(t)
      setAccounts(a)
      setIsDemoModeRaw(true)
    } else {
      const savedAccounts = load(KEYS.accounts, [])
      if (savedAccounts.length === 0) {
        const { transactions: t, accounts: a } = generateSampleData()
        setTransactions(t)
        setAccounts(a)
        save(KEYS.transactions, t)
        save(KEYS.accounts, a)
      } else {
        setTransactions(load(KEYS.transactions, []))
        setAccounts(savedAccounts)
      }
    }
    setInitialized(true)
  }, [])

  // ── Auto-persist (skip demo mode and first render) ────────────────────────
  useEffect(() => {
    if (!initialized || isDemoMode) return
    save(KEYS.transactions, transactions)
    save(KEYS.accounts, accounts)
  }, [transactions, accounts, isDemoMode, initialized])

  // ── Demo mode ─────────────────────────────────────────────────────────────
  function setDemoMode(enabled) {
    localStorage.setItem(KEYS.demoMode, enabled ? 'true' : 'false')
    setIsDemoModeRaw(enabled)
    if (enabled) {
      const { transactions: t, accounts: a } = generateSampleData()
      setTransactions(t)
      setAccounts(a)
    } else {
      setAccounts(load(KEYS.accounts, []))
      setTransactions(load(KEYS.transactions, []))
    }
  }

  // ── CRUD: Transactions ────────────────────────────────────────────────────
  function addTransaction(tx) {
    setTransactions(prev => [...prev, tx])
    setAccounts(prev => prev.map(acc => {
      if (acc.id !== tx.accountId) return acc
      const delta = tx.type === 'income' ? tx.amount : -tx.amount
      return { ...acc, balance: acc.balance + delta }
    }))
  }

  function deleteTransaction(tx) {
    setTransactions(prev => prev.filter(t => t.id !== tx.id))
    setAccounts(prev => prev.map(acc => {
      if (acc.id !== tx.accountId) return acc
      const delta = tx.type === 'income' ? -tx.amount : tx.amount
      return { ...acc, balance: acc.balance + delta }
    }))
  }

  function updateTransaction(updated) {
    const old = txRef.current.find(t => t.id === updated.id)
    if (!old) return
    setTransactions(prev => prev.map(t => t.id === updated.id ? updated : t))
    setAccounts(prev => prev.map(acc => {
      let balance = acc.balance
      if (acc.id === old.accountId) {
        balance += old.type === 'income' ? -old.amount : old.amount
      }
      if (acc.id === updated.accountId) {
        balance += updated.type === 'income' ? updated.amount : -updated.amount
      }
      if (acc.id === old.accountId || acc.id === updated.accountId) {
        return { ...acc, balance }
      }
      return acc
    }))
  }

  // ── CRUD: Accounts ────────────────────────────────────────────────────────
  function addAccount(account) {
    setAccounts(prev => [...prev, account])
  }

  function deleteAccount(account) {
    setAccounts(prev => prev.filter(a => a.id !== account.id))
    setTransactions(prev => prev.filter(t => t.accountId !== account.id))
  }

  function updateAccount(updated) {
    setAccounts(prev => prev.map(a => a.id === updated.id ? updated : a))
  }

  // ── Export / Import ───────────────────────────────────────────────────────
  function exportBackup() {
    const realTx  = isDemoMode ? load(KEYS.transactions, []) : transactions
    const realAcc = isDemoMode ? load(KEYS.accounts,     []) : accounts
    const backup = { exportDate: new Date().toISOString(), transactions: realTx, accounts: realAcc }
    const blob = new Blob([JSON.stringify(backup, null, 2)], { type: 'application/json' })
    const url  = URL.createObjectURL(blob)
    const a    = document.createElement('a')
    a.href     = url
    a.download = `finance-backup-${new Date().toISOString().split('T')[0]}.json`
    a.click()
    URL.revokeObjectURL(url)
  }

  function importBackup(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader()
      reader.onload = (e) => {
        try {
          const backup = JSON.parse(e.target.result)
          if (!Array.isArray(backup.transactions) || !Array.isArray(backup.accounts)) {
            reject(new Error('Invalid backup file — missing transactions or accounts'))
            return
          }
          setIsDemoModeRaw(false)
          localStorage.setItem(KEYS.demoMode, 'false')
          setTransactions(backup.transactions)
          setAccounts(backup.accounts)
          save(KEYS.transactions, backup.transactions)
          save(KEYS.accounts, backup.accounts)
          resolve()
        } catch (err) { reject(err) }
      }
      reader.onerror = () => reject(new Error('Failed to read file'))
      reader.readAsText(file)
    })
  }

  // ── Derived data ──────────────────────────────────────────────────────────
  const filteredTransactions = useMemo(() => {
    const now   = new Date()
    const start = periodStart(selectedPeriod, now)
    return transactions
      .filter(t => { const d = new Date(t.date); return d >= start && d <= now })
      .sort((a, b) => new Date(b.date) - new Date(a.date))
  }, [transactions, selectedPeriod])

  const netWorth       = useMemo(() => accounts.reduce((s, a) => s + (LIABILITY_TYPES.includes(a.type) ? -Math.abs(a.balance) : a.balance), 0), [accounts])
  const totalAssets    = useMemo(() => accounts.filter(a => !LIABILITY_TYPES.includes(a.type)).reduce((s, a) => s + a.balance, 0), [accounts])
  const totalLiabilities = useMemo(() => accounts.filter(a => LIABILITY_TYPES.includes(a.type)).reduce((s, a) => s + a.balance, 0), [accounts])
  const totalIncome    = useMemo(() => filteredTransactions.filter(t => t.type === 'income').reduce((s, t) => s + t.amount, 0), [filteredTransactions])
  const totalExpenses  = useMemo(() => filteredTransactions.filter(t => t.type === 'expense').reduce((s, t) => s + t.amount, 0), [filteredTransactions])
  const cashFlow       = totalIncome - totalExpenses
  const savingsRate    = totalIncome > 0 ? (cashFlow / totalIncome) * 100 : 0
  const recentTransactions = useMemo(() => [...transactions].sort((a, b) => new Date(b.date) - new Date(a.date)).slice(0, 5), [transactions])

  const expensesByCategory = useMemo(() => {
    const expenses = filteredTransactions.filter(t => t.type === 'expense')
    const total    = expenses.reduce((s, t) => s + t.amount, 0)
    const map = {}
    for (const t of expenses) map[t.category] = (map[t.category] || 0) + t.amount
    return Object.entries(map)
      .map(([category, amount]) => ({ category, amount, percentage: total > 0 ? (amount / total) * 100 : 0 }))
      .sort((a, b) => b.amount - a.amount)
  }, [filteredTransactions])

  const monthlyTrend = useMemo(() => {
    const MONTHS = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
    const now = new Date()
    return Array.from({ length: 6 }, (_, i) => {
      const d     = new Date(now.getFullYear(), now.getMonth() - (5 - i), 1)
      const start = new Date(d.getFullYear(), d.getMonth(), 1)
      const end   = new Date(d.getFullYear(), d.getMonth() + 1, 1)
      const monthTx = transactions.filter(t => { const td = new Date(t.date); return td >= start && td < end })
      const income   = monthTx.filter(t => t.type === 'income').reduce((s, t) => s + t.amount, 0)
      const expenses = monthTx.filter(t => t.type === 'expense').reduce((s, t) => s + t.amount, 0)
      return { month: MONTHS[d.getMonth()], income, expenses, cashFlow: income - expenses, date: d.toISOString() }
    })
  }, [transactions])

  const dailySpending = useMemo(() => {
    const now = new Date()
    return Array.from({ length: 30 }, (_, i) => {
      const d     = new Date(now); d.setDate(d.getDate() - (29 - i))
      const start = new Date(d.getFullYear(), d.getMonth(), d.getDate())
      const end   = new Date(d.getFullYear(), d.getMonth(), d.getDate() + 1)
      const amount = transactions.filter(t => t.type === 'expense').filter(t => { const td = new Date(t.date); return td >= start && td < end }).reduce((s, t) => s + t.amount, 0)
      return { day: d.getDate().toString(), amount, date: d.toISOString() }
    })
  }, [transactions])

  return {
    transactions, accounts, isDemoMode, selectedPeriod, setSelectedPeriod,
    setDemoMode, addTransaction, deleteTransaction, updateTransaction,
    addAccount, deleteAccount, updateAccount, exportBackup, importBackup,
    filteredTransactions, netWorth, totalAssets, totalLiabilities,
    totalIncome, totalExpenses, cashFlow, savingsRate,
    recentTransactions, expensesByCategory, monthlyTrend, dailySpending,
  }
}

function periodStart(period, now) {
  switch (period) {
    case 'week':    return new Date(now - 7 * 86400000)
    case 'month':   return new Date(now.getFullYear(), now.getMonth() - 1, now.getDate())
    case 'quarter': return new Date(now.getFullYear(), now.getMonth() - 3, now.getDate())
    case 'year':    return new Date(now.getFullYear() - 1, now.getMonth(), now.getDate())
    default:        return new Date(0)
  }
}
