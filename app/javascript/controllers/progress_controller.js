import { Controller } from "@hotwired/stimulus"

// The reading rule. Renders at zero, then grows to its true fill on the next
// frame, so the transition always runs — on load and on every Turbo replace.
export default class extends Controller {
  connect() {
    const target = this.element.dataset.fill
    requestAnimationFrame(() => {
      this.element.style.setProperty("--fill", target)
    })
  }
}
