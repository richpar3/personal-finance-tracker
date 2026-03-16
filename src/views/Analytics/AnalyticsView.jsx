import { useState } from 'react'
import {
  BarChart, Bar, AreaChart, Area,
  PieChart, Pie, Cell,
  XAxis, YAxis, Tooltip,
  ResponsiveContainer, Legend,
} from 'recharts'
import { formatCurrency } from '../../utils/formatters'
import { CATEGORIES } from '../../utils/categories'

const PERIODS = [
  { key: 'week', label: 'Week' }, { key: 'month', label: 'Month' },
  { key: 'quarter', label: 'Quarter' }, { key: 'year', label: 'Year' }, { key: 'all', label: 'All' },
]

export default function AnalyticsView({ finance }) {
  const { selectedPeriod, setSelectedPeriod, totalIncome, totalExpenses, cashFlow, savingsRate,
          expensesByCategory, monthlyTrend, dailySpending } = finance

  return (
    <div className="page">
      <div className="nav-header">
        <h1 className="nav-title">Analytics</h1>
      </div>

      <div className="period-scroll" style={{ marginBottom: 16 }}>
        <div className="period-chips">
          {PERIODS.map(p => (
            <button key={p.key} className={`period-chip${selectedPeriod === p.key ? ' active' : ''}`} onClick={() => setSelectedPeriod(p.key)}>{p.label}</button>
          ))}
        </div>
      </div>

      <div className="page-content">
        {/* Summary */}
        <div style={{ display: 'flex', gap: 12 }}>
          <div className="stat-pill">
            <span className="stat-pill-icon">{cashFlow >= 0 ? '📈' : '📉'}</span>
            <div>
              <div className="stat-pill-label">Cash Flow</div>
              <div className="stat-pill-value" style={{ color: cashFlow >= 0 ? 'var(--green)' : 'var(--red)' }}>
                {cashFlow >= 0 ? '+' : ''}{formatCurrency(cashFlow)}
              </div>
            </div>
          </div>
          <div className="stat-pill">
            <span className="stat-pill-icon">💰</span>
            <div>
              <div className="stat-pill-label">Savings Rate</div>
              <div className="stat-pill-value" style={{ color: savingsRate >= 0 ? 'var(--green)' : 'var(--red)' }}>
                {savingsRate.toFixed(1)}%
              </div>
            </div>
          </div>
        </div>

        {/* Monthly income vs expenses */}
        <div className="card chart-card">
          <div className="chart-card-title">Income vs Expenses (6 months)</div>
          <ResponsiveContainer width="100%" height={180}>
            <BarChart data={monthlyTrend} barGap={2} barSize={12}>
              <XAxis dataKey="month" tick={{ fontSize: 11 }} axisLine={false} tickLine={false} />
              <YAxis hide />
              <Tooltip
                formatter={(v, name) => [formatCurrency(v), name]}
                contentStyle={{ borderRadius: 10, border: 'none', boxShadow: '0 4px 12px rgba(0,0,0,0.12)', fontSize: 12 }}
              />
              <Bar dataKey="income"   name="Income"   fill="#26BF8C" radius={[4,4,0,0]} />
              <Bar dataKey="expenses" name="Expenses" fill="#FF5959" radius={[4,4,0,0]} />
              <Legend iconType="circle" iconSize={8} wrapperStyle={{ fontSize: 12 }} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Daily spending */}
        <div className="card chart-card">
          <div className="chart-card-title">Daily Spending (30 days)</div>
          {dailySpending.every(d => d.amount === 0) ? (
            <div style={{ textAlign: 'center', padding: '24px 0', color: 'var(--text2)', fontSize: 14 }}>No spending data</div>
          ) : (
            <ResponsiveContainer width="100%" height={140}>
              <AreaChart data={dailySpending}>
                <defs>
                  <linearGradient id="spendGrad" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="#FF5959" stopOpacity={0.3} />
                    <stop offset="100%" stopColor="#FF5959" stopOpacity={0.02} />
                  </linearGradient>
                </defs>
                <XAxis dataKey="day" tick={{ fontSize: 10 }} axisLine={false} tickLine={false} interval={6} />
                <YAxis hide />
                <Tooltip
                  formatter={(v) => [formatCurrency(v), 'Spent']}
                  contentStyle={{ borderRadius: 10, border: 'none', boxShadow: '0 4px 12px rgba(0,0,0,0.12)', fontSize: 12 }}
                />
                <Area type="monotone" dataKey="amount" stroke="#FF5959" strokeWidth={2} fill="url(#spendGrad)" />
              </AreaChart>
            </ResponsiveContainer>
          )}
        </div>

        {/* Category breakdown */}
        {expensesByCategory.length > 0 && (
          <>
            <CategoryDonut data={expensesByCategory} />
            <div className="card card-pad">
              <div className="section-title" style={{ marginBottom: 12 }}>Spending Breakdown</div>
              {expensesByCategory.map(item => {
                const cat = CATEGORIES[item.category] || CATEGORIES.other
                return (
                  <div key={item.category} style={{ marginBottom: 12 }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 6 }}>
                      <div style={{ width: 32, height: 32, borderRadius: 8, background: cat.color + '22', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 15, flexShrink: 0 }}>
                        {cat.emoji}
                      </div>
                      <div style={{ flex: 1 }}>
                        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 4 }}>
                          <span style={{ fontSize: 14, fontWeight: 500 }}>{cat.label}</span>
                          <span style={{ fontSize: 14, fontWeight: 600 }}>{formatCurrency(item.amount)}</span>
                        </div>
                        <div className="progress-bar">
                          <div className="progress-fill" style={{ width: `${item.percentage}%`, background: cat.color }} />
                        </div>
                      </div>
                      <span style={{ fontSize: 12, color: 'var(--text2)', width: 36, textAlign: 'right' }}>{item.percentage.toFixed(0)}%</span>
                    </div>
                  </div>
                )
              })}
            </div>
          </>
        )}

        {expensesByCategory.length === 0 && (
          <div className="card">
            <div className="empty-state">
              <div className="icon">📊</div>
              <h3>No expense data</h3>
              <p>Add some expenses to see analytics</p>
            </div>
          </div>
        )}
      </div>
      <div style={{ height: 8 }} />
    </div>
  )
}

function CategoryDonut({ data }) {
  const [active, setActive] = useState(null)
  const top6 = data.slice(0, 6)
  const RADIAN = Math.PI / 180

  const renderLabel = ({ cx, cy, midAngle, innerRadius, outerRadius, percent }) => {
    if (percent < 0.06) return null
    const r = innerRadius + (outerRadius - innerRadius) * 0.55
    return (
      <text x={cx + r * Math.cos(-midAngle * RADIAN)} y={cy + r * Math.sin(-midAngle * RADIAN)}
        fill="white" textAnchor="middle" dominantBaseline="central" fontSize={11} fontWeight={600}>
        {(percent * 100).toFixed(0)}%
      </text>
    )
  }

  return (
    <div className="card chart-card">
      <div className="chart-card-title">Spending by Category</div>
      <ResponsiveContainer width="100%" height={200}>
        <PieChart>
          <Pie
            data={top6}
            dataKey="amount"
            nameKey="category"
            cx="50%"
            cy="50%"
            innerRadius={55}
            outerRadius={85}
            paddingAngle={2}
            labelLine={false}
            label={renderLabel}
            onMouseEnter={(_, idx) => setActive(idx)}
            onMouseLeave={() => setActive(null)}
          >
            {top6.map((item, i) => {
              const cat = CATEGORIES[item.category] || CATEGORIES.other
              return (
                <Cell
                  key={item.category}
                  fill={cat.color}
                  opacity={active === null || active === i ? 1 : 0.5}
                />
              )
            })}
          </Pie>
          <Tooltip
            formatter={(v, name) => [formatCurrency(v), (CATEGORIES[name] || CATEGORIES.other).label]}
            contentStyle={{ borderRadius: 10, border: 'none', boxShadow: '0 4px 12px rgba(0,0,0,0.12)', fontSize: 12 }}
          />
        </PieChart>
      </ResponsiveContainer>
      {/* Legend */}
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: '6px 14px', marginTop: 4 }}>
        {top6.map(item => {
          const cat = CATEGORIES[item.category] || CATEGORIES.other
          return (
            <div key={item.category} style={{ display: 'flex', alignItems: 'center', gap: 5, fontSize: 12 }}>
              <div style={{ width: 10, height: 10, borderRadius: 2, background: cat.color, flexShrink: 0 }} />
              <span style={{ color: 'var(--text2)' }}>{cat.label}</span>
            </div>
          )
        })}
      </div>
    </div>
  )
}
