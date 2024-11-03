import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form-validator"
export default class extends Controller {
  static values = { enabledClasses: String, disabledClasses: String };

  connect() {
    this.submitButton = this.element.querySelector('button[type="submit"]') ||
      this.element.querySelector('input[type="submit"]') ||
      this.element.querySelector('button:not([type="submit"])');
    this.requiredFields = this.element.querySelectorAll("[required]:not(disabled)");
    this.enabledClasses = this.enabledClassesValue.split(" ");
    this.disabledClasses = this.disabledClassesValue.split(" ");
    this.element.addEventListener('input', this.validate.bind(this));
    this.validate();
  }

  submit(event) {
    const isValid = this.validate();

    if (!isValid) {
      event.preventDefault();
    }
  }

  validate() {
    let isValid = true;

    this.requiredFields.forEach((field) => {
      if (!field.value || field.value.trim() === "") {
        isValid = false;
        return;
      }
    })

    this.submitButton.disabled = !isValid;
    if (this.submitButton.disabled) {
      this.submitButton.classList.remove(...this.enabledClasses);
      this.submitButton.classList.add(...this.disabledClasses);
    } else {
      this.submitButton.classList.remove(...this.disabledClasses);
      this.submitButton.classList.add(...this.enabledClasses);
    }
    return isValid;
  }
}
