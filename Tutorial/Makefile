#SHELL = /bin/bash

Tutorial.pdf: _build/main.pdf
	cp _build/main.pdf Tutorial.pdf
_build/main.pdf: FORCE
	lb main.tex

FORCE:

.Phony: FORCE clean ar zip

clean:
	rm -rf _build
ar:
	arl main.tex
	tar -rf main.tar Makefile
	gzip main.tar
	mv main.tar.gz Tutorial.tar.gz
zip:
	arl -z main.tex
	zip main.zip Makefile
	mv main.zip Tutorial.zip
