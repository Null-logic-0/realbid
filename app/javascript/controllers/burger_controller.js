import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
	static targets = ["menu", "backdrop"]

	connect() {
		this.body = document.body
	}

	open() {
		this.menuTarget.classList.add("open")
		this.backdropTarget.classList.add("visible")
		this.body.style.overflow = "hidden"
	}

	close() {
		this.menuTarget.classList.remove("open")
		this.backdropTarget.classList.remove("visible")
		this.body.style.overflow = ""
	}

	// Closes menu when ESC is pressed
	handleKeydown(event) {
		if (event.key === "Escape") {
			this.close()
		}
	}
}
