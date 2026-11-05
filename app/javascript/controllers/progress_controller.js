import { Controller } from "@hotwired/stimulus"

// The reading rule. The element is rendered at data-fill-from inline (0 on a
// fresh load, its previous value in a Turbo replace); this controller only
// pushes it to data-fill on the next frame, so exactly one transition runs —
// the delta — with no flash.
export default class extends Controller {
  connect() {
    const target = this.element.dataset.fill

    requestAnimationFrame(() => {
      this.element.style.setProperty("--fill", target)
    })
  }
}
