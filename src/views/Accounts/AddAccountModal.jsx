import { useState } from 'react'
import { generateId } from '../../utils/formatters'
import { ACCOUNT_TYPES } from '../../utils/categories'

export default function AddAccountModal({ finance, onClose, editAccount = null }) {
  const isEdit = !!editAccount
  const [name,  setName]  = useState(editAccount?.name || '')
  const [type,  setType]  = useState(editAccount?.type || 'checking')
  const [notes, setNotes] = useState(editAccount?.notes || '')

  function handleSubmit(e) {
    e.preventDefault()
    const account = {
      id:        isEdit ? editAccount.id : generateId(),
      name:      name.trim(),
      type,
      notes:     notes.trim(),
      createdAt: isEdit ? editAccount.createdAt : new Date().toISOString(),
    }
    if (isEdit) finance.updateAccount(account)
    else        finance.addAccount(account)
    onClose()
  }

  return (
    <div className="modal-overlay" onClick={e => e.target === e.currentTarget && onClose()}>
      <div className="modal-sheet">
        <div className="modal-handle" />
        <div className="modal-header">
          <span className="modal-title">{isEdit ? 'Edit Account' : 'Add Account'}</span>
          <button className="modal-close" onClick={onClose}>✕</button>
        </div>
        <div className="modal-body">
          <form onSubmit={handleSubmit}>

            <div className="form-group">
              <label className="form-label">Account Name</label>
              <input
                className="form-input"
                type="text"
                placeholder="e.g. Chase Checking"
                value={name}
                onChange={e => setName(e.target.value)}
                required
                autoFocus
              />
            </div>

            <div className="form-group">
              <label className="form-label">Account Type</label>
              <select className="form-select" value={type} onChange={e => setType(e.target.value)}>
                {Object.entries(ACCOUNT_TYPES).map(([k, v]) => (
                  <option key={k} value={k}>{v.emoji} {v.label}</option>
                ))}
              </select>
            </div>

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
              {isEdit ? 'Save Changes' : 'Add Account'}
            </button>
          </form>
        </div>
      </div>
    </div>
  )
}
