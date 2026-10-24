.DEFAULT_GOAL := help
GALLERY := static/uploads/gallery

.PHONY: help serve build test photos clean-photos clean

help: ## Show the available commands
	@awk 'BEGIN {FS = ":.*## "} /^[a-z-]+:.*## / {printf "  make %-13s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

serve: ## Run the site locally at http://localhost:1313
	hugo server

build: ## Build the site into public/ like the CI does
	hugo --gc --minify

test: ## Test the Dropbox import script
	.github/scripts/test-sync-dropbox-photos.sh

photos: ## Download the gallery photos from Dropbox: make photos URL="<shared folder link>"
	@test -n "$(URL)" || { echo 'Usage: make photos URL="<Dropbox shared folder link>"'; exit 1; }
	rm -f $(GALLERY)/dropbox-*
	DROPBOX_FOLDER_URL="$(URL)" .github/scripts/sync-dropbox-photos.sh $(GALLERY)

clean-photos: ## Remove the photos downloaded from Dropbox
	rm -f $(GALLERY)/dropbox-*

clean: ## Remove the build output and caches
	rm -rf public resources .hugo_build.lock
