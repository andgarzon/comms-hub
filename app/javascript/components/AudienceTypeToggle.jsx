import React, { useEffect } from "react"

export default function AudienceTypeToggle({ dynamicSectionSelector = ".dynamic-only" }) {
  useEffect(() => {
    const staticRadio = document.querySelector('input[value="StaticAudience"]')
    const dynamicRadio = document.querySelector('input[value="DynamicAudience"]')
    const dynamicSection = document.querySelector(dynamicSectionSelector)

    function updateVisibility() {
      if (dynamicSection) {
        dynamicSection.style.display =
          dynamicRadio && dynamicRadio.checked ? "block" : "none"
      }
    }

    updateVisibility()

    if (staticRadio) staticRadio.addEventListener("change", updateVisibility)
    if (dynamicRadio) dynamicRadio.addEventListener("change", updateVisibility)

    return () => {
      if (staticRadio) staticRadio.removeEventListener("change", updateVisibility)
      if (dynamicRadio) dynamicRadio.removeEventListener("change", updateVisibility)
    }
  }, [dynamicSectionSelector])

  return null
}
