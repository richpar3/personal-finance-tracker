import { useState } from 'react'
import { generateId, toDateInputValue } from '../../utils/formatters'
import { CATEGORIES, EXPENSE_CATEGORIES, INCOME_CATEGORIES, ACCOUNT_TYPES } from '../../utils/categories'

export default function AddTransactionModal({ finance, onClose, editTransaction = null }) {
  const isEdit = !!editTransaction
  const [type,        setType]        = useState(editTransaction?.type || 'expense')
  const [amount,      setAmount]      = useState(editTransaction ? String(editTransaction.amount) : '')
  const [category,    setCategory]    = useState(editTransaction?.category || 'food')
  const [description, setDescription] = useState(editTransaction?.description || '')
  const [date,        setDate]        = useState(editTransaction ? toDateInputValue(editTransaction.date) : toDateInputValue(new Date().toISOString()))
  const [accountId,   setAccountId]   = useState(editTransaction?.accountId || finance.accounts[0]?.id || '')
  const [notes,       setNotes]       = useState(editTransaction?.notes || '')

  const categories = type === 'income' ? INCOME_CATEGORIES : EXPENSE_CATEGORIES

  // Keep category in sync when type changes
  function handleTypeChange(newType) {
    setType(newType)
    const cats = newType === 'income' ? INCOME_CATEGORIES : EXPENSE_CATEGORIES
    if (!cats.includes(category)) setCategory(cats[0])
  }

  function handleSubmit(e) {
    e.preventDefault()
    const amt = parseFloat(amount)
    if (!amt || amt <= 0) { alert('Please enter a valid amount'); return }
    if (!accountId) { alert('Please add an account first'); return }
    const acc = finance.accounts.find(a => a.id === accountId)

    const tx = {
      id:          isEdit ? editTransaction.id : generateId(),
      date:        new Date(date).toISOString(),
      category,
      amount:      amt,
      accountId,
      accountName: acc?.name || '',
      description: description.trim(),
      type,
      notes:       notes.trim(),
      isRecurring: false,
      tags:        [],
      createdAt:   isEdit ? editTransaction.createdAt : new Date().toISOString(),
    }

    if (isEdit) finance.updateTransaction(tx)
    else        finance.addTransaction(tx)
    onClose()
  }

  return (
    <div className="modal-overlay" onClick={e => e.target === e.currentTarget && onClose()}>
      <div className="modal-sheet">
        <div className="modal-handle" />
        <div className="modal-header">
          <span className="modal-title">{isEdit ? 'Edit Transaction' : 'Add Transaction'}</span>
          <button className="modal-close" onClick={onClose}>✕</button>
        </div>
        <div className="modal-body">
          <form onSubmit={handleSubmit}>

            {/* Type toggle */}
            <div className="form-group">
              <div className="type-toggle">
                <button type="button" className={`type-toggle-btn${type === 'expense' ? ' active-expense' : ''}`} onClick={() => handleTypeChange('expense')}>↑ Expense</button>
                <button type="button" className={`type-toggle-btn${type === 'income'  ? ' active-income'  : ''}`} onClick={() => handleTypeChange('income')}>↓ Income</button>
              </div>
            </div>

            {/* Amount */}
            <div className="form-group">
              <label className="form-label">Amount</label>
              <div className="amount-wrapper">
                <span className="amount-prefix">$</span>
                <input
                  className="form-input form-input-amount"
                  type="number"
                  inputMode="decimal"
                  step="0.01"
                  min="0"
                  placeholder="0.00"
                  value={amount}
                  onChange={e => setAmount(e.target.value)}
                  required
                  autoFocus
                />
              </div>
            </div>

            {/* Category */}
            <div className="form-group">
              <label className="form-label">Category</label>
              <select className="form-select" value={category} onChange={e => setCategory(e.target.value)}>
                {categories.map(k => (
                  <option key={k} value={k}>{CATEGORIES[k].emoji} {CATEGORIES[k].label}</option>
                ))}
                <option value="other">📋 Other</option>
              </select>
            </div>

            {/* Description */}
            <div className="form-group">
              <label className="form-label">Description</label>
              <input
                className="form-input"
                type="text"
                placeholder="What was it for?"
                value={description}
                onChange={e => setDescription(e.target.value)}
              />
            </div>

            {/* Date */}
            <div className="form-group">
              <label className="form-label">Date</label>
              <input
                className="form-input"
                type="date"
                value={date}
                onChange={e => setDate(e.target.value)}
                required
              />
            </div>

            {/* Account */}
            <div className="form-group">
              <label className="form-label">Account</label>
              {finance.accounts.length === 0 ? (
                <p style={{ fontSize: 14, color: 'var(--text2)', padding: '10px 14px', background: 'var(--bg)', borderRadius: 10 }}>
                  No accounts yet — add one in the Accounts tab first.
                </p>
              ) : (
                <select className="form-select" value={accountId} onChange={e => setAccountId(e.target.value)}>
                  {finance.accounts.map(a => (
                    <option key={a.id} value={a.id}>{ACCOUNT_TYPES[a.type]?.emoji} {a.name}</option>
                  ))}
                </select>
              )}
            </div>

            {/* Notes */}
            <div className="form-group">
              <label className="form-label">Notes (optional)</label>
              <textarea
                className="form-textarea"
                placeholder="Any extra details…"
                value={notes}
                onChange={e => setNotes(e.target.value)}
              />
            </div>

            <button type="submit" className="btn btn-primary btn-full" style={{ marginTop: 4 }}>
              {isEdit ? 'Save Changes' : 'Add Transaction'}
            </button>
          </form>
        </div>
      </div>
    </div>
  )
}
