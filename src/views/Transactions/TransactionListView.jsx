import { useState, useMemo } from 'react'
import { formatCurrency, formatDateGroup, formatDateShort } from '../../utils/formatters'
import { CATEGORIES, EXPENSE_CATEGORIES, INCOME_CATEGORIES } from '../../utils/categories'
import AddTransactionModal from './AddTransactionModal'

const TYPE_FILTERS = [
  { key: 'all',     label: 'All' },
  { key: 'expense', label: 'Expenses' },
  { key: 'income',  label: 'Income' },
]

export default function TransactionListView({ finance, onAddTx }) {
  const [search,      setSearch]      = useState('')
  const [typeFilter,  setTypeFilter]  = useState('all')
  const [catFilters,  setCatFilters]  = useState([])
  const [showFilters, setShowFilters] = useState(false)
  const [editTx,      setEditTx]      = useState(null)

  const filtered = useMemo(() => {
    let txs = [...finance.transactions].sort((a, b) => new Date(b.date) - new Date(a.date))
    if (typeFilter !== 'all')   txs = txs.filter(t => t.type === typeFilter)
    if (catFilters.length > 0)  txs = txs.filter(t => catFilters.includes(t.category))
    if (search.trim()) {
      const q = search.toLowerCase()
      txs = txs.filter(t =>
        t.description.toLowerCase().includes(q) ||
        (CATEGORIES[t.category]?.label || '').toLowerCase().includes(q) ||
        t.accountName.toLowerCase().includes(q)
      )
    }
    return txs
  }, [finance.transactions, typeFilter, catFilters, search])

  // Group by date label
  const grouped = useMemo(() => {
    const groups = {}
    for (const tx of filtered) {
      const label = formatDateGroup(tx.date)
      if (!groups[label]) groups[label] = { label, txs: [], totalExpenses: 0 }
      groups[label].txs.push(tx)
      if (tx.type === 'expense') groups[label].totalExpenses += tx.amount
    }
    return Object.values(groups)
  }, [filtered])

  const hasFilters = typeFilter !== 'all' || catFilters.length > 0

  function toggleCatFilter(cat) {
    setCatFilters(prev => prev.includes(cat) ? prev.filter(c => c !== cat) : [...prev, cat])
  }

  return (
    <div className="page">
      {/* Header */}
      <div className="nav-header">
        <h1 className="nav-title">Transactions</h1>
        <div className="nav-actions">
          <button
            className="icon-btn"
            style={hasFilters ? { background: 'var(--blue)', color: 'white' } : {}}
            onClick={() => setShowFilters(true)}
          >🔍</button>
        </div>
      </div>

      <div style={{ padding: '0 20px 12px' }}>
        {/* Search */}
        <div className="search-bar" style={{ marginBottom: 12 }}>
          <span className="search-icon">🔍</span>
          <input
            className="search-input"
            placeholder="Search transactions…"
            value={search}
            onChange={e => setSearch(e.target.value)}
          />
          {search && <button style={{ background: 'none', border: 'none', color: 'var(--text2)', fontSize: 16 }} onClick={() => setSearch('')}>✕</button>}
        </div>

        {/* Type filter chips */}
        <div style={{ display: 'flex', gap: 8, overflowX: 'auto', paddingBottom: 4, scrollbarWidth: 'none' }}>
          {TYPE_FILTERS.map(f => (
            <button
              key={f.key}
              className={`filter-chip ${f.key}${typeFilter === f.key ? ' active' : ''}`}
              onClick={() => setTypeFilter(f.key)}
            >{f.label}</button>
          ))}
          {catFilters.map(cat => (
            <button key={cat} className="filter-chip active" onClick={() => toggleCatFilter(cat)}>
              {CATEGORIES[cat]?.emoji} {CATEGORIES[cat]?.label} ✕
            </button>
          ))}
        </div>
      </div>

      {/* List */}
      <div style={{ padding: '0 20px' }}>
        {filtered.length === 0 ? (
          <div className="empty-state" style={{ paddingTop: 60 }}>
            <div className="icon">{search || hasFilters ? '🔍' : '🧾'}</div>
            <h3>{search || hasFilters ? 'No results found' : 'No transactions yet'}</h3>
            <p>{search || hasFilters ? 'Try adjusting your filters' : 'Tap + to add your first one'}</p>
          </div>
        ) : (
          grouped.map(group => (
            <div key={group.label} className="date-group">
              <div className="date-group-header">
                <span>{group.label}</span>
                {group.totalExpenses > 0 && (
                  <span style={{ color: 'var(--red)' }}>−{formatCurrency(group.totalExpenses)}</span>
                )}
              </div>
              <div className="card">
                {group.txs.map((tx, i) => (
                  <div key={tx.id}>
                    <TxRow
                      tx={tx}
                      onEdit={() => setEditTx(tx)}
                      onDelete={() => {
                        if (confirm(`Delete "${tx.description || CATEGORIES[tx.category]?.label}"?`)) {
                          finance.deleteTransaction(tx)
                        }
                      }}
                    />
                    {i < group.txs.length - 1 && <div className="divider" />}
                  </div>
                ))}
              </div>
            </div>
          ))
        )}
      </div>

      {/* Filter sheet */}
      {showFilters && (
        <FilterSheet
          catFilters={catFilters}
          onToggleCat={toggleCatFilter}
          onClear={() => { setCatFilters([]); setTypeFilter('all') }}
          onClose={() => setShowFilters(false)}
        />
      )}

      {/* Edit modal */}
      {editTx && (
        <AddTransactionModal
          finance={finance}
          editTransaction={editTx}
          onClose={() => setEditTx(null)}
        />
      )}
    </div>
  )
}

function TxRow({ tx, onEdit, onDelete }) {
  const cat = CATEGORIES[tx.category] || CATEGORIES.other
  return (
    <div className="tx-row" style={{ paddingLeft: 12, paddingRight: 12 }}>
      <div className="tx-icon" style={{ background: cat.color + '22' }}>{cat.emoji}</div>
      <div className="tx-info">
        <div className="tx-desc">{tx.description || cat.label}</div>
        <div className="tx-meta">{cat.label} · {tx.accountName}</div>
      </div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
        <div>
          <div className={`tx-amount ${tx.type}`}>
            {tx.type === 'income' ? '+' : '−'}{formatCurrency(tx.amount)}
          </div>
          <div className="tx-date">{formatDateShort(tx.date)}</div>
        </div>
        <button
          style={{ background: 'none', border: 'none', padding: '4px 6px', color: 'var(--text2)', fontSize: 16, flexShrink: 0 }}
          onClick={e => {
            e.stopPropagation()
            const choice = window.confirm('Edit or delete this transaction?\n\nPress OK to edit, Cancel to see delete option.')
            if (choice) { onEdit() }
            else {
              if (window.confirm('Delete this transaction?')) onDelete()
            }
          }}
        >···</button>
      </div>
    </div>
  )
}

function FilterSheet({ catFilters, onToggleCat, onClear, onClose }) {
  const allCats = [...EXPENSE_CATEGORIES, ...INCOME_CATEGORIES, 'other']
  return (
    <div className="modal-overlay" onClick={e => e.target === e.currentTarget && onClose()}>
      <div className="modal-sheet">
        <div className="modal-handle" />
        <div className="modal-header">
          <span className="modal-title">Filter by Category</span>
          <button className="modal-close" onClick={onClose}>✕</button>
        </div>
        <div className="modal-body">
          {catFilters.length > 0 && (
            <button className="btn btn-secondary btn-full" style={{ marginBottom: 16 }} onClick={onClear}>
              Clear All Filters
            </button>
          )}
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
            {allCats.map(cat => {
              const c = CATEGORIES[cat]
              const active = catFilters.includes(cat)
              return (
                <button
                  key={cat}
                  onClick={() => onToggleCat(cat)}
                  style={{
                    padding: '7px 14px',
                    borderRadius: 999,
                    border: `1.5px solid ${active ? c.color : 'var(--border)'}`,
                    background: active ? c.color + '22' : 'transparent',
                    color: active ? c.color : 'var(--text)',
                    fontSize: 13,
                    fontWeight: active ? 600 : 400,
                    cursor: 'pointer',
                  }}
                >{c.emoji} {c.label}</button>
              )
            })}
          </div>
        </div>
      </div>
    </div>
  )
}
