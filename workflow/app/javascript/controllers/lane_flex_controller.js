import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="lane-flex"
export default class extends Controller {
  static values = { regularWidth: String, wideWidth: String };
  static targets = [ 'widener', 'shrinker' ];

  connect() {
    this.regularWidth = this.regularWidthValue.split(" ");
    this.wideWidth = this.wideWidthValue.split(" ");
    this.restore();
  }

  widen() {
    this.element.classList.add(...this.wideWidth);
    this.element.classList.remove(...this.regularWidth);
    this.widenerTarget.classList.add('hidden');
    this.shrinkerTarget.classList.remove('hidden');
  }

  restore() {
    this.element.classList.add(...this.regularWidth);
    this.element.classList.remove(...this.wideWidth);
    this.shrinkerTarget.classList.add('hidden');
    this.widenerTarget.classList.remove('hidden');
  }
}
