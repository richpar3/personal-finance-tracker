import { useState } from 'react'
import './App.css'
import useFinance from './hooks/useFinance'
import TabBar from './components/TabBar'
import DashboardView from './views/Dashboard/DashboardView'
import TransactionListView from './views/Transactions/TransactionListView'
import AnalyticsView from './views/Analytics/AnalyticsView'
import AccountsView from './views/Accounts/AccountsView'
import SettingsModal from './components/SettingsModal'
import AddTransactionModal from './views/Transactions/AddTransactionModal'
import LoginView from './views/Auth/LoginView'
import DemoBanner from './components/DemoBanner'

export default function App() {
  const [activeTab, setActiveTab]       = useState(0)
  const [showSettings, setShowSettings] = useState(false)
  const [showAdd, setShowAdd]           = useState(false)
  const finance = useFinance()

  if (finance.authLoading) {
    return (
      <div style={{ minHeight: '100dvh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: '#1C1C1E' }}>
        <span style={{ color: '#8E8E93', fontSize: 16 }}>Loading…</span>
      </div>
    )
  }

  if (!finance.user && !finance.isDemo) {
    return <LoginView onDemo={finance.enterDemoMode} />
  }

  return (
    <div className="app">
      {finance.isDemo && <DemoBanner onExit={finance.exitDemoMode} />}
      {finance.syncError && (
        <div style={{ background: '#FF3B30', color: '#fff', fontSize: 13, padding: '8px 16px', textAlign: 'center' }}>
          Sync error: {finance.syncError}
        </div>
      )}
      <main className="main-content">
        {activeTab === 0 && <DashboardView finance={finance} onOpenSettings={() => setShowSettings(true)} onAddTx={() => setShowAdd(true)} />}
        {activeTab === 1 && <TransactionListView finance={finance} onAddTx={() => setShowAdd(true)} />}
        {activeTab === 2 && <AnalyticsView finance={finance} />}
        {activeTab === 3 && <AccountsView finance={finance} />}
      </main>

      <TabBar activeTab={activeTab} onTabChange={setActiveTab} onAdd={() => setShowAdd(true)} />

      {showSettings && <SettingsModal finance={finance} onClose={() => setShowSettings(false)} />}
      {showAdd && <AddTransactionModal finance={finance} onClose={() => setShowAdd(false)} />}
    </div>
  )
}
