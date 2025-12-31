import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]
  static values = { url: String }

  connect() {
    this.timeout = null
    this.saveDelay = 1000 // Save after 1 second of inactivity
  }

  scheduleAutoSave() {
    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      this.autoSave()
    }, this.saveDelay)
  }

  autoSave() {
    const form = this.element
    const formData = new FormData(form)

    // Don't submit if this is a new note (not persisted yet)
    const action = form.action
    if (!action || action.endsWith('/notes')) {
      return
    }

    // Use fetch to save without redirecting
    fetch(action, {
      method: 'PATCH',
      body: formData,
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
        'Accept': 'text/vnd.turbo-stream.html'
      }
    }).then(response => {
      if (response.ok) {
        this.showSaveStatus("Saved")
      }
    })
  }

  saved(event) {
    if (event.detail.success) {
      this.showSaveStatus("Saved")
    }
  }

  showSaveStatus(message) {
    const statusElement = document.getElementById("save-status")
    if (statusElement) {
      statusElement.textContent = message
      statusElement.classList.add("text-green-600")

      setTimeout(() => {
        statusElement.textContent = ""
        statusElement.classList.remove("text-green-600")
      }, 2000)
    }
  }
}
