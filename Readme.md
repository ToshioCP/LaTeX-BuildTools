# Buildtools

## The background of Buildtools

#### Buildtools is a part of Latextools

If you make a long document, for example, a book with more than a hundred pages, you need to consider various things which isn't necessary in creating a short document.

- Divide the source file into small parts
- Compile each parts independently
- Replace something with another in the whole document
- Preprocessing (processes before compiling latex source files)

Latextools support these things and it includes two parts.

- Buildtools. It is tools which support creating templates of source files, building and partial compiling.
- Substools. It is tools which perform replacements in the whole document.

Buildtools is a part of Latextools and also a core tools in it.
This document describes Buildtools only.

#### Dividing a source file

Latex source files are simply called source files here.
It is not appropriate to write a long document into a single source file.
Because, bigger the file, much more difficult to edit it.
To solve this, the document will be divided into some parts.
Usually, they consist of a file containing `\begin{document}` and `\end{document}` and the other files called by the file with `\include` or `\input` command.
The former file is called rootfile and the latter files are called subfiles.
There is a difference between `\include` and `\input` though both are commands to include subfiles.

- `\include` can't be nested.
it can be described only in the body, which means the part between `\begin{document}` and `\end{document}`.
`\includeonly`, which must be in the preamble, specifies a list of files to include by the `\include` command.
The files in the list are included by `\include` command, and files out of the list aren't included even if it is an argument of `\include` command.
`\include` command issues `\clearpage` command before and after including the file.

- `\input` command simply include files.
It doesn't issue `\clearpage` command.
This command can be nested.

It is called build to make a document by compiling.
It includes not only the compilation with latex but also the preprocessing, such as the image generation by gnuplot or tikz graph generation with data.
It is finally completed by the compilation of the rootfile.

There are several programs to compile LaTeX source files, and they are called engines.
Buildtools supports latex, platex, pdflatex, xelatex and lualate as engines.

The bigger the document to compile is, the longer the time needs.
Even if you change a small part of the document, it needs the same time as the big change.
You often need to compile to check how the pdf document looks like, which is sometimes called test, it needs long time in each compilation.
The bigger the document is, the more serious the problem is.
So, it has been thought up to compile a subfile itself without rootfile or other subfiles.

- Comment out the files in the argument list of `\includeonly` command which you don't want to compile.
- Use subfiles package.

Subfiles package is nice and many people recommend it.
However, you need to include the package and use its command appropriately.
Naturally, it is not the matter compared with the compilation time above.

Another way is to add an specific preamble to compile a subfile without any other files.
More specifically, the subfile is put between "the text from `\documentclass` to `\begin{document}`" and "`\end{document}`".
On that occasion, the subfile itself isn't changed, but another file, which contains the preamble, `\end{document}` and `\input` command, is made.
The `\input` command reads the subfile.
The file newly made is called "temporary rootfile".
On the other hand, the rootfile is sometimes called " original rootfile".
The preamble in the temporary rootfile is a copy of the preamble in the original rootfile.
The good point of this way is:

- There's no need to include any packages or put any special commands.
- Therefore, users don't need to install any packages when the source file is distributed.

The point is subfile can be compiled separately without any modification in the source files.
The generation of the temporary rootfile is the only necessary.
Buildtools has `ttex` shell script to do that.

#### Repeating compiling

It often needs to compile source files two times or more because of the cross-reference.
The repeating times are maybe two or three (or more), but I don't know the details.
However, there's a great software that calculate the repeating times automatically.
It is latexmk.
Latexmk make the build very easy.
Buildtools uses latexmk to compile rootfiles.

#### Build directory

Some people might complain about latex because it generates various of auxiliary files and log files.
If you make a build directory and put all the generated files into it, the source directory can be kept clean.
One of such program is cluttex and it is recommended to people who like cleanliness.

Buildtools makes a temporary directory, which is also called build directory, and put all the temporary files and generated document.
The default name of the directory is `_build`.
It makes the source directory keep clean.
If you want to see log or auxiliary files, search the build directory for them.
It's very simple.
Although it is superfluous to say so, meson build system which is very popular as a C build tool also uses build directory.
This shows us that separating build directory from source directory is very easy to understand.

Lb, one of the tools in Buildtools, generate a final pdf document in the build directory.
However, many users probably want to put it in the source directory.
It is a natural idea.
If you want to do so, use make or rake.

Rake is a similar program to make.
Its advantage is using ruby language in the Rakefile, which is the script file of rake.
Because ruby language is very strong and flexible, the script file can be readable and structured.

To get back to the subject how to put a final pdf document in the source directory, you just write a cp command in your Makefile or Rakefile to copy the pdf document under the build directory into source directory.
Furthermore, the advantage to use make or rake is that it's possible to specify preprocessing code in the Makefile or Rakefile.
Because preprocessing depends on the document and what tools the user choose, it's difficult for Buildtools to cover the preprocessing.
Compared with that, Makefile or Rakefile are really flexible so that you can write your own preprocessing in it.

It is recommended that users should use make or rake with Buildtools.

#### combination with Texworks

Lb, one of the tools in Buildtools, can either compile a rootfile or test-compile a subfile.
If you specify it into proccessing tools in the texworks dialog, you can run lb from texworks and it's so convenient.
Click edit, preference, then typesetting tab.
Click plus button in the processing tools part, then put `lb`, `lb`, `$fullname` in name, program and arguments box respectively.
Once you set it, you can compile a rootfile or test-compile a subfile by clicking on the typesetting icon (green triangle icon).

## Buildtools structure

Buildtools is made up of the following five parts.

- `newtex`: It generates source file templates. This is used at the beginning of making documents.
- `lb`: It calls latexmk or ttex to compile source files.
- `arl`: It makes an archive file.
- installer
- a group of utilities. They are used by the tools above.

The following shows the steps to build documents.

1. Make the structure, especially the chapters/sections, of the document..
2. Run newtex and make folders and templates of the document.
3. Modify the templates of Makefile, Rakefile, cover page (cover.tex) and preamble (cover.tex) if necessary.
4. Write the body of the document and test-compile.
5. If necessary, make script files for the preprocessing.
6. Compile the rootfile to generate the final pdf document.

The step three to five above are usually repeated and the process is not necessarily in the order above.

## Main tools

Each tool shows its help message if it is run with `--help` option.
For example, newtex shows the following message.

    $ newtex --help
    Usage:
      newtex --help
        Show this message.
      Newtex.conf needs to be edited before running newtex.
      newtex
        A directory is made and some template files are generated under the directory.

The document of each tool is:

- The help message shown by each command with `--help` option.
- The description below in this document.

No other document exists.
If you want to know more, see the source code.
All the tools in Buildtools are shell scripts.
If you are familiar to shell scripts, you can easily understand them because they are short.

#### newtex

    $ newtex

Newtex is used when you make a new latex document.
irst, decide the structure and chapters and make `newtex.conf` in advance.
This script makes a directory and generates template files according to `newtex.conf`.

1. There is `newtex.conf` file in the Buildtools source files.
Modify it to fit your environment and tex source files you will make.
2. Execute `newtex`.
Then it make a directory which name is the same as `title` in `newtex.conf`.
However, the space characters in the value of `title` is converted to underscore in the name of the directory.
The script also generates template files under the directory.

#### lb

    $ lb [LaTeXfile]

If the argument is left out, `lb` behaves as if `main.tex` is specified as an argument.
`Lb` is a script to build LaTeX source files and you usually don't need anything except it.

- If the argument is rootfile, then `lb` compiles it with `latexmk`. If the argument is subfile, then `lb` runs `ttex` specifying the subfile as an argument.
- If the argument is rootfile, `lb` compiles it without synctex.
- If the argument is subfile, `lb` runs `ttex` and `ttex` compiles the subfile with synctex.
After compilation, `lb` runs previewer specified in `lb.conf`.
- If there exists `lb.conf` in the current directory (it usually contains the rootfile), `lb` reads it and initialize some variables.
- If the variable `engine` in `lb.conf` is null string, then `lb` guesses an appropriate engine by itself.
However, it is recommended that you should specify the engine in `lb.conf`.

You can specify the default values in `lb.conf` to initialize some variables.

    rootfile=main.tex
    builddir=_build
    engine=
    latex_option=-halt-on-error
    preview=texworks

- `rootfile` is the name of the rootfile. If you specify the name of the rootfile as an argument to `lb`, then the argument takes precedence.
- `builddir` is the name of the build directory.
Auxiliary files and output files are put in the build directory.
If the argument of `lb` is a subfile, then the temporary rootfile is also put in the build directory.
If `builddir` is empty, then no temporary directory is generated and the source file directory becomes a build directory.
- `engine` is the name of a latex engine. `latex`, `platex`, `pdflatex`, `xelatex` and `lualatex` can be specified. Other engines are not supported.
- `latex_option` is a list of options to specify as an argument to the engine through `latexmk`. `-output-directory` is automatically given to `latexmk` by `lb` even if `lb.conf`doesn't exist.
- `preview` is the name of a pdf previewer to show the document. It is run only if the argument of `lb` is a subfile.

#### arl

    $ arl [-b|-g|-z] [rootfile]

The name `arl` comes from "ARchive LaTeX files".
It searches the rootfile for its related files (refer the following) and make an archive file.
If the argument is left out, then it runs as if `main.tex` is specified as an argument.

- If there are preprocessing programs, you need to execute them before running arl.
- Arl archives the latex source files and the graphic files included by `\includegraphics` command.
- Therefore, `Makefile` or the preprocessing script files are not archived.

It is a good way to make a target (for example, its name is 'ar') in Makefile and write a recipe to add Makefile and the preprocessing files into the archive file made by `arl`.
You can do the same thing with Rakefile.

There are options `-g`, `-b` and `-z` to compress the archive file into `tar.gz`, `tar.bz2` and `zip` file respectively.
If no option is given, `arl` just make a tarball without compression.

#### Utilities

You don't need to read this subsection except maintaining the scripts.

    $ srf subfile

This script `srf` searches for the rootfile of the given subfile and outputs its absolute path.
`srf` comes from "Search for Root File".

    $ tfiles [-p|-a|-i] [rootfile]

It outputs a list of subfiles of the given rootfile.
If the argument is left out, then it is run as if `main.tex` is specified as an argument.

- No option: It outputs a list of subfiles, specified from `\begin{document}` to `\end{document}`. They are the arguments of `\include` or `\input` command.
- `-p`: It outputs a list of subfiles specified with the `\input` commands in the preamble of the rootfile.
- `-a`: It outputs a list, outputted with no option, and the rootfile itself.
- `-i`: It outputs a list of subfiles specified with both `\include` and `\includeonly` command.

The files in the list are separated with new lines.

    $ tftype [-r|-s|-q] files ...

It outputs or returns the type of the given latex files.

- `-r`: It outputs rootfiles which is in the argument files. If no options are given, It behaves as if this option is specified.
- `-s`: It outputs subfiles which is in the argument files.
- `-q`: It doesn't output anything. The number of the argument must be one. It returns an exit status code of the file type.
If the code is 0 or 1, then the file is a rootfile or subfile respectively.
Otherwise an error happens.

Using `-q` option is the most common.

    $ gfiles files ...

The argument is a list of latex source files.
It outputs graphic files which are included by `\includegraphics` commands in the given files.

    $ ltxengine rootfile

It guesses a latex engine to compile the rootfile, although it is recommended that the engine should be specified by the user.
For example,

    \usepackage[luatex]{graphicx}

If this command exists in the preamble, it guesses that the engine is probably lualatex.

    $ ttex [-b builddir] -e latex_engine [-p dvipdf] [-v previewr] -r rootfile subfile

It generates a temporary rootfile of the subfile and compile it.
The compilation is done only once.
Therefore, no cross-reference is carried out.
This comes from the idea that `ttex` is a script for test to see how the pdf file looks like and cross-reference is not so important.
The cross-reference to the other files doesn't work neither.
This script can be run directly on the command line, but usually it is called by `lb`.
The following shows the options.

- `-b`: Specify a build directory. The default is `_build`.
- `-e`: Specify a latex engine. There is no restriction on the engine, but it assumes that latex, platex, pdflatex, xelatex or lualatex is specified.
- `-p`: Specify an application that translates dvi into pdf. This is used only when the engine is latex or platex, because they outputs a dvi file.
The default is dvipdfmx.
Other possible application is dvipdfm and dvipdf.
- `-v`: Specify a pdf previewer like evince.
If you edit the source file with texworks, it is a good idea to specify texworks here.
- `-r`: Specify the original rootfile.

## Installation and uninstallation

#### Prerequisite

- Linux and bash:
It is tested on Debian and Ubuntu.
However, it probably works on other linux distributions.
Bash is required because this script includes bash commands.

- LaTeX:
There are two options to install LaTeX.
One is installing the LaTeX applications provided by your distribution.
The other is installing TexLive.

- make or rake:
These applications are not necessarily required to run the tools in Buildtools.
However, it is recommended that they are used under the control of make or rake.
You don't need to install both of them.
Choose one which you like.
Make is a traditional build tool originally aimed at C compiler.
Rake is a build tool similar to make.
It is one of the ruby application.
The advantage to use rake is that you can put any ruby codes into Rakefile, which is the script file of rake.
Generally speaking, Rakefile is easy to understand than Makefile.

#### Installation

Use the script install.sh.

    $ bash install.sh

This script installs the executable files into `$HOME/bin`.
Debian and Ubuntu adds the directory `$HOME/bin` into `PATH` environment variable if it exists at the login time.
The script makes the directory `$HOME/bin` if it doesn't exist.
In that case, you need to re-login to put the directory into the `PATH` environment variable.
If you run `sudo` or `su` to become the root user before the installation, the executable files are put into `/user/local/bin`.

If your OS is debian, type the following to be the root user.

    $ su -
    # bash install.sh

Or if it's ubuntu,

    $ sudo bash install.sh

#### Uninstallation

Use the script uninstall.sh.

    $ bash uninstall.sh

If you run this as a user, the files under `$HOME` are removed.
If you run this as a root, the files under `/usr/local` are removed.
If your OS is debian, type the following to be the root user.

    $ su -
    # bash uninstall.sh

Or if it's ubuntu,

    $ sudo bash uninstall.sh

## licence

Copyright (C) 2020  ToshioCP (Toshio Sekiya)

Buildtools is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

Buildtools is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the [GNU Lesser General Public License](https://www.gnu.org/licenses/gpl-3.0.html) for more details.

