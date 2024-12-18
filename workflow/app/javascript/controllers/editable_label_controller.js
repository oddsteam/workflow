import { Controller } from "@hotwired/stimulus"

const MIN_INPUT_WIDTH_PX = 50;

// Connects to data-controller="editable-label"
export default class extends Controller {
  static values = { editorClass: String, identifier: String, maxWidth: Number, maxWidthModifier: Number, horizontalPadding: Number };
  static targets = [ 'label', 'input', 'measure' ];

  connect() {
    this.view();
    this.input = this.inputTarget.querySelector('input');
    this.originalValue = this.labelTarget.innerText;
    this.recentValue = this.labelTarget.innerText;
    this.measureTarget.innerText = this.input.value;
    this.input.addEventListener("keydown", this.handleKeyDown.bind(this));
    this.input.addEventListener("keyup", this.handleKeyUp.bind(this));
    this.input.addEventListener("blur", this.handleBlur.bind(this));
    // this.debug();
  }

  disconnect() {
    this.input.removeEventListener("keydown", this.handleKeyDown.bind(this)); 
    this.input.removeEventListener("keyup", this.handleKeyUp.bind(this)); 
    this.input.removeEventListener("blur", this.handleBlur.bind(this)); 
  }

  debug() {
    this.inputTarget.classList.remove('hidden');
    this.labelTarget.classList.remove('hidden');
  }

  edit() {
    this.syncInputWidth();
    this.inputTarget.classList.remove('hidden');
    this.labelTarget.classList.add('hidden');
    this.input.select();
  }

  view() {
    this.labelTarget.classList.remove('hidden');
    this.inputTarget.classList.add('hidden');
  }

  cancelChanges() {
    // console.log('cancelled', { detail: { original: this.originalValue }, prefix: this.identifierValue });
    this.input.value = this.originalValue;
    this.labelTarget.input = this.originalValue;
    this.view();
  }

  commitChanges() {
    this.dispatch('changed', { detail: { original: this.originalValue, new: this.input.value }, prefix: this.identifierValue });
    // console.log('changed', { detail: { original: this.originalValue, new: this.input.value }, prefix: this.identifierValue });
    this.originalValue = this.input.value;
    this.labelTarget.input = this.originalValue;
    this.view();
  }

  syncInputWidth() {
    let maxWidth = this.maxWidthValue?this.maxWidthValue:this.measureTarget.parentElement.parentElement.offsetWidth;
    maxWidth += (this.maxWidthModifierValue?this.maxWidthModifierValue:0);
    let textWidth = this.measureTarget.offsetWidth;
    if (textWidth < MIN_INPUT_WIDTH_PX) {
      textWidth = MIN_INPUT_WIDTH_PX;
    }
    if (textWidth > maxWidth) {
      textWidth = maxWidth;
    }
    textWidth += this.horizontalPaddingValue?this.horizontalPaddingValue:4;
    this.inputTarget.style.width = textWidth + 'px';
    this.input.style.width = textWidth + 'px';
  }

  handleBlur(event) {
    if (this.input.value != this.originalValue) {
      this.commitChanges();
    } else {
      this.cancelChanges();
    }
  }

  handleKeyUp(event) {
    if (this.input.value != this.recentValue) {
      this.recentValue = this.input.value;
      this.measureTarget.innerText = this.recentValue;
      this.syncInputWidth();
    }
  }

  handleKeyDown(event) {
    switch (event.key){
      case "Escape":
        this.cancelChanges();
        break;
      case "Enter":
        this.commitChanges();
        break;
    }
  }
}
