import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="editable-label"
export default class extends Controller {
  static values = { editorClass: String, original: String, identifier: String };
  static targets = [ 'label', 'input' ];

  connect() {
    this.view();
    this.inputTarget.addEventListener("keydown", this.handleKeyDown.bind(this));
    this.input = this.inputTarget.querySelector('input');
  }

  disconnect() {
    this.inputTarget.removeEventListener("keydown", this.handleKeyDown.bind(this)); 
  }

  edit() {
    this.inputTarget.classList.remove('hidden');
    this.labelTarget.classList.add('hidden');
    this.input.select();
  }

  view() {
    this.labelTarget.classList.remove('hidden');
    this.inputTarget.classList.add('hidden');
  }

  confirm() {
    this.dispatch('changed', { detail: { original: this.originalValue, new: this.input.value }, prefix: this.identifierValue });
    this.view();
    console.log('changed', { detail: { original: this.originalValue, new: this.input.value }, prefix: this.identifierValue });
  }

  cancel() {
    this.input.value = this.originalValue;
    this.view();
    console.log('cancelled', { detail: { original: this.originalValue }, prefix: this.identifierValue });
  }

  handleKeyDown(event) {
    if (event.key === "Escape") {
      this.cancel();
    }
  }
}
