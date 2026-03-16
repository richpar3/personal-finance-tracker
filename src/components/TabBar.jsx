const TABS = [
  { icon: '⊞',  label: 'Overview',     emoji: true },
  { icon: '☰',  label: 'Transactions', emoji: true },
  { icon: null, label: '',             fab: true },
  { icon: '📊', label: 'Analytics',    emoji: true },
  { icon: '💳', label: 'Accounts',     emoji: true },
]

// Use SVG icons so they render consistently
function Icon({ name }) {
  switch (name) {
    case 'home':   return <svg viewBox="0 0 24 24" fill="currentColor" width="22" height="22"><path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/></svg>
    case 'list':   return <svg viewBox="0 0 24 24" fill="currentColor" width="22" height="22"><path d="M3 13h2v-2H3v2zm0 4h2v-2H3v2zm0-8h2V7H3v2zm4 4h14v-2H7v2zm0 4h14v-2H7v2zM7 7v2h14V7H7z"/></svg>
    case 'chart':  return <svg viewBox="0 0 24 24" fill="currentColor" width="22" height="22"><path d="M5 9.2h3V19H5V9.2zM10.6 5h2.8v14h-2.8V5zM16.2 13h2.8v6h-2.8v-6z"/></svg>
    case 'card':   return <svg viewBox="0 0 24 24" fill="currentColor" width="22" height="22"><path d="M20 4H4c-1.11 0-2 .89-2 2v12c0 1.11.89 2 2 2h16c1.11 0 2-.89 2-2V6c0-1.11-.89-2-2-2zm0 14H4v-6h16v6zm0-10H4V6h16v2z"/></svg>
    case 'plus':   return <svg viewBox="0 0 24 24" fill="currentColor" width="26" height="26"><path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/></svg>
    default: return null
  }
}

const TAB_ICONS = ['home', 'list', null, 'chart', 'card']

export default function TabBar({ activeTab, onTabChange, onAdd }) {
  // Map tab indices to actual indices (skipping fab slot at index 2)
  // Displayed: [0:Overview, 1:Transactions, 2:FAB, 3:Analytics, 4:Accounts]
  // activeTab: 0=Overview, 1=Transactions, 2=Analytics, 3=Accounts
  const displayActiveTab = activeTab >= 2 ? activeTab + 1 : activeTab

  function handleSlot(slot) {
    if (slot === 2) { onAdd(); return }
    const tab = slot >= 3 ? slot - 1 : slot
    onTabChange(tab)
  }

  return (
    <nav className="tab-bar">
      {[0, 1, 2, 3, 4].map(slot => {
        if (slot === 2) {
          return (
            <button key="fab" className="tab-fab" onClick={onAdd} aria-label="Add transaction">
              <Icon name="plus" />
            </button>
          )
        }
        const isActive = slot === displayActiveTab
        return (
          <button
            key={slot}
            className={`tab-btn${isActive ? ' active' : ''}`}
            onClick={() => handleSlot(slot)}
          >
            <Icon name={TAB_ICONS[slot]} />
            <span>{['Overview','Transactions',null,'Analytics','Accounts'][slot]}</span>
          </button>
        )
      })}
    </nav>
  )
}
