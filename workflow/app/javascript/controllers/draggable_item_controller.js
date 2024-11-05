import { Controller } from "@hotwired/stimulus"
import Sortable from 'sortablejs';

// Connects to data-controller="draggable-item"
export default class extends Controller {
  static values = { group: String };

  connect() {
    this.sortable = new Sortable(this.element, {
      group: this.groupValue,
      animation: 150,
      ghostClass: "ghost-class", // see application.tailwind.css for this utility class
    });
  }

  disconnect() {
  }
}
