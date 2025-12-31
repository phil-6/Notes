import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Ensure the initial state matches the checkbox
    this.updateTheme()
  }

  toggle(event) {
    const isDark = event.target.checked

    // Update the HTML class immediately for instant visual feedback
    if (isDark) {
      document.documentElement.classList.add("dark")
    } else {
      document.documentElement.classList.remove("dark")
    }

    // Save the preference to the server
    this.savePreference(isDark)
  }

  updateTheme() {
    const checkbox = this.element.querySelector('input[type="checkbox"]')
    if (checkbox) {
      const isDark = checkbox.checked
      if (isDark) {
        document.documentElement.classList.add("dark")
      } else {
        document.documentElement.classList.remove("dark")
      }
    }
  }

  savePreference(isDark) {
    const form = this.element.querySelector("form")
    if (!form) return

    const formData = new FormData(form)
    const csrfToken = document.querySelector('[name="csrf-token"]').content

    fetch(form.action, {
      method: "PATCH",
      body: formData,
      headers: {
        "X-CSRF-Token": csrfToken,
        "Accept": "application/json"
      }
    }).catch(error => {
      console.error("Failed to save theme preference:", error)
    })
  }
}
