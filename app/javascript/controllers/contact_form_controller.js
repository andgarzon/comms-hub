import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["personFields", "slackChannelFields", "organizationFields", "nameInput"]

  connect() {
    this.toggle()
  }

  toggle() {
    const isSlackChannel = this.element.querySelector("[data-contact-type-field]").value === "slack_channel"

    this.personFieldsTarget.classList.toggle("hidden", isSlackChannel)
    this.slackChannelFieldsTarget.classList.toggle("hidden", !isSlackChannel)
    this.organizationFieldsTarget.classList.toggle("hidden", isSlackChannel)

    if (isSlackChannel) {
      this.nameInputTarget.placeholder = "e.g., Engineering Updates"
    } else {
      this.nameInputTarget.placeholder = "Full name"
    }
  }
}
