import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]

  connect() {
    // Close modal on successful form submission
    this.element.addEventListener("turbo:submit-end", (event) => {
      if (event.detail.success) {
        this.close()
      }
    })

    // Close modal when clicking backdrop
    if (this.hasDialogTarget) {
      this.dialogTarget.addEventListener("click", (event) => {
        if (event.target === this.dialogTarget) {
          this.close()
        }
      })

      // Handle escape key
      this.dialogTarget.addEventListener("cancel", (event) => {
        event.preventDefault()
        this.close()
      })
    }
  }

  open() {
    if (this.hasDialogTarget) {
      this.dialogTarget.showModal()
      document.body.classList.add("overflow-hidden")
    }
  }

  close() {
    if (this.hasDialogTarget) {
      this.dialogTarget.close()
      document.body.classList.remove("overflow-hidden")

      // Clear the turbo frame content after closing
      const turboFrame = this.element.querySelector("turbo-frame")
      if (turboFrame) {
        turboFrame.src = null
        turboFrame.innerHTML = ""
      }
    }
  }
}
