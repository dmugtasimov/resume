src/resume.tex: ;
src/telegram-logo.svg: ;
src/pandoc.yaml: ;
src/pandoc_postprocessor.py: ;

.PHONY: generate-pdf
generate-pdf generated/dmugtasimov-resume.pdf: src/resume.tex src/telegram-logo.svg
	mkdir -p generated
	-cat src/resume.tex | m4 --define=PROCESSOR=pdflatex | pdflatex -shell-escape -jobname=generated/dmugtasimov-resume

.PHONY: generate-markdown
generate-markdown README.md: src/resume.tex src/pandoc.yaml src/pandoc_postprocessor.py
	-cat src/resume.tex | m4 --define=PROCESSOR=pandoc | pandoc --defaults=src/pandoc.yaml | ./src/pandoc_postprocessor.py > README.md

#.PHONY: generate-all
generate-all: generated/dmugtasimov-resume.pdf README.md ;
