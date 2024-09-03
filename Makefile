.PHONY: generate
generate:
	mkdir -p generated
	pdflatex -shell-escape -jobname=generated/dmugtasimov-resume src/resume.tex
