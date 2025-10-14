import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
	static targets = ["dropZone", "fileInput", "preview"];

	connect() {
		this.dropZoneTarget.addEventListener("click", () => this.fileInputTarget.click());

		this.fileInputTarget.addEventListener("change", (e) => this.handleFiles(e.target.files));

		this.dropZoneTarget.addEventListener("dragover", (e) => {
			e.preventDefault();
			this.dropZoneTarget.classList.add("dragover");
		});

		this.dropZoneTarget.addEventListener("dragleave", () => {
			this.dropZoneTarget.classList.remove("dragover");
		});

		this.dropZoneTarget.addEventListener("drop", (e) => {
			e.preventDefault();
			this.dropZoneTarget.classList.remove("dragover");
			const files = e.dataTransfer.files;

			// Assign files to input
			const dt = new DataTransfer();
			for (let i = 0; i < files.length; i++) dt.items.add(files[i]);
			this.fileInputTarget.files = dt.files;

			this.handleFiles(files);
		});
	}

	handleFiles(files) {
		if (!files[0]) return;

		// Clear previous preview
		this.dropZoneTarget.innerHTML = "";

		const reader = new FileReader();
		reader.onload = (e) => {
			const img = document.createElement("img");
			img.src = e.target.result;
			img.classList.add("preview-image");
			this.dropZoneTarget.appendChild(img);
		};
		reader.readAsDataURL(files[0]);
	}
}
