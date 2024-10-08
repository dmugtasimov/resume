src/resume.tex: ;
src/telegram-logo.svg: ;
src/pandoc.yaml: ;
src/pandoc_postprocessor.py: ;

.PHONY: install-texlive
install-texlive:
	sudo apt install -y texlive texlive-latex-extra

.PHONY: install-pandoc-m4
install-pandoc-m4:
	sudo apt install -y pandoc m4

.PHONY: install-pre-commit
install-pre-commit:
	pip install pre-commit

.PHONY: setup-pre-commit
setup-pre-commit:
	pre-commit uninstall
	pre-commit install

.PHONY: install
install: install-texlive install-pandoc-m4 install-pre-commit setup-pre-commit ;

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
