import { Controller } from "@hotwired/stimulus"
import Sortable from 'sortablejs';

// Connects to data-controller="draggable-item"
export default class extends Controller {
  static values = { group: String, listName: String, uniqueIdAttribute: String };

  connect() {
    this.uniqueIdAttribute = this.uniqueIdAttributeValue;
    if (!this.uniqueIdAttribute) {
      this.uniqueIdAttribute = "data-id";
    }
    this.sortable = new Sortable(this.element, {
      group: this.groupValue,
      animation: 150,
      ghostClass: "ghost-class", // see application.tailwind.css for this utility class
      dragClass: "drag-class",
      chosenClass: "chosen-class",
      onEnd: this.onEnd.bind(this),
    });
  }

  disconnect() {
  }

  onEnd(event) {
    const draggedItem = event.item.getAttribute(this.uniqueIdAttribute);
    const sourceList = event.from.getAttribute(this.uniqueIdAttribute);
    const destinationList = event.to.getAttribute(this.uniqueIdAttribute);
    const sourceOrder = Array.from(event.from.children)
      .map((child) => child.getAttribute(this.uniqueIdAttribute));
    const destinationOrder = Array.from(event.to.children)
      .map((child) => child.getAttribute(this.uniqueIdAttribute));

    const eventData = {
      draggedItem,
      sourceList,
      sourceOrder,
      destinationList,
      destinationOrder,
    };

    console.log(eventData);
    if (eventData.sourceList === eventData.destinationList) {
      console.log(`list id ${eventData.sourceList} is reordered.`);
    } else {
      console.log(`item id ${eventData.draggedItem} is dragged from list id ${eventData.sourceList} to list id ${eventData.destinationList}.`);
    }
  }
}
