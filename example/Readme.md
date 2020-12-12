# Examples for lb and lb.conf

## example1

How to compile it.

-Run the terminal and change the current directory to `example1`.
-Type `lb`.

Lb.conf describes configurations for lb.
Here is an sample lb.conf.

    # configuration file for lb
    rootfile=example.tex
    builddir=_build
    engine=latex
    latex_option=-halt-on-error
    dvipdf=dvipdf
    preview=

Compilation will be done as follows by the file above.

    $ latexmk -dvi -latex="latex -halt-on-error %S %O" _build example.tex
    $ dvipdf _build/example.dvi _build/example.pdf

The following describes the behavior of lb if some items are changed.

-rootfile=(empty string).
No rootfile name is specified.
You can compile example.tex if you give it to `lb` as an argument.
Spcifically, type `lb example` or `lb example.tex`.
If you type just `lb`, it means no rootfile is specified.
In this case, `lb` takes the default value `main.tex` as a rootfile name, but there doesn't exist `main.tex` and `lb` prints a error massage and exits.
-builddif=(empty string)
No build directory is specified.
All the auxiliary files and the target file will be put into the source directory.
-engine=pdflatex.
This specifies pdflatex as a latex engine.
Pdflatex compiles latex source files into pdf files directly.
No dvi file is generated.
-engine=(empty string).
No engine is specified.
In this case, `lb` guesses the suitable engine for the given latex source file.
The source file `example1.tex` specifies `article` as a documentclass.
This documentclass can be compiled by latex, pdflatex, xelatex and lualatex.
However, pdflatex is the standard engine to compile it for ages.
So, `lb` (actually `ltxengine` called by `lb`) chooses pdflatex.
-dvipdf=dvipdfmx.
`lb` uses `dvipdfmx` instead of dvipdf.

## example2

In the directory `example2`, there are some examples to show how lb behaves if lb.conf isn't given.
Open the terminal and change the current directory to `example2`.

    $ lb

No arguments given.
Then lb assume that the rootfile name is `main.tex`.
It specifies `jsarticle` as a documentclass in line one.
This documentclass is a Japanese version of article documentclass.
Lb uses `platex` as an engine and `dvipdfmx` as a converter from dvi to pdf.

    $ lb ex1

Lb compiles `ex1.tex`.
Its documentclass is `ltjsarticle`.
It is similar to article documentclass, but for Japanese and `lualatex` engine.
So, lb uses `lualatex` as an engine and it generates pdf file directly.

    $ lb ex2

Lb compiles `ex2.tex`.
Its documentclass is `article`.
So, lb uses `pdflatex` as an engine and it generates pdf file directly.

## example3

In this directory, there are `main.tex` and `sub.tex`.
The rootfile is `main.tex` and it includes `sub.tex` using \\input command.

    $ lb

No arguments given.
Then lb assume that the rootfile name is `main.tex`.
Lb uses pdflatex as an engine and it compiles `main.tex` to `main.pdf`.

    $ lb sub

The argument is `sub`.
Lb adds `.tex` to `sub`, so the argument will be `sub.tex`.
This is not a rootfile.
It's a subfile.
Then, lb creates a temporary rootfile `test_sub.tex` in the build directory and compile it to `test_sub.pdf`.
When lb compiles a temporary rootfile, it runs pdf viewer after compilation.
`Lb.conf` specifies `evince` as a viewer, so `evince` will be run and it shows the generated pdf file.
Lb gives the synctex option to pdflatex via latexmk.
If the editor and the viewer support synctex, then you can use search forward and search backward.
First, you need to open `_build/test_sub.tex` and `sub.tex` with your editor.
You can search backward from pdf file by clicking CTRL + (left click).
If you open only `sub.tex` then synctex doesn't work.
You need to open `_build/test_sub.tex`.

