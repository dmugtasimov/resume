src/resume.tex: ;
src/telegram-logo.svg: ;
src/pandoc.yaml: ;
src/pandoc_postprocessor.py: ;

.PHONY: install-prerequisites
install-prerequisites:
	sudo apt install texlive texlive-latex-extra pandoc

.PHONY: install-pre-commit
install-pre-commit:
	pip install pre-commit; pre-commit uninstall; pre-commit install

.PHONY: install
install: install-prerequisites install-pre-commit ;

.PHONY: generate-pdf
generate-pdf: generated/dmugtasimov-resume.pdf

generated/dmugtasimov-resume.pdf: src/resume.tex src/telegram-logo.svg
	mkdir -p generated
	-cat src/resume.tex | m4 --define=PROCESSOR=pdflatex | pdflatex -shell-escape -jobname=generated/dmugtasimov-resume

.PHONY: generate-markdown
generate-markdown: README.md

README.md: src/resume.tex src/pandoc.yaml src/pandoc_postprocessor.py
	-cat src/resume.tex | m4 --define=PROCESSOR=pandoc | pandoc --defaults=src/pandoc.yaml | ./src/pandoc_postprocessor.py > README.md

.PHONY: generate-all
generate-all: generated/dmugtasimov-resume.pdf README.md ;


.PHONY: lint
lint:
	pre-commit run --all-files
