#SHELL = /bin/bash

チュートリアル.pdf: _build/main.pdf
	cp _build/main.pdf チュートリアル.pdf
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
	mv main.tar.gz チュートリアル.tar.gz
zip:
	arl -z main.tex
	zip main.zip Makefile
	mv main.zip チュートリアル.zip
