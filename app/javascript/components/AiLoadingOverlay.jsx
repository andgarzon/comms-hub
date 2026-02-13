import React from "react"

export default function AiLoadingOverlay() {
  // This component is always rendered hidden; shown via JS when AI Improve triggers form submit
  return (
    <div id="ai-loading-overlay" className="ai-overlay">
      <div className="ai-overlay__card">
        <div className="ai-overlay__spinner"></div>
        <p className="ai-overlay__title">{"\u2728"} AI is improving your announcement...</p>
        <p className="ai-overlay__subtitle">This may take a few seconds</p>
      </div>
    </div>
  )
}
