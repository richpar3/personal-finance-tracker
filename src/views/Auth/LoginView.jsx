import { useState } from 'react'
import { supabase } from '../../lib/supabase'

export default function LoginView({ onDemo }) {
  const [mode, setMode]       = useState('login') // 'login' | 'signup'
  const [email, setEmail]     = useState('')
  const [password, setPassword] = useState('')
  const [error, setError]     = useState(null)
  const [loading, setLoading] = useState(false)
  const [message, setMessage] = useState(null)

  async function handleSubmit(e) {
    e.preventDefault()
    setError(null)
    setMessage(null)
    setLoading(true)
    try {
      if (mode === 'login') {
        const { error } = await supabase.auth.signInWithPassword({ email, password })
        if (error) throw error
      } else {
        const { error } = await supabase.auth.signUp({ email, password })
        if (error) throw error
        setMessage('Check your email to confirm your account, then sign in.')
        setMode('login')
      }
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div style={styles.container}>
      <div style={styles.card}>
        <div style={styles.icon}>💰</div>
        <h1 style={styles.title}>Personal Finance</h1>
        <p style={styles.subtitle}>Track your money across all accounts</p>

        <div style={styles.tabs}>
          <button style={{ ...styles.tab, ...(mode === 'login' ? styles.tabActive : {}) }} onClick={() => { setMode('login'); setError(null); setMessage(null) }}>Sign In</button>
          <button style={{ ...styles.tab, ...(mode === 'signup' ? styles.tabActive : {}) }} onClick={() => { setMode('signup'); setError(null); setMessage(null) }}>Sign Up</button>
        </div>

        <form onSubmit={handleSubmit} style={styles.form}>
          <input
            style={styles.input}
            type="email"
            placeholder="Email"
            value={email}
            onChange={e => setEmail(e.target.value)}
            required
            autoComplete="email"
          />
          <input
            style={styles.input}
            type="password"
            placeholder="Password"
            value={password}
            onChange={e => setPassword(e.target.value)}
            required
            autoComplete={mode === 'login' ? 'current-password' : 'new-password'}
            minLength={6}
          />
          {error   && <p style={styles.error}>{error}</p>}
          {message && <p style={styles.success}>{message}</p>}
          <button style={{ ...styles.button, opacity: loading ? 0.7 : 1 }} type="submit" disabled={loading}>
            {loading ? 'Please wait…' : mode === 'login' ? 'Sign In' : 'Create Account'}
          </button>
        </form>
        <button style={styles.demoButton} onClick={onDemo}>Try Demo</button>
      </div>
    </div>
  )
}

const styles = {
  container: {
    minHeight: '100dvh',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    background: 'linear-gradient(135deg, #1C1C1E 0%, #2C2C2E 100%)',
    padding: '20px',
  },
  card: {
    background: '#2C2C2E',
    borderRadius: 24,
    padding: '40px 32px',
    width: '100%',
    maxWidth: 380,
    textAlign: 'center',
    boxShadow: '0 20px 60px rgba(0,0,0,0.4)',
  },
  icon: { fontSize: 48, marginBottom: 12 },
  title: { color: '#fff', fontSize: 26, fontWeight: 700, margin: '0 0 6px' },
  subtitle: { color: '#8E8E93', fontSize: 14, margin: '0 0 28px' },
  tabs: {
    display: 'flex',
    background: '#1C1C1E',
    borderRadius: 12,
    padding: 4,
    marginBottom: 24,
  },
  tab: {
    flex: 1,
    padding: '8px 0',
    border: 'none',
    borderRadius: 9,
    background: 'transparent',
    color: '#8E8E93',
    fontSize: 14,
    fontWeight: 600,
    cursor: 'pointer',
    transition: 'all 0.2s',
  },
  tabActive: {
    background: '#3A3A3C',
    color: '#fff',
  },
  form: { display: 'flex', flexDirection: 'column', gap: 12 },
  input: {
    padding: '14px 16px',
    borderRadius: 12,
    border: '1px solid #3A3A3C',
    background: '#1C1C1E',
    color: '#fff',
    fontSize: 16,
    outline: 'none',
  },
  button: {
    padding: '14px',
    borderRadius: 12,
    border: 'none',
    background: '#007AFF',
    color: '#fff',
    fontSize: 16,
    fontWeight: 600,
    cursor: 'pointer',
    marginTop: 4,
  },
  error:   { color: '#FF453A', fontSize: 13, margin: 0, textAlign: 'left' },
  success: { color: '#30D158', fontSize: 13, margin: 0, textAlign: 'left' },
  demoButton: {
    marginTop: 16,
    width: '100%',
    padding: '12px',
    borderRadius: 12,
    border: '1px solid #3A3A3C',
    background: 'transparent',
    color: '#8E8E93',
    fontSize: 15,
    fontWeight: 500,
    cursor: 'pointer',
  },
}
