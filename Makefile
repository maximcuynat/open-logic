# open-logic - local pipeline. Run `make help` for the list of targets.
# There is no hosted CI: `make check` is the gate to run before every push.

GODOT     ?= $(shell command -v godot 2>/dev/null || echo /Applications/Godot.app/Contents/MacOS/Godot)
BUMP      ?= patch
DRY_RUN   ?= 0
export GODOT

GD_SOURCES := src tests tools

.DEFAULT_GOAL := help
.PHONY: help doctor hooks import fmt fmt-check lint test smoke check run screenshot export promote release deploy-web clean

help: ## Show this help
	@awk 'BEGIN {FS = ":.*## "} /^[a-zA-Z_-]+:.*## / {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

doctor: ## Check that every required tool is installed
	@scripts/doctor.sh

hooks: ## Install the git hooks (format, lint, secrets, commit message)
	@git config core.hooksPath .githooks
	@echo "Git hooks installed from .githooks/"

import: ## Import project resources (needed once before tests/export)
	@"$(GODOT)" --headless --path . --import >/dev/null 2>&1 || true

fmt: ## Format GDScript sources in place
	@gdformat $(GD_SOURCES)

fmt-check: ## Fail if GDScript sources are not formatted
	@gdformat --check $(GD_SOURCES)

lint: fmt-check ## Format check + gdlint
	@gdlint $(GD_SOURCES)

test: import ## Run the gdUnit4 test suite headless
	@scripts/test.sh

smoke: import ## Boot the main scene headless and fail on script errors
	@scripts/smoke.sh

check: lint test smoke ## Full local CI gate: lint, tests, smoke test

run: ## Launch the editor app
	@"$(GODOT)" --path .

screenshot: import ## Render docs/images/screenshot.png
	@"$(GODOT)" --path . -s res://tools/screenshot.gd -- "$(CURDIR)/docs/images/screenshot.png"

export: import ## Export all platforms into build/ (VERSION=x.y.z optional)
	@scripts/export.sh $(VERSION)

promote: ## Fast-forward main to develop (run before a release)
	@scripts/promote.sh

release: ## Cut a release: make release BUMP=patch|minor|major [DRY_RUN=1]
	@BUMP=$(BUMP) DRY_RUN=$(DRY_RUN) scripts/release.sh

deploy-web: ## Publish the Web build to GitHub Pages (gh-pages branch)
	@scripts/deploy-web.sh

clean: ## Remove build artifacts and test reports
	@rm -rf build reports
