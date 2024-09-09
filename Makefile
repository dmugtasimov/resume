PDF_DIRECTORY := generated-pdf
HTML_DIRECTORY := generated-html

src/resume.tex: ;
src/telegram-logo.svg: ;
src/pandoc-md.yaml: ;
src/pandoc-html.yaml: ;
src/pandoc_postprocessor.py: ;
src/styles.css: ;

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
generate-pdf ${PDF_DIRECTORY}/dmugtasimov-resume.pdf: src/resume.tex src/telegram-logo.svg
	mkdir -p ${PDF_DIRECTORY}
	-cat src/resume.tex | m4 --define=PROCESSOR=pdflatex | pdflatex -shell-escape -jobname=${PDF_DIRECTORY}/dmugtasimov-resume

.PHONY: generate-markdown
generate-markdown README.md: src/pandoc-md.yaml src/resume.tex src/pandoc_postprocessor.py
	-cat src/resume.tex | m4 --define=PROCESSOR=pandoc | pandoc --defaults=src/pandoc-md.yaml | ./src/pandoc_postprocessor.py > README.md

.PHONY: generate-html
generate-html ${HTML_DIRECTORY}/dmugtasimov-resume.html: src/pandoc-html.yaml src/resume.tex src/styles.css
	mkdir -p ${HTML_DIRECTORY}
	-cat src/resume.tex | m4 --define=PROCESSOR=pandoc | pandoc --defaults=src/pandoc-html.yaml > ${HTML_DIRECTORY}/dmugtasimov-resume.html

.PHONY: generate-all
generate-all: generated/dmugtasimov-resume.pdf README.md ${HTML_DIRECTORY}/dmugtasimov-resume.html ;


.PHONY: lint
lint:
	pre-commit run --all-files
