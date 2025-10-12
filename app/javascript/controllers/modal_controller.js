import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
	static targets = ["modal"];

	connect() {
		this.closeOnEsc = this.closeOnEsc.bind(this);
		document.addEventListener("keydown", this.closeOnEsc);

	}

	disconnect() {
		document.removeEventListener("keydown", this.closeOnEsc);
	}

	open() {
		this.modalTarget.classList.add("show");
	}

	close() {
		this.modalTarget.classList.remove("show");
	}

	closeOnEsc(event) {
		if (event.key === "Escape") this.close();
	}
}
