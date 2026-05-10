MAIN            := main
PROJECT         := $(notdir $(PWD))
OUT_DIR         := build
HALT_ON_ERROR   ?= 0
ifeq ($(HALT_ON_ERROR),1)
  PDFLATEX_OPTS := pdflatex -interaction=nonstopmode -halt-on-error
else
  PDFLATEX_OPTS := pdflatex -interaction=nonstopmode
endif
FLAGS           := -pdf -pdflatex="$(PDFLATEX_OPTS)" -auxdir=$(OUT_DIR) -jobname=$(PROJECT)
LATEX_IMAGE     := texlive/texlive:latest

# Auto-detect: prefer local latexmk, fall back to Docker/Podman
LATEXMK_BIN     := $(shell which latexmk 2>/dev/null)
CONTAINER_ENGINE := $(shell which podman 2>/dev/null || which docker 2>/dev/null)

ifdef LATEXMK_BIN
  LATEX       := latexmk
  LATEX_WATCH := latexmk
  WATCH_FLAGS := $(FLAGS)
else
  LATEX       := $(CONTAINER_ENGINE) run --rm  -v "$(PWD)":/workspace -w /workspace $(LATEX_IMAGE) latexmk
  LATEX_WATCH := $(CONTAINER_ENGINE) run --rm -d --name latex-watch -v "$(PWD)":/workspace -w /workspace $(LATEX_IMAGE) latexmk
  WATCH_FLAGS := $(FLAGS) -view=none
endif

.PHONY: build watch watch-logs watch-stop open clean clean-aux pull help

build: $(PROJECT).pdf ## Compile the PDF (uses Docker if latexmk is not installed locally).

$(PROJECT).pdf: $(MAIN).tex references.bib
	$(LATEX) $(FLAGS) $(MAIN)

.PHONY: watch
watch: ## Continuously recompile on file change (detached when running via Docker).
	$(LATEX_WATCH) $(WATCH_FLAGS) -pvc $(MAIN)

.PHONY: watch-logs
watch-logs: ## Follow the Docker watcher logs (Ctrl+C to detach).
	$(CONTAINER_ENGINE) logs -f latex-watch

.PHONY: watch-stop
watch-stop: ## Stop the Docker watcher container.
	$(CONTAINER_ENGINE) stop latex-watch

.PHONY: open
open: $(PROJECT).pdf ## Open the compiled PDF.
	@command -v open >/dev/null 2>&1 && open $(PROJECT).pdf || xdg-open $(PROJECT).pdf

.PHONY: clean
clean: ## Remove all auxiliary files but keep the PDF.
	rm -rf $(OUT_DIR)

.PHONY: pull
pull: ## Pull the LaTeX Docker image.
	$(CONTAINER_ENGINE) pull $(LATEX_IMAGE)

.DEFAULT_GOAL := help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sed 's/Makefile://g' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
