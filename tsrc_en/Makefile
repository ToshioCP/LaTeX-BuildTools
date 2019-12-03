#SHELL = /bin/bash

bookname.pdf: _build/main.pdf
	cp _build/main.pdf bookname.pdf
_build/main.pdf: FORCE
	lb

FORCE:

.Phony: FORCE clean ar zip

clean:
	rm -rf _build
ar:
	arl main
	mv main.tar.gz bookname.tar.gz
zip:
	arl -z main
	mv main.zip bookname.zip

