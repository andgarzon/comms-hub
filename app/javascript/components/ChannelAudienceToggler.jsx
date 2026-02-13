import React, { useEffect } from "react"

export default function ChannelAudienceToggler({ channels }) {
  // channels = [{ name: "email", checkboxSelector: "...", sectionId: "email-audiences-section" }, ...]

  useEffect(() => {
    function toggleAudiences() {
      channels.forEach(({ name, sectionId }) => {
        const checkbox = document.querySelector(
          `input[type="checkbox"][data-channel="${name}"]`
        )
        const section = document.getElementById(sectionId)
        if (checkbox && section) {
          section.style.display = checkbox.checked ? "block" : "none"
        }
      })
    }

    // Run on mount
    toggleAudiences()

    // Listen for changes
    const listeners = []
    channels.forEach(({ name }) => {
      const checkbox = document.querySelector(
        `input[type="checkbox"][data-channel="${name}"]`
      )
      if (checkbox) {
        checkbox.addEventListener("change", toggleAudiences)
        listeners.push({ checkbox, handler: toggleAudiences })
      }
    })

    return () => {
      listeners.forEach(({ checkbox, handler }) => {
        checkbox.removeEventListener("change", handler)
      })
    }
  }, [channels])

  // This component doesn't render visible UI — it only manages side effects
  return null
}
