import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="popup-trigger"
export default class extends Controller {
  static targets = [ 'popup' ];

  connect() {
    this.popupTarget.classList.add('hidden');
    document.addEventListener("click", this.handleClickOutside.bind(this))
    document.addEventListener("keydown", this.handleKeyDown.bind(this));   
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside.bind(this))
    document.removeEventListener("keydown", this.handleKeyDown.bind(this)); 
  }

  show(event) {
    event.stopPropagation();
    this.popupTarget.classList.remove('hidden');
    this.dispatch('showed', { prefix: 'popup-trigger' })
  }

  handleClickOutside(event) {
    if (!this.popupTarget.contains(event.target) && !event.target.closest("[data-action='click->popup#toggle']")) {
      this.popupTarget.classList.add("hidden")
    }
  }

  handleKeyDown(event) {
    if (event.key === "Escape" && !this.popupTarget.classList.contains("hidden")) {
      this.popupTarget.classList.add("hidden");
    }
  }
}
