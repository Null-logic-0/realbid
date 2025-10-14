import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
	connect() {
		console.log("connecting...");
		setTimeout(() => {
			this.element.classList.add("fade-out")

			setTimeout(() => this.element.remove(), 400)
		}, 2000)
	}
}
