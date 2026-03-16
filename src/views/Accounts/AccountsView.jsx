import { useState } from 'react'
import { formatCurrency } from '../../utils/formatters'
import { ACCOUNT_TYPES, LIABILITY_TYPES } from '../../utils/categories'
import AddAccountModal from './AddAccountModal'

export default function AccountsView({ finance }) {
  const { accounts, netWorth, totalAssets, totalLiabilities, deleteAccount } = finance
  const [showAdd,   setShowAdd]   = useState(false)
  const [editAcc,   setEditAcc]   = useState(null)

  const assets      = accounts.filter(a => !LIABILITY_TYPES.includes(a.type))
  const liabilities = accounts.filter(a =>  LIABILITY_TYPES.includes(a.type))

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
        {/* Net Worth summary */}
        <div className="nw-card">
          <div className="nw-label">Net Worth</div>
          <div className="nw-amount">{formatCurrency(netWorth)}</div>
          <div className="nw-row">
            <div className="nw-col">
              <div className="nw-col-label">Assets</div>
              <div className="nw-col-value">{formatCurrency(totalAssets)}</div>
            </div>
            <div className="nw-col">
              <div className="nw-col-label">Liabilities</div>
              <div className="nw-col-value">{formatCurrency(totalLiabilities)}</div>
            </div>
          </div>
        </div>

        {accounts.length === 0 ? (
          <div className="card">
            <div className="empty-state">
              <div className="icon">💳</div>
              <h3>No accounts yet</h3>
              <p>Add your checking, savings, and credit accounts to track your net worth</p>
              <button className="btn btn-primary" style={{ marginTop: 16 }} onClick={() => setShowAdd(true)}>
                Add Account
              </button>
            </div>
          </div>
        ) : (
          <>
            {assets.length > 0 && (
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
                  <span style={{ fontSize: 13, fontWeight: 600, color: 'var(--text2)', textTransform: 'uppercase', letterSpacing: '0.05em' }}>Assets</span>
                  <span style={{ fontSize: 13, fontWeight: 600, color: 'var(--green)' }}>{formatCurrency(totalAssets)}</span>
                </div>
                <div className="card">
                  {assets.map((acc, i) => (
                    <div key={acc.id}>
                      <AccountCard
                        account={acc}
                        onEdit={() => setEditAcc(acc)}
                        onDelete={() => handleDelete(acc)}
                      />
                      {i < assets.length - 1 && <div className="divider" style={{ marginLeft: 64 }} />}
                    </div>
                  ))}
                </div>
              </div>
            )}

            {liabilities.length > 0 && (
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
                  <span style={{ fontSize: 13, fontWeight: 600, color: 'var(--text2)', textTransform: 'uppercase', letterSpacing: '0.05em' }}>Liabilities</span>
                  <span style={{ fontSize: 13, fontWeight: 600, color: 'var(--red)' }}>{formatCurrency(totalLiabilities)}</span>
                </div>
                <div className="card">
                  {liabilities.map((acc, i) => (
                    <div key={acc.id}>
                      <AccountCard
                        account={acc}
                        onEdit={() => setEditAcc(acc)}
                        onDelete={() => handleDelete(acc)}
                      />
                      {i < liabilities.length - 1 && <div className="divider" style={{ marginLeft: 64 }} />}
                    </div>
                  ))}
                </div>
              </div>
            )}
          </>
        )}
      </div>
      <div style={{ height: 8 }} />

      {showAdd  && <AddAccountModal finance={finance} onClose={() => setShowAdd(false)} />}
      {editAcc  && <AddAccountModal finance={finance} editAccount={editAcc} onClose={() => setEditAcc(null)} />}
    </div>
  )
}

function AccountCard({ account, onEdit, onDelete }) {
  const type = ACCOUNT_TYPES[account.type] || ACCOUNT_TYPES.other
  const isLiability = LIABILITY_TYPES.includes(account.type)

  return (
    <div className="acc-row" style={{ padding: '12px 16px' }}>
      <div className="acc-icon" style={{ background: type.color + '22' }}>
        <span style={{ fontSize: 18 }}>{type.emoji}</span>
      </div>
      <div className="acc-info">
        <div className="acc-name">{account.name}</div>
        <div className="acc-type">
          {type.label}
          {account.lastFourDigits ? ` ···${account.lastFourDigits}` : ''}
        </div>
      </div>
      <div className="acc-balance" style={{ marginRight: 8 }}>
        <div className="acc-balance-amount" style={{ color: isLiability ? 'var(--red)' : 'var(--text)' }}>
          {formatCurrency(account.balance)}
        </div>
        <div className="acc-balance-label">{isLiability ? 'Owed' : 'Available'}</div>
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
