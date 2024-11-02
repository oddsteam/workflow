import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form-autofocus"
export default class extends Controller {
  static targets = [ 'autofocus' ];

  connect() {
  }

  focus() {
    if (this.autofocusTarget) {
      this.autofocusTarget.focus();
    }
  }
}
