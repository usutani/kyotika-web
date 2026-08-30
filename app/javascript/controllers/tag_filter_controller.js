import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "list"]

  filter() {
    const query = this.inputTarget.value.toLowerCase()
    const labels = this.listTarget.querySelectorAll("label")

    labels.forEach(label => {
      const text = label.textContent.toLowerCase()
      label.style.display = text.includes(query) ? "" : "none"
    })
  }
}
