import { useState } from 'react'
import { ACCOUNT_TYPES } from '../../utils/categories'
import AddAccountModal from './AddAccountModal'

export default function AccountsView({ finance }) {
  const { accounts, deleteAccount } = finance
  const [showAdd, setShowAdd] = useState(false)
  const [editAcc, setEditAcc] = useState(null)

  function handleDelete(account) {
    const txCount = finance.transactions.filter(t => t.accountId === account.id).length
    const msg = txCount > 0
      ? `Delete "${account.name}"? This will also remove ${txCount} associated transaction${txCount > 1 ? 's' : ''}.`
      : `Delete "${account.name}"?`
    if (confirm(msg)) deleteAccount(account)
  }

  return (
    <div className="page">
      <div className="nav-header">
        <h1 className="nav-title">Accounts</h1>
        <div className="nav-actions">
          <button className="icon-btn icon-btn-primary" onClick={() => setShowAdd(true)}>＋</button>
        </div>
      </div>

      <div className="page-content">
        {accounts.length === 0 ? (
          <div className="card">
            <div className="empty-state">
              <div className="icon">💳</div>
              <h3>No accounts yet</h3>
              <p>Add labels like "Chase Checking" or "Visa" to tag your transactions</p>
              <button className="btn btn-primary" style={{ marginTop: 16 }} onClick={() => setShowAdd(true)}>
                Add Account
              </button>
            </div>
          </div>
        ) : (
          <div className="card">
            {accounts.map((acc, i) => (
              <div key={acc.id}>
                <AccountCard
                  account={acc}
                  onEdit={() => setEditAcc(acc)}
                  onDelete={() => handleDelete(acc)}
                />
                {i < accounts.length - 1 && <div className="divider" style={{ marginLeft: 64 }} />}
              </div>
            ))}
          </div>
        )}
      </div>
      <div style={{ height: 8 }} />

      {showAdd && <AddAccountModal finance={finance} onClose={() => setShowAdd(false)} />}
      {editAcc  && <AddAccountModal finance={finance} editAccount={editAcc} onClose={() => setEditAcc(null)} />}
    </div>
  )
}

function AccountCard({ account, onEdit, onDelete }) {
  const type = ACCOUNT_TYPES[account.type] || ACCOUNT_TYPES.other

  return (
    <div className="acc-row" style={{ padding: '12px 16px' }}>
      <div className="acc-icon" style={{ background: type.color + '22' }}>
        <span style={{ fontSize: 18 }}>{type.emoji}</span>
      </div>
      <div className="acc-info">
        <div className="acc-name">{account.name}</div>
        <div className="acc-type">{type.label}</div>
      </div>
      <button
        style={{ background: 'none', border: 'none', color: 'var(--text2)', fontSize: 18, padding: '4px 6px', flexShrink: 0 }}
        onClick={() => {
          const choice = window.confirm(`Edit or delete "${account.name}"?\n\nOK = Edit  |  Cancel = Delete option`)
          if (choice) { onEdit() }
          else {
            if (window.confirm(`Delete "${account.name}"?`)) onDelete()
          }
        }}
      >···</button>
    </div>
  )
}
