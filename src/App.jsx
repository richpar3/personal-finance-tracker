import { useState } from 'react'
import './App.css'
import useFinance from './hooks/useFinance'
import TabBar from './components/TabBar'
import DemoBanner from './components/DemoBanner'
import DashboardView from './views/Dashboard/DashboardView'
import TransactionListView from './views/Transactions/TransactionListView'
import AnalyticsView from './views/Analytics/AnalyticsView'
import AccountsView from './views/Accounts/AccountsView'
import SettingsModal from './components/SettingsModal'
import AddTransactionModal from './views/Transactions/AddTransactionModal'

export default function App() {
  const [activeTab, setActiveTab]       = useState(0)
  const [showSettings, setShowSettings] = useState(false)
  const [showAdd, setShowAdd]           = useState(false)
  const finance = useFinance()

  return (
    <div className="app">
      {finance.isDemoMode && (
        <DemoBanner onExit={() => finance.setDemoMode(false)} />
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
