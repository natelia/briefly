import { Controller } from "@hotwired/stimulus"

// The reading rule. Starts at data-fill-from (the value it showed before this
// render — 0 on a fresh load), then grows to data-fill on the next frame, so
// the transition animates only the delta.
export default class extends Controller {
  connect() {
    const from = this.element.dataset.fillFrom || "0"
    const target = this.element.dataset.fill

    this.element.style.setProperty("--fill", from)
    requestAnimationFrame(() => {
      this.element.style.setProperty("--fill", target)
    })
  }
}
