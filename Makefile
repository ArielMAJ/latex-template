MAIN     := main
LATEX    := latexmk
FLAGS    := -pdf -pdflatex="pdflatex -interaction=nonstopmode -halt-on-error" -use-make

.PHONY: all clean watch open

## Default: compile the PDF
all: $(MAIN).pdf

$(MAIN).pdf: $(MAIN).tex references.bib
	$(LATEX) $(FLAGS) $(MAIN)

## Continuous compilation (recompiles on file change)
watch:
	$(LATEX) $(FLAGS) -pvc $(MAIN)

## Open the PDF (macOS: open, Linux: xdg-open)
open: $(MAIN).pdf
	@command -v open >/dev/null 2>&1 && open $(MAIN).pdf || xdg-open $(MAIN).pdf

## Remove all generated files including the PDF
clean:
	$(LATEX) -CA
	rm -f $(MAIN).bbl

## Remove only auxiliary files, keep the PDF
clean-aux:
	$(LATEX) -c
