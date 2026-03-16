export default function DemoBanner({ onExit }) {
  return (
    <div className="demo-banner">
      <span>👁️</span>
      <span className="demo-banner-text">Demo Mode — your real data is hidden</span>
      <button className="demo-banner-exit" onClick={onExit}>Exit</button>
    </div>
  )
}
