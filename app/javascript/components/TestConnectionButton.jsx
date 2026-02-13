import React, { useState } from "react"

export default function TestConnectionButton({ testUrl, csrfToken, successColor = "#25D366" }) {
  const [testing, setTesting] = useState(false)
  const [result, setResult] = useState(null)

  async function handleTest() {
    setTesting(true)
    setResult(null)

    try {
      const response = await fetch(testUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
        },
      })
      const data = await response.json()

      if (data.success) {
        let message = data.message
        if (data.phone_display) message += ` (${data.phone_display})`
        if (data.workspace) message += ` — Workspace: ${data.workspace}`
        setResult({ success: true, message })
      } else {
        setResult({ success: false, message: data.message })
      }
    } catch {
      setResult({ success: false, message: "Network error. Please try again." })
    } finally {
      setTesting(false)
    }
  }

  return (
    <span className="test-connection-wrapper">
      <button
        type="button"
        className="btn btn-secondary"
        onClick={handleTest}
        disabled={testing}
      >
        {testing ? "Testing..." : "Test Connection"}
      </button>

      {result && (
        <span
          className="test-connection-result"
          style={{ color: result.success ? successColor : "#dc3545" }}
        >
          <strong>{result.success ? "\u2713" : "\u2717"}</strong>{" "}
          {result.message}
        </span>
      )}
    </span>
  )
}
