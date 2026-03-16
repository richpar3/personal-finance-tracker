import { BarChart, Bar, XAxis, YAxis, ResponsiveContainer, Tooltip } from 'recharts'
import { formatCurrency, formatDateShort } from '../../utils/formatters'
import { CATEGORIES, ACCOUNT_TYPES } from '../../utils/categories'

const PERIODS = [
  { key: 'week',    label: 'Week' },
  { key: 'month',   label: 'Month' },
  { key: 'quarter', label: 'Quarter' },
  { key: 'year',    label: 'Year' },
  { key: 'all',     label: 'All' },
]

export default function DashboardView({ finance, onOpenSettings, onAddTx }) {
  const { totalIncome, totalExpenses, cashFlow,
          accounts, recentTransactions, monthlyTrend, selectedPeriod, setSelectedPeriod } = finance

  return (
    <div className="page">
      {/* Header */}
      <div className="nav-header">
        <h1 className="nav-title">Overview</h1>
        <div className="nav-actions">
          <button className="icon-btn" onClick={onOpenSettings} aria-label="Settings">⚙️</button>
          <button className="icon-btn icon-btn-primary" onClick={onAddTx} aria-label="Add transaction">＋</button>
        </div>
      </div>

      {/* Period selector */}
      <div className="period-scroll" style={{ marginBottom: 16 }}>
        <div className="period-chips">
          {PERIODS.map(p => (
            <button
              key={p.key}
              className={`period-chip${selectedPeriod === p.key ? ' active' : ''}`}
              onClick={() => setSelectedPeriod(p.key)}
            >{p.label}</button>
          ))}
        </div>
      </div>

      <div className="page-content">
        {/* Income / Expenses row */}
        <div style={{ display: 'flex', gap: 12 }}>
          <div className="card cf-card">
            <div className="cf-label">↓ Income</div>
            <div className="cf-amount green">{formatCurrency(totalIncome)}</div>
          </div>
          <div className="card cf-card">
            <div className="cf-label">↑ Expenses</div>
            <div className="cf-amount red">{formatCurrency(totalExpenses)}</div>
          </div>
        </div>

        {/* Cash flow chart */}
        <div className="card chart-card">
          <div className="chart-card-title">
            <span>Cash Flow</span>
            <div style={{ display: 'flex', gap: 12 }}>
              <span style={{ fontSize: 11, color: '#26BF8C', fontWeight: 600 }}>▮ Income</span>
              <span style={{ fontSize: 11, color: '#FF5959', fontWeight: 600 }}>▮ Expenses</span>
            </div>
          </div>
          <ResponsiveContainer width="100%" height={160}>
            <BarChart data={monthlyTrend} barGap={2} barSize={10}>
              <XAxis dataKey="month" tick={{ fontSize: 11 }} axisLine={false} tickLine={false} />
              <YAxis hide />
              <Tooltip
                formatter={(v, name) => [formatCurrency(v), name]}
                contentStyle={{ borderRadius: 10, border: 'none', boxShadow: '0 4px 12px rgba(0,0,0,0.12)', fontSize: 12 }}
              />
              <Bar dataKey="income"   name="Income"   fill="#26BF8C" radius={[4,4,0,0]} />
              <Bar dataKey="expenses" name="Expenses" fill="#FF5959" radius={[4,4,0,0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Accounts */}
        <div className="card card-pad">
          <div className="section-header">
            <span className="section-title">Accounts</span>
          </div>
          {accounts.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '16px 0', color: 'var(--text2)', fontSize: 14 }}>No accounts yet</div>
          ) : (
            accounts.slice(0, 4).map((acc, i) => (
              <div key={acc.id}>
                <AccountRowMini account={acc} />
                {i < Math.min(accounts.length, 4) - 1 && <div className="divider" />}
              </div>
            ))
          )}
        </div>

        {/* Recent Transactions */}
        <div className="card card-pad">
          <div className="section-header">
            <span className="section-title">Recent Transactions</span>
          </div>
          {recentTransactions.length === 0 ? (
            <div className="empty-state">
              <div className="icon">🧾</div>
              <h3>No transactions yet</h3>
              <p>Tap + to add your first one</p>
            </div>
          ) : (
            recentTransactions.map((tx, i) => (
              <div key={tx.id}>
                <TxRow tx={tx} />
                {i < recentTransactions.length - 1 && <div className="divider" />}
              </div>
            ))
          )}
        </div>
      </div>
      <div style={{ height: 8 }} />
    </div>
  )
}

function AccountRowMini({ account }) {
  const type = ACCOUNT_TYPES[account.type] || ACCOUNT_TYPES.other
  return (
    <div className="acc-row">
      <div className="acc-icon" style={{ background: type.color + '22' }}>
        <span>{type.emoji}</span>
      </div>
      <div className="acc-info">
        <div className="acc-name">{account.name}</div>
        <div className="acc-type">{type.label}</div>
      </div>
    </div>
  )
}

function TxRow({ tx }) {
  const cat = CATEGORIES[tx.category] || CATEGORIES.other
  return (
    <div className="tx-row">
      <div className="tx-icon" style={{ background: cat.color + '22' }}>{cat.emoji}</div>
      <div className="tx-info">
        <div className="tx-desc">{tx.description || cat.label}</div>
        <div className="tx-meta">{cat.label}</div>
      </div>
      <div>
        <div className={`tx-amount ${tx.type}`}>
          {tx.type === 'income' ? '+' : '-'}{formatCurrency(tx.amount)}
        </div>
        <div className="tx-date">{formatDateShort(tx.date)}</div>
      </div>
    </div>
  )
}
