import { Controller } from "@hotwired/stimulus"
import Sortable from 'sortablejs';

// Connects to data-controller="draggable-item"
export default class extends Controller {
  static values = { group: String };

  connect() {
    this.sortable = Sortable.create(this.element, {
      group: this.groupValue,
      animation: 150
    })
  }

  disconnect() {
    this.sortable.destroy();
  }
}
