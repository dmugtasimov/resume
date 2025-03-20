src/resume.tex: ;
src/telegram-logo.svg: ;
src/pandoc.yaml: ;
src/pandoc_postprocessor.py: ;
src/filter.lua: ;
Makefile: ;

.PHONY: apt-update
apt-update:
	sudo apt update

.PHONY: install-texlive
install-texlive:
	sudo apt install -y texlive=2023.20240207-1 \
		texlive-latex-extra=2023.20240207-1 \
		texlive-base=2023.20240207-1 \
		texlive-binaries=2023.20230311.66589-9build3 \
		texlive-fonts-recommended=2023.20240207-1 \
		texlive-latex-base=2023.20240207-1 \
		texlive-latex-recommended=2023.20240207-1 \
		texlive-pictures=2023.20240207-1 \
		texlive-plain-generic=2023.20240207-1

.PHONY: install-pandoc-m4
install-pandoc-m4:
	sudo apt install -y pandoc=3.1.3+ds-2 \
		pandoc-data=3.1.3-1 \
		m4=1.4.19-4build1

.PHONY: install-pipx
install-pipx:
	sudo apt install -y pipx
	pipx ensurepath
	pipx install pipx==1.7.1

.PHONY: install-pre-commit
install-pre-commit: install-pipx
	pipx install pre-commit==4.0.1

.PHONY: setup-pre-commit
setup-pre-commit:
	pre-commit uninstall; pre-commit install

.PHONY: install
install: apt-update install-texlive install-pandoc-m4 install-pre-commit setup-pre-commit ;

.PHONY: generate-pdf
generate-pdf: generated/dmugtasimov-resume.pdf

generated/dmugtasimov-resume.pdf: src/resume.tex src/telegram-logo.svg
	mkdir -p generated
	-cat src/resume.tex | m4 --define=PROCESSOR=pdflatex | pdflatex -shell-escape -jobname=generated/dmugtasimov-resume

.PHONY: generate-markdown
generate-markdown: README.md

README.md: src/resume.tex src/pandoc.yaml src/pandoc_postprocessor.py Makefile
	-cat src/resume.tex | m4 --define=PROCESSOR=pandoc | pandoc --defaults=src/pandoc.yaml | ./src/pandoc_postprocessor.py > README.md

.PHONY: generate-all
generate-all: generated/dmugtasimov-resume.pdf README.md ;

.PHONY: lint
lint:
	pre-commit run --all-files
