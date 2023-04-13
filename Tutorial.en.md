# Installation

The followings are required for LaTex-Buildtools.

- Ruby
- LualateX
- Lbt (lbt is Latex-Buildtools)

The first can be installed from the distribution package.
For example, You can use the apt command with Ubuntu.

Lbt is provided as a Ruby Gem.
It can be installed with the `gem` command.

~~~
$ gem install lbt
~~~

# Creating a directory and templates for source files

The rest of this tutorial shows an example of using Lbt.
Its source file is this tutorial.

First, use a `new` subcommand to create a directory and templates for source files.
The `new` subcommand takes the directory name, document class name, and working directory name as arguments.
The last two arguments can be left out.
Their default values are book and \_build respectively.
In this example, we use `ltjsarticle` document class.

~~~
$ lbt new Tutorial ltjsarticle
$ cd Tutorial
$ ls -a
. .. .config helper.tex main.tex
~~~

The working directory name is written in the `.config` file.

~~~
$ cat .config
build_dir = _build
~~~

Since the working directory name was left out, it is \_build (default value).
It is used when `build` and `part_typeset` subcommands are executed.

The file `main.tex` is the route file of LaTeX sources.

~~~
$ cat main.tex
\documentclass{ltjsarticle}
\input{helper.tex}
\title{Title}
\author{Author}
\begin{document}
\maketitle
\tableofcontents

\end{document}
~~~

The title and the author need to rewrite.
They are changed to "Tutorial" and "Toshio Sekiya" respectively.

The file `helper.tex` is included into the preamble part of `main.tex`.
Its contents are mainly package including and command definitions.

~~~
$ cat helper.tex
\usepackage{amsmath,amssymb}
\usepackage[luatex]{graphicx}
\usepackage{tikz}
\usepackage[margin=2.4cm]{geometry}
\usepackage[colorlinks=true,linkcolor=black]{hyperref}
% If your source includes Markdown, you may need the following lines.
% It is because Pandoc generates some undefined commands.
% The Pandoc template file shows how to define them.
% You can see it by 'pandoc --print-default-template=latex'.
\providecommand{\tightlist}{%
  \setlength{\itemsep}{0pt}\setlength{\parskip}{0pt}}
~~~

Since we don't need tikz package in this example, it can be deleted.
But you can leave it if you want.
The last two lines are required when converting Markdown files to LaTeX files with Pandoc.
The source, which is this tutorial, is Markdown, so we will leave them.

# Creating sub files

This tutorial has six sections.
We divide it into six files sec1.md, sec2.md, ... and sec6.md
They are put under the top directory.

# Typesetting

Converting LaTeX source files into a PDF file is called typesetting.
You can typeset them with `build` subcommand of Lbt.

~~~
$ lbt build
~~~

There are many converting processes.
Finally a PDF file `Tutorial.pdf` is made in the top directory.
The name of the PDF file is the same as the title in the source file.

# Partial typesetting

The bigger are the LaTeX sources, the longer time the typesetting takes.
Even if your modification is in only one, `build` subcommand converts all the source files.
It takes long time.
The subcommand `part_typeset` provides one file typesetting.
So it is faster than `build` subcommand.

~~~
$ lbt part_typeset 1
~~~

The argument `1` means `sec1.md`.
If you want to type sec5.md, use 5 instead of 1.

For large documents with parts and chapters, for example, specify "1-2-4" for part1/chap2/sec4.tex.

# Renumbering

Sometimes you may want to insert a section between sec1.md and sec2.md.
At that time, name it sec1.5.md.
If you want to renamed these (sec1.md, sec1.5.md and sec2.md) into consecutive number filenames (sec1.md, sec2.md, and sec3.md), use `renum` subcommand.

~~~
$ lbt renum
~~~