import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
	static targets = ["dropdown"];

	connect() {
		this.closeDropdown = this.closeDropdown.bind(this);
	}

	toggle() {
		const isOpen = !this.dropdownTarget.classList.contains("hidden");
		if (isOpen) {
			this.dropdownTarget.classList.add("hidden");
			document.removeEventListener("click", this.closeDropdown);
		} else {
			this.dropdownTarget.classList.remove("hidden");
			setTimeout(() => {
				document.addEventListener("click", this.closeDropdown);
			}, 0);
		}
	}

	closeDropdown(event) {
		if (!this.element.contains(event.target)) {
			this.dropdownTarget.classList.add("hidden");
			document.removeEventListener("click", this.closeDropdown);
		}
	}
}
