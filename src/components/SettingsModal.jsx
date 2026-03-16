import { useRef } from 'react'

export default function SettingsModal({ finance, onClose }) {
  const fileInputRef = useRef(null)

  function handleImport(e) {
    const file = e.target.files[0]
    if (!file) return
    finance.importBackup(file)
      .then(() => { onClose() })
      .catch(err => alert('Import failed: ' + err.message))
    e.target.value = ''
  }

  return (
    <div className="modal-overlay" onClick={e => e.target === e.currentTarget && onClose()}>
      <div className="modal-sheet">
        <div className="modal-handle" />
        <div className="modal-header">
          <span className="modal-title">Settings</span>
          <button className="modal-close" onClick={onClose}>✕</button>
        </div>
        <div className="modal-body">

          {/* Privacy */}
          <div className="settings-section">
            <div className="settings-section-title">Privacy</div>
            <div className="settings-card">
              <div className="settings-row">
                <div className="settings-row-icon" style={{ background: '#FFF3E0' }}>🙈</div>
                <div className="settings-row-text">
                  <div className="settings-row-title">Demo Mode</div>
                  <div className="settings-row-sub">Show sample data, hide real finances</div>
                </div>
                <div className="settings-row-action">
                  <label className="toggle">
                    <input
                      type="checkbox"
                      checked={finance.isDemoMode}
                      onChange={e => finance.setDemoMode(e.target.checked)}
                    />
                    <span className="toggle-track" />
                  </label>
                </div>
              </div>
            </div>
          </div>

          {/* Backup */}
          <div className="settings-section">
            <div className="settings-section-title">Backup</div>
            <div className="settings-card">
              <button className="settings-row" style={{ width: '100%', textAlign: 'left', cursor: 'pointer', background: 'none', border: 'none' }} onClick={finance.exportBackup}>
                <div className="settings-row-icon" style={{ background: '#E8F0FF' }}>⬆️</div>
                <div className="settings-row-text">
                  <div className="settings-row-title">Export Data</div>
                  <div className="settings-row-sub">Download a JSON backup file</div>
                </div>
                <span style={{ color: '#C7C7CC', fontSize: 18 }}>›</span>
              </button>
              <button className="settings-row" style={{ width: '100%', textAlign: 'left', cursor: 'pointer', background: 'none', border: 'none' }} onClick={() => fileInputRef.current.click()}>
                <div className="settings-row-icon" style={{ background: '#E8F8F2' }}>⬇️</div>
                <div className="settings-row-text">
                  <div className="settings-row-title">Import Backup</div>
                  <div className="settings-row-sub">Restore from a JSON backup file</div>
                </div>
                <span style={{ color: '#C7C7CC', fontSize: 18 }}>›</span>
              </button>
            </div>
            <input
              ref={fileInputRef}
              type="file"
              accept=".json,application/json"
              style={{ display: 'none' }}
              onChange={handleImport}
            />
          </div>

          {/* About */}
          <div className="settings-section">
            <div className="settings-section-title">About</div>
            <div className="settings-card">
              <div className="settings-row">
                <div className="settings-row-icon" style={{ background: '#F2F2F7' }}>💰</div>
                <div className="settings-row-text">
                  <div className="settings-row-title">Personal Finance Tracker</div>
                  <div className="settings-row-sub">Free · Open source · No account required</div>
                </div>
              </div>
            </div>
          </div>

        </div>
      </div>
    </div>
  )
}
