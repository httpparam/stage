import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle("hidden")
  }

  hide(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }

  connect() {
    this.clickHandler = this.hide.bind(this)
    document.addEventListener("click", this.clickHandler)
  }

  disconnect() {
    document.removeEventListener("click", this.clickHandler)
  }
}
