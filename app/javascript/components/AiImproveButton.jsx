import React, { useState } from "react"

export default function AiImproveButton({
  mode = "submit",
  submitName = "improve_with_ai",
  endpoint,
  textareaId = "message-textarea",
  csrfToken,
  formId = "announcement-form",
}) {
  const [loading, setLoading] = useState(false)
  const [feedback, setFeedback] = useState(null)

  async function handleClick() {
    if (mode === "submit") {
      // Submit mode: show overlay and submit the form
      const overlay = document.getElementById("ai-loading-overlay")
      if (overlay) overlay.style.display = "flex"

      const form = document.getElementById(formId)
      if (form) {
        // Add hidden input for improve_with_ai flag
        let hidden = form.querySelector(`input[name="${submitName}"]`)
        if (!hidden) {
          hidden = document.createElement("input")
          hidden.type = "hidden"
          hidden.name = submitName
          hidden.value = "1"
          form.appendChild(hidden)
        }
        form.submit()
      }
      return
    }

    // Async mode: fetch and update textarea
    const textarea = document.getElementById(textareaId)
    if (!textarea) return

    const message = textarea.value.trim()
    if (!message) {
      alert("Please enter a message first.")
      return
    }

    setLoading(true)
    setFeedback(null)

    try {
      const response = await fetch(endpoint, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
        },
        body: JSON.stringify({ message }),
      })

      if (response.ok) {
        const data = await response.json()
        textarea.value = data.improved_message || data.message
        setFeedback({ success: true, message: "Message improved!" })
        setTimeout(() => setFeedback(null), 2000)
      } else {
        throw new Error("AI improvement failed")
      }
    } catch {
      setFeedback({
        success: false,
        message: "Could not improve message. Please try again.",
      })
      setTimeout(() => setFeedback(null), 3000)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="ai-improve-wrapper">
      <button
        type="button"
        className="btn btn-secondary btn--sm"
        onClick={handleClick}
        disabled={loading}
      >
        {loading ? "\u23F3 Improving..." : "\u2728 AI Improve"}
      </button>

      {feedback && (
        <div
          className={`ai-improve-feedback ${
            feedback.success
              ? "ai-improve-feedback--success"
              : "ai-improve-feedback--error"
          }`}
        >
          <span className="ai-improve-feedback__icon">
            {feedback.success ? "\u2713" : "\u2717"}
          </span>
          <span>{feedback.message}</span>
        </div>
      )}
    </div>
  )
}
