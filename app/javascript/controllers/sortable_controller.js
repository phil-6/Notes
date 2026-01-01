import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = {
    url: String,
    param: { type: String, default: "position" }
  }

  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      handle: "[data-sortable-handle]",
      ghostClass: "opacity-50",
      onEnd: this.onEnd.bind(this)
    })
  }

  disconnect() {
    if (this.sortable) {
      this.sortable.destroy()
    }
  }

  onEnd(event) {
    if (event.oldIndex === event.newIndex) return

    const id = event.item.dataset.sortableId
    const newPosition = event.newIndex + 1

    this.updatePosition(id, newPosition)
  }

  updatePosition(id, position) {
    const url = this.urlValue.replace(":id", id)
    const csrfToken = document.querySelector('[name="csrf-token"]').content

    fetch(url, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken,
        "Accept": "application/json"
      },
      body: JSON.stringify({
        [this.paramValue]: position
      })
    }).catch(error => {
      console.error("Failed to update position:", error)
      // Reload the page if the update fails
      window.location.reload()
    })
  }
}
