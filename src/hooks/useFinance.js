import { useState, useEffect, useMemo, useRef } from 'react'
import { generateSampleData } from '../utils/sampleData'
import { LIABILITY_TYPES } from '../utils/categories'
import { supabase } from '../lib/supabase'

const KEYS = {
  transactions: 'pft_transactions',
  accounts:     'pft_accounts',
}

function loadLocal(key, fallback) {
  try {
    const v = localStorage.getItem(key)
    return v ? JSON.parse(v) : fallback
  } catch { return fallback }
}

function saveLocal(key, value) {
  localStorage.setItem(key, JSON.stringify(value))
}

// ── Supabase helpers ────────────────────────────────────────────────────────

function dbToAccount(row) {
  return {
    id:             row.id,
    name:           row.name,
    type:           row.type,
    balance:        row.balance,
    currency:       row.currency ?? 'USD',
    lastFourDigits: row.last_four_digits ?? '',
    color:          row.color ?? '#4A90D9',
    notes:          row.notes ?? '',
  }
}

function accountToDb(a, userId) {
  return {
    id:               a.id,
    name:             a.name,
    type:             a.type,
    balance:          a.balance,
    currency:         a.currency ?? 'USD',
    last_four_digits: a.lastFourDigits ?? '',
    color:            a.color ?? '#4A90D9',
    notes:            a.notes ?? '',
    user_id:          userId,
  }
}

function dbToTransaction(row) {
  return {
    id:          row.id,
    date:        row.date,
    category:    row.category,
    amount:      row.amount,
    accountId:   row.account_id,
    accountName: row.account_name,
    description: row.description ?? '',
    type:        row.type,
    notes:       row.notes ?? '',
    isRecurring: row.is_recurring ?? false,
    tags:        row.tags ?? [],
  }
}

function transactionToDb(t, userId) {
  return {
    id:           t.id,
    date:         t.date,
    category:     t.category,
    amount:       t.amount,
    account_id:   t.accountId,
    account_name: t.accountName,
    description:  t.description ?? '',
    type:         t.type,
    notes:        t.notes ?? '',
    is_recurring: t.isRecurring ?? false,
    tags:         t.tags ?? [],
    user_id:      userId,
  }
}

export default function useFinance() {
  const [transactions,   setTransactions]  = useState([])
  const [accounts,       setAccounts]      = useState([])
  const [selectedPeriod, setSelectedPeriod] = useState('month')
  const [user,           setUser]          = useState(null)
  const [authLoading,    setAuthLoading]   = useState(true)
  const [isSyncing,      setIsSyncing]     = useState(false)
  const [syncError,      setSyncError]     = useState(null)
  const [isDemo,         setIsDemo]        = useState(false)

  const txRef = useRef([])
  useEffect(() => { txRef.current = transactions }, [transactions])

  // ── Auth listener ──────────────────────────────────────────────────────────
  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setUser(session?.user ?? null)
      setAuthLoading(false)
      if (session?.user) syncFromSupabase(session.user)
    })

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      const u = session?.user ?? null
      setUser(u)
      setAuthLoading(false)
      if (u) {
        syncFromSupabase(u)
      } else {
        setTransactions([])
        setAccounts([])
        localStorage.removeItem(KEYS.transactions)
        localStorage.removeItem(KEYS.accounts)
      }
    })
    return () => subscription.unsubscribe()
  }, [])

  // ── Supabase sync ──────────────────────────────────────────────────────────
  async function syncFromSupabase(u) {
    setIsSyncing(true)
    setSyncError(null)
    try {
      // Show local cache immediately while fetching
      const cached = loadLocal(KEYS.accounts, [])
      if (cached.length > 0) {
        setAccounts(cached)
        setTransactions(loadLocal(KEYS.transactions, []))
      }

      const [{ data: accRows, error: accErr }, { data: txRows, error: txErr }] = await Promise.all([
        supabase.from('accounts').select('*').eq('user_id', u.id),
        supabase.from('transactions').select('*').eq('user_id', u.id),
      ])
      if (accErr) throw accErr
      if (txErr)  throw txErr

      if (accRows.length === 0) {
        // First sign-in: seed sample data and push to Supabase
        const { transactions: t, accounts: a } = generateSampleData()
        setTransactions(t)
        setAccounts(a)
        saveLocal(KEYS.transactions, t)
        saveLocal(KEYS.accounts, a)
        await Promise.all([
          supabase.from('accounts').insert(a.map(acc => accountToDb(acc, u.id))),
          supabase.from('transactions').insert(t.map(tx => transactionToDb(tx, u.id))),
        ])
      } else {
        const a = accRows.map(dbToAccount)
        const t = txRows.map(dbToTransaction)
        setAccounts(a)
        setTransactions(t)
        saveLocal(KEYS.accounts, a)
        saveLocal(KEYS.transactions, t)
      }
    } catch (err) {
      setSyncError(err.message)
    } finally {
      setIsSyncing(false)
    }
  }

  // ── Auth actions ───────────────────────────────────────────────────────────
  async function signOut() {
    await supabase.auth.signOut()
  }

  // ── Demo mode ──────────────────────────────────────────────────────────────
  function enterDemoMode() {
    const { transactions: t, accounts: a } = generateSampleData()
    setTransactions(t)
    setAccounts(a)
    setIsDemo(true)
  }

  function exitDemoMode() {
    setTransactions([])
    setAccounts([])
    setIsDemo(false)
  }

  // ── CRUD: Transactions ────────────────────────────────────────────────────
  function addTransaction(tx) {
    setTransactions(prev => { const next = [...prev, tx]; saveLocal(KEYS.transactions, next); return next })
    setAccounts(prev => {
      const next = prev.map(acc => {
        if (acc.id !== tx.accountId) return acc
        const delta = tx.type === 'income' ? tx.amount : -tx.amount
        return { ...acc, balance: acc.balance + delta }
      })
      saveLocal(KEYS.accounts, next)
      return next
    })
    if (user && !isDemo) {
      supabase.from('transactions').insert(transactionToDb(tx, user.id)).then(({ error }) => { if (error) setSyncError(error.message) })
      setAccounts(prev => {
        const acc = prev.find(a => a.id === tx.accountId)
        if (acc) supabase.from('accounts').update(accountToDb(acc, user.id)).eq('id', acc.id).then(({ error }) => { if (error) setSyncError(error.message) })
        return prev
      })
    }
  }

  function deleteTransaction(tx) {
    setTransactions(prev => { const next = prev.filter(t => t.id !== tx.id); saveLocal(KEYS.transactions, next); return next })
    setAccounts(prev => {
      const next = prev.map(acc => {
        if (acc.id !== tx.accountId) return acc
        const delta = tx.type === 'income' ? -tx.amount : tx.amount
        return { ...acc, balance: acc.balance + delta }
      })
      saveLocal(KEYS.accounts, next)
      return next
    })
    if (user && !isDemo) {
      supabase.from('transactions').delete().eq('id', tx.id).then(({ error }) => { if (error) setSyncError(error.message) })
      setAccounts(prev => {
        const acc = prev.find(a => a.id === tx.accountId)
        if (acc) supabase.from('accounts').update(accountToDb(acc, user.id)).eq('id', acc.id).then(({ error }) => { if (error) setSyncError(error.message) })
        return prev
      })
    }
  }

  function updateTransaction(updated) {
    const old = txRef.current.find(t => t.id === updated.id)
    if (!old) return
    setTransactions(prev => { const next = prev.map(t => t.id === updated.id ? updated : t); saveLocal(KEYS.transactions, next); return next })
    setAccounts(prev => {
      const next = prev.map(acc => {
        let balance = acc.balance
        if (acc.id === old.accountId)     balance += old.type === 'income' ? -old.amount : old.amount
        if (acc.id === updated.accountId) balance += updated.type === 'income' ? updated.amount : -updated.amount
        if (acc.id === old.accountId || acc.id === updated.accountId) return { ...acc, balance }
        return acc
      })
      saveLocal(KEYS.accounts, next)
      return next
    })
    if (user && !isDemo) {
      supabase.from('transactions').update(transactionToDb(updated, user.id)).eq('id', updated.id).then(({ error }) => { if (error) setSyncError(error.message) })
      setAccounts(prev => {
        const ids = new Set([old.accountId, updated.accountId])
        for (const acc of prev) {
          if (ids.has(acc.id)) supabase.from('accounts').update(accountToDb(acc, user.id)).eq('id', acc.id).then(({ error }) => { if (error) setSyncError(error.message) })
        }
        return prev
      })
    }
  }

  // ── CRUD: Accounts ────────────────────────────────────────────────────────
  function addAccount(account) {
    setAccounts(prev => { const next = [...prev, account]; saveLocal(KEYS.accounts, next); return next })
    if (user && !isDemo) supabase.from('accounts').insert(accountToDb(account, user.id)).then(({ error }) => { if (error) setSyncError(error.message) })
  }

  function deleteAccount(account) {
    setAccounts(prev => { const next = prev.filter(a => a.id !== account.id); saveLocal(KEYS.accounts, next); return next })
    setTransactions(prev => { const next = prev.filter(t => t.accountId !== account.id); saveLocal(KEYS.transactions, next); return next })
    if (user && !isDemo) supabase.from('accounts').delete().eq('id', account.id).then(({ error }) => { if (error) setSyncError(error.message) })
  }

  function updateAccount(updated) {
    setAccounts(prev => { const next = prev.map(a => a.id === updated.id ? updated : a); saveLocal(KEYS.accounts, next); return next })
    if (user && !isDemo) supabase.from('accounts').update(accountToDb(updated, user.id)).eq('id', updated.id).then(({ error }) => { if (error) setSyncError(error.message) })
  }

  // ── Export / Import ───────────────────────────────────────────────────────
  function exportBackup() {
    const backup = { exportDate: new Date().toISOString(), transactions, accounts }
    const blob = new Blob([JSON.stringify(backup, null, 2)], { type: 'application/json' })
    const url  = URL.createObjectURL(blob)
    const a    = document.createElement('a')
    a.href = url
    a.download = `finance-backup-${new Date().toISOString().split('T')[0]}.json`
    a.click()
    URL.revokeObjectURL(url)
  }

  function importBackup(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader()
      reader.onload = async (e) => {
        try {
          const backup = JSON.parse(e.target.result)
          if (!Array.isArray(backup.transactions) || !Array.isArray(backup.accounts)) {
            reject(new Error('Invalid backup file')); return
          }
          const validAccount = a =>
            a && typeof a === 'object' &&
            typeof a.id === 'string' && a.id.length > 0 &&
            typeof a.name === 'string' && a.name.length > 0 &&
            typeof a.type === 'string' &&
            typeof a.balance === 'number' && isFinite(a.balance)
          const validTransaction = t =>
            t && typeof t === 'object' &&
            typeof t.id === 'string' && t.id.length > 0 &&
            typeof t.date === 'string' && !isNaN(Date.parse(t.date)) &&
            typeof t.amount === 'number' && isFinite(t.amount) && t.amount > 0 &&
            (t.type === 'income' || t.type === 'expense') &&
            typeof t.accountId === 'string' && t.accountId.length > 0
          if (!backup.accounts.every(validAccount)) {
            reject(new Error('Backup contains invalid account data')); return
          }
          if (!backup.transactions.every(validTransaction)) {
            reject(new Error('Backup contains invalid transaction data')); return
          }
          const accounts = backup.accounts.map(a => ({
            id: a.id, name: String(a.name).slice(0, 100), type: a.type,
            balance: a.balance, currency: a.currency ?? 'USD',
            lastFourDigits: String(a.lastFourDigits ?? '').replace(/\D/g, '').slice(0, 4),
            color: /^#[0-9A-Fa-f]{6}$/.test(a.color) ? a.color : '#4A90D9',
            notes: String(a.notes ?? '').slice(0, 500),
          }))
          const transactions = backup.transactions.map(t => ({
            id: t.id, date: t.date, category: String(t.category ?? ''),
            amount: t.amount, accountId: t.accountId,
            accountName: String(t.accountName ?? '').slice(0, 100),
            description: String(t.description ?? '').slice(0, 200),
            type: t.type, notes: String(t.notes ?? '').slice(0, 500),
            isRecurring: Boolean(t.isRecurring),
            tags: Array.isArray(t.tags) ? t.tags.filter(tag => typeof tag === 'string').slice(0, 10) : [],
          }))
          setTransactions(transactions)
          setAccounts(accounts)
          saveLocal(KEYS.transactions, transactions)
          saveLocal(KEYS.accounts, accounts)
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

  const netWorth         = useMemo(() => accounts.reduce((s, a) => s + (LIABILITY_TYPES.includes(a.type) ? -Math.abs(a.balance) : a.balance), 0), [accounts])
  const totalAssets      = useMemo(() => accounts.filter(a => !LIABILITY_TYPES.includes(a.type)).reduce((s, a) => s + a.balance, 0), [accounts])
  const totalLiabilities = useMemo(() => accounts.filter(a => LIABILITY_TYPES.includes(a.type)).reduce((s, a) => s + a.balance, 0), [accounts])
  const totalIncome      = useMemo(() => filteredTransactions.filter(t => t.type === 'income').reduce((s, t) => s + t.amount, 0), [filteredTransactions])
  const totalExpenses    = useMemo(() => filteredTransactions.filter(t => t.type === 'expense').reduce((s, t) => s + t.amount, 0), [filteredTransactions])
  const cashFlow         = totalIncome - totalExpenses
  const savingsRate      = totalIncome > 0 ? (cashFlow / totalIncome) * 100 : 0
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
    transactions, accounts, selectedPeriod, setSelectedPeriod,
    user, authLoading, isSyncing, syncError, signOut,
    isDemo, enterDemoMode, exitDemoMode,
    addTransaction, deleteTransaction, updateTransaction,
    addAccount, deleteAccount, updateAccount,
    exportBackup, importBackup,
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
