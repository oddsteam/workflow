import { Controller } from "@hotwired/stimulus"
import Sortable from 'sortablejs';

// Connects to data-controller="draggable-item"
export default class extends Controller {
  static values = { group: String, listName: String, uniqueIdAttribute: String, identifier: String };

  connect() {
    this.uniqueIdAttribute = this.uniqueIdAttributeValue || "data-id";
    this.sortable = new Sortable(this.element, {
      group: this.groupValue,
      animation: 150,
      ghostClass: "ghost-class", // see application.tailwind.css for this utility class
      dragClass: "drag-class",
      chosenClass: "chosen-class",
      forceFallback: true,
      onChoose: this.onChoose.bind(this),
      onEnd: this.onEnd.bind(this),
    });
  }

  disconnect() {
  }

  onChoose(event) {
  }

  onEnd(event) {
    const draggedItemID = Number.parseInt(event.item.getAttribute(this.uniqueIdAttribute), 10);
    const sourceListID = Number.parseInt(event.from.getAttribute(this.uniqueIdAttribute), 10);
    const destinationListID = Number.parseInt(event.to.getAttribute(this.uniqueIdAttribute), 10);
    const sourceOrder = Array.from(event.from.children)
      .map((child) => Number.parseInt(child.getAttribute(this.uniqueIdAttribute), 10));
    const destinationOrder = Array.from(event.to.children)
      .map((child) => Number.parseInt(child.getAttribute(this.uniqueIdAttribute), 10));
    const destinationIndex = event.newIndex;
    const sourceIndex = event.oldIndex;

    const eventData = {
      draggedItemID,
      sourceListID,
      sourceOrder,
      sourceIndex,
      destinationListID,
      destinationOrder,
      destinationIndex,
    };

    // console.log(eventData);
    if (eventData.sourceListID === eventData.destinationListID && eventData.sourceIndex === eventData.destinationIndex) {
      // console.log('Unchanged positioning detected.');
      return;
    }

    if (eventData.sourceListID === eventData.destinationListID) {
      // console.log(`Reordering in list id ${eventData.sourceListID} detected.`);
    } else {
      // console.log(`Crossed-List reordering from list id ${eventData.sourceListID} to list id ${eventData.destinationListID} detected with item id ${eventData.draggedItemID}.`);
    }
    // console.log('moved', { detail: eventData, prefix: this.identifierValue });
    this.dispatch('moved', { detail: eventData, prefix: this.identifierValue });
  }
}
