import React, { useEffect } from "react"

export default function ChannelTypeToggle({ slackSelector, emailSelector, whatsappSelector }) {
  useEffect(() => {
    const radios = document.querySelectorAll('input[name="audience[type]"]')
    const slackSection = document.querySelector(slackSelector)
    const emailSection = document.querySelector(emailSelector)
    const whatsappSection = document.querySelector(whatsappSelector)

    function updateVisibility() {
      const selected = document.querySelector('input[name="audience[type]"]:checked')
      const value = selected ? selected.value : ''

      if (slackSection) {
        slackSection.classList.toggle("hidden", value !== "SlackAudience")
      }
      if (emailSection) {
        emailSection.classList.toggle("hidden", value !== "EmailAudience")
      }
      if (whatsappSection) {
        whatsappSection.classList.toggle("hidden", value !== "WhatsappAudience")
      }
    }

    updateVisibility()

    radios.forEach((radio) => {
      radio.addEventListener("change", updateVisibility)
    })

    return () => {
      radios.forEach((radio) => {
        radio.removeEventListener("change", updateVisibility)
      })
    }
  }, [slackSelector, emailSelector, whatsappSelector])

  return null
}
