import React, { useEffect } from "react"

/**
 * AudienceScopeToggle
 *
 * Shows/hides the role dropdown based on the scope_type selection.
 * When scope_type is "role", the role field is shown; otherwise hidden.
 *
 * Props:
 *   scopeSelector     - CSS selector for the scope_type <select> (e.g. "#audience_scope_type")
 *   roleFieldSelector - CSS selector for the role field wrapper (e.g. "#role-scope-field")
 */
export default function AudienceScopeToggle({ scopeSelector, roleFieldSelector }) {
  useEffect(() => {
    const scopeSelect = document.querySelector(scopeSelector)
    const roleField = document.querySelector(roleFieldSelector)

    if (!scopeSelect || !roleField) return

    const toggle = () => {
      if (scopeSelect.value === "role") {
        roleField.style.display = ""
      } else {
        roleField.style.display = "none"
      }
    }

    // Set initial state
    toggle()

    // Listen for changes
    scopeSelect.addEventListener("change", toggle)

    return () => {
      scopeSelect.removeEventListener("change", toggle)
    }
  }, [scopeSelector, roleFieldSelector])

  return null
}
