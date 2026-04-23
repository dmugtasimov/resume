PRE_COMMIT_VERSION := 4.5.1
PYPANDOC_BINARY_VERSION := 1.17
WEASYPRINT_VERSION := 68.1
BUILD_DIR := build
TEMPORARY_HTML_FILE := /tmp/.resume-$(shell date '+%Y-%d-%m-%H-%M-%S').tmp.html
GREEN := \033[0;32m
RESET := \033[0m
msg ?= $(shell date '+%Y-%m-%d %H:%M:%S')

.PHONY: help
help:
	@echo 'Specify a target explicitly: make <target>'

Makefile: ;
README.md: ;
src/pandoc.yaml: ;
src/pandoc-html.yaml: ;
src/pandoc-pdf-template.html: ;
src/resume.css: ;

.PHONY: install-uv
install-uv:
	@printf '\n$(GREEN)%s$(RESET)\n' 'Installing uv if not already installed...'
	if ! command -v uv >/dev/null 2>&1; then \
		curl -LsSf https://astral.sh/uv/install.sh | sh; \
	fi

.PHONY: run-pre-commit
run-pre-commit: install-uv
	uvx pre-commit==$(PRE_COMMIT_VERSION) $(args)

.PHONY: run-pandoc
run-pandoc: install-uv
	uvx --from pypandoc-binary==$(PYPANDOC_BINARY_VERSION) pypandoc pandoc $(args)

.PHONY: run-weasyprint
run-weasyprint: install-uv
	uvx weasyprint==$(WEASYPRINT_VERSION) $(args)

.PHONY: install-pre-commit
install-pre-commit:
	@printf '\n$(GREEN)%s$(RESET)\n' 'Installing pre-commit...'
	$(MAKE) run-pre-commit args=install

.PHONY: install-pandoc
install-pandoc: install-uv
	@printf '\n$(GREEN)%s$(RESET)\n' 'Installing pandoc...'
	$(MAKE) run-pandoc args=--version

.PHONY: install-weasyprint
install-weasyprint: install-uv
	@printf '\n$(GREEN)%s$(RESET)\n' 'Installing weasyprint...'
	$(MAKE) run-weasyprint args=--version

.PHONY: setup
setup: install-uv install-pre-commit install-pandoc install-weasyprint ;

$(BUILD_DIR)/:
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/dmugtasimov-resume.md: README.md Makefile | $(BUILD_DIR)/
	cp README.md $(BUILD_DIR)/dmugtasimov-resume.md

$(BUILD_DIR)/dmugtasimov-resume.pdf: README.md src/pandoc.yaml src/pandoc-pdf-template.html src/resume.css Makefile | $(BUILD_DIR)/
	trap 'rm -f "$(TEMPORARY_HTML_FILE)"' EXIT && \
	$(MAKE) run-pandoc args='--defaults=src/pandoc.yaml README.md -o $(TEMPORARY_HTML_FILE)' && \
	$(MAKE) run-weasyprint args='--base-url "$(CURDIR)" "$(TEMPORARY_HTML_FILE)" $(BUILD_DIR)/dmugtasimov-resume.pdf'

$(BUILD_DIR)/dmugtasimov-resume.html: README.md src/pandoc-html.yaml src/resume.css Makefile | $(BUILD_DIR)/
	$(MAKE) run-pandoc args='--embed-resources --defaults=src/pandoc-html.yaml README.md -o $(BUILD_DIR)/dmugtasimov-resume.html'

.PHONY: build-md
build-md: $(BUILD_DIR)/dmugtasimov-resume.md

.PHONY: build-pdf
build-pdf: $(BUILD_DIR)/dmugtasimov-resume.pdf

.PHONY: build-html
build-html: $(BUILD_DIR)/dmugtasimov-resume.html

.PHONY: build-all
build-all: build-pdf build-html build-md ;

.PHONY: build
build: build-all ;

.PHONY: build-force
build-force:
	rm -rf $(BUILD_DIR)
	$(MAKE) build

.PHONY: lint
lint: install-uv
	$(MAKE) run-pre-commit args='run --all-files'

.PHONY: tag
tag:
	git tag -a -m '' $(name) $(tag_args)

.PHONY: tag-latest
tag-latest:
	$(MAKE) tag name=latest tag_args=-f

.PHONY: release
release:
	version=$$(cat .version) && \
	git fetch --tags --force >/dev/null 2>&1 && \
	highest_existing_version=$$(git tag --list 'v*' | sort -u | sort -V | tail -n 1) && \
	if [ -n "$$highest_existing_version" ] && [ "$$(printf '%s\n' "$$version" "$$highest_existing_version" | sort -V | tail -n 1)" = "$$highest_existing_version" ]; then \
	    echo ''; \
	    echo ''; \
		printf 'Same or higher version tag already exists: %s.\n' "$$highest_existing_version"; \
		printf 'Please bump version in ./.version.\n\n\n'; \
		exit 1; \
	fi && \
	$(MAKE) tag name=$$version && \
	$(MAKE) tag-latest && \
	git push origin $$version && \
	git push origin latest -f

.PHONY: codex-unleashed
codex-unleashed:
	codex --dangerously-bypass-approvals-and-sandbox

.PHONY: commit-and-push
commit-and-push: commit_args = -m "$(msg)"
commit-and-push: commit-and-push-common

.PHONY: amend-and-push
amend-and-push: commit_args = --amend --no-edit
amend-and-push: push_args = -f
amend-and-push: commit-and-push-common

.PHONY: commit-and-push-common
commit-and-push-common:
	git diff --quiet && git diff --cached --quiet || git commit --all $(commit_args)
	git push $(push_args)
