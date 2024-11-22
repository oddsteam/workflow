import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form-autosubmit"
export default class extends Controller {
  connect() {
  }

  submitEventData(event) {
    event.preventDefault();
    console.log('submitted', event.detail);

    const authenticity_token = this.element.querySelector('input[name="authenticity_token"]').value;
    fetch(this.element.action + `?authenticity_token=${authenticity_token}`, {
      method: this.element.method,
      body: JSON.stringify(event.detail),
      headers: {
        'Accept': 'text/vnd.turbo-stream.html', // Important for Turbo Streams
        'Content-Type': 'application/json',
      }
    })
    .then(response => response.text())
    .then(html => Turbo.renderStreamMessage(html));

    // this.element.requestSubmit();
  }
}
