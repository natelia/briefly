import { Controller } from "@hotwired/stimulus"

// The dark-mode toggle. The boot script in the layout reads localStorage
// before first paint, so the mode is never wrong and never flashes.
export default class extends Controller {
  static targets = [ "label" ]

  connect() {
    this.render()
  }

  toggle() {
    const current = this.effectiveMode()
    const next = current === "dark" ? "light" : "dark"
    document.documentElement.dataset.mode = next
    localStorage.setItem("mode", next)
    this.render()
  }

  effectiveMode() {
    const set = document.documentElement.dataset.mode
    if (set) return set
    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light"
  }

  render() {
    this.labelTarget.textContent = this.effectiveMode() === "dark" ? "light" : "dark"
  }
}
