日本語の"Readme.ja.md"があります。

# Latex-Buildtools

The current version is written in ruby. Old bash version has been moved to the bash branch.

### Background

It gets more difficult to create and maintain a document if it becomes larger.
The same goes to LaTeX.
The followings are some solutions to avoid such difficulties.

- Splitting and organizing source files
- individual typesetting
- Preprocessing

Buildtools is a set of tools that supports them.

### Source file splitting and organising

It is appropriate to organize a book into parts, chapters, sections if it has more than 300 pages.
LaTeX has commands of part, chapter, section, subsection and subsubsection.
It is good to divide a file into each section.
Part and chapter will be directories.
Subsection and subsubsection will be described in the section file.

| Part-Subsubsection | Directory/File |
|:------:|:-----------:|
| Part |  directory |
| Chapter | directory |
| Section |  file |
| Subsection |  in a section file |
| Subsubsection |  in a section file |

This can be expressed in the directory structure as follows, for example.

~~~
--+-- part1 --+-- chap1 --+-- sec1
  |           |           +-- sec2
  |           +-- chap2 ----- sec1
  +-- part2 --+-- chap1 --+-- sec1
              |           +-- sec2
              +-- chap2 ----- sec1
~~~

If a book has about 100 pages, it doesn't need any parts.
In that case, the structure becomes as follows.

~~~
--+-- chap1 --+-- sec1
  |           +-- sec2
  |           +-- sec3
  +-- chap1 --+-- sec1
              +-- sec2
              +-- sec3
~~~

For smaller documents, section is enough.

~~~
--+-- sec1
  +-- sec2
  +-- sec3
  +-- sec4
  +-- sec5
~~~

These structures depend on the size of the documents.
In the above figure, the file extension is omitted.

There are advantages and disadvantages to limiting the directory/file names to part1, chap2 and sec1 (sec1.tex etc. if you add an extension).
The advantage is that the order of the files is clear and the program can easily find the file.
The disadvantage is that the contents of the file cannot be known from the file name.
In Buildtools, the former is taken more important and the file are named to part, chap and sec.

The above files are called subfiles.
Subfiles are included from the root file.
The program automatically makes these connections, so the user does not have to write the \\input{} commands in the tex source files.

Files other than the sec files can be placed anywhere, but it's a good idea to put all the image files together in one directory.

~~~
--+-- part1 --+-- chap1 --+-- sec1
  |           |           +-- sec2
  |           +-- chap2 ----- sec1
  +-- part2 --+-- chap1 --+-- sec1
  +           |           +-- sec2
  +           +-- chap2 ----- sec1
  +-- image --+-- photo.jpg
              +-- diagram.png
              +-- sample.png
~~~

When including these files from the body files, refer to them by the relative path from the top directory.

~~~
\includegraphics{image/photo.jpg}
~~~

This means:

- You don't need to change the pathnames in the \\input or \\includegraphics commands even if the body file moves across chaps and parts.
- Lualatex recognizes the relative paths correctly when its current directory is located to the top directory.

### Typeset

Compiling source files with lualatex is called a "typeset".
The typeset requires lualatex to be run more than once for cross-references.
There is a program called latexmk that manages it.
Buildtools uses latexmk.
Thanks to that, the user does not have to run lualatex multiple times.
Just type:

~~~
$ rake
~~~

After that, the typeset is done automatically.

Typeset take time for large documents.
It's a waste of time to typeset an entire document to see minor corrections.
In that case, use the part_typeset command.
This is a program that typesets only one subfile.
However, section and cross-reference numbers are not reflected correctly.
It is for confirmation only.

~~~
$ part_typeset 1-1-1
~~~

This command typessets only the file part1/chap1/sec1.
If there is no part and only chap and sec, for example, "part_typeset 1-2" will typeset the chap1/sec2 file.
Typesetting only one file in this way is called a partial typeset.

There is a directory 'example', where you can try the rake command.

The typeset produces various intermediate files.
These are stored in the _build directory.
When you want to delete the intermediate files, type as follows.

~~~
$ rake clean
~~~

If you want to delete the target pdf file as well, then type:

~~~
4 rake clobber
~~~

### Preprocessing

Preprocessing is executed before the typeset.
For example, converting a markdown file to a LaTeX file is preprocessing.

~~~
sec1.md == (pandoc) ==> sec1.tex == (lualatex) ==> XXX.pdf
~~~

Pandoc is a program that converts one document to another type document..

~~~
https://pandoc.org/
~~~

Since the preprocessing is done automatically, the only thing users need to do is putting the extension to the source file.
For example, put '.md' to a markdown file sec1.

Users can add their own preprocessing program.
For example, suppose that you want to add a new extension ".src.tex" and transfer "m(1,2,3,4)" into bmatrix environment.

~~~
\begin{bmatrix}1&2\\3&4\end{bmatrix}
~~~

You can do this with ruby's gsub or gsub! methods.
The preprocessing created by the user is described in a file called "converter.rb" and placed in the top directory.

~~~
{ :'.src.tex' => lambda do |src, dst|
    buf = File.read(src)
    buf = buf.split(/(\\begin\{verbatim\}.*?\\end\{verbatim\}\n)/m)
    buf = buf.map do |s|
      s.match?(/^\\begin\{verbatim\}/) ? s : s.split(/(%.*$)/)
    end
    buf = buf.flatten
    buf.each do |s|
      unless s.match?(/^\\begin\{verbatim\}/) || s.match?(/^%/)
        s.gsub!(/m\((\d),(\d),(\d),(\d)\)/) {"\\begin{bmatrix}#{$1}&#{$2}\\\\#{$3}&#{$4}\\end{bmatrix}"}
      end
    end
    File.write(dst, buf.join)
  end }
~~~

From the 3rd line to the 7th line, the verbatim environment, the comment part and the other parts are separated.
In the 9th line, lines without verbatim and comments are selected.
The conversion is performed in the 10th line.
Various conversions are possible by customizing the 10th line.
Note that the conversion will not be reflected if gsub is used instead of gsub! (With an exclamation mark).

The converted files are saved in the `_build` directory which is just under the top directory.
Thanks to putting `_build` under the top directory, the relative paths in files are always correct.

The contents of the converter.rb are executed without being checked by the program.
If there is an error in it, it may cause a serious damage.
Therefore, it is recommended to backup the files in advance.
Also, it is very dangerous to execute a program created by another person without checking its contents.
Make a converter after you fully understand these risks.

Extensions of files here are a bit different from common definitions.
Since the extension is the part after the last dot of the file name, the extension of "abc.de.fg" is ".fg", not ".de.fg".
However, this system exceptionally treats ".src.tex" as an extension.
There are two such exceptions, ".src.tex" and ".src.md".
For example, the extension of "sec2.5.src.tex" is ".src.tex", not ".5.src.tex" or ".tex".
The "get_suffix" method takes a file name as an argument and returns its extension (correct extension including exceptions).

### Initialization

If you want to create a new document, use newtex.
Newtex makes a new directory and initializes it.
The directory contains templates.

~~~
$ ls
Rakefile  cover.tex  gecko.png  helper.tex  main.tex
~~~

In most cases, the Rakefile works.
It rarely needs to be rewritten.

- cover.tex is the source file of a cover page.
This file is not needed if you use the \\maketitile command.
- gecko.png is an image file of a gecko used in cover.tex.
You can also modify cover.tex to use another image file.
- helper.tex is part of the preamble.
It mainly includes packages and define macros (\\newcommand etc).
- main.tex is the root file. You don't have to write the \\input{} commands to i subfiles.
Importing is done automatically.

If you want to create your own converter, put a file named "converter.rb" in this directory.

If your document is large, create a part-chap-sec directories/files, and if it is small, write only sec files in the top directory.

### Insert and renumber files

If you want to put a new sec file between sec1 and sec2, create a file with any number between 1 and 2.
For example, name the file "sec1.5".
You can leave it as it is, but if you want to change the file numbers to 1,2,3,4 ..., use the renumber command.

~~~
$ renumber
~~~

This makes:

~~~
sec1.tex => sec1.tex
sec1.5.tex => sec2.tex
sec2.tex => sec3.tex
~~~

### Archive

The document can be archived after you finish your work.

~~~
$ arch_tex -b
~~~

This will archive all documents and Rakefile, lib_latex_utils.rb, converter.rb into a bzip2 file.
At this time, readme.md, which is a brief explanation file, is also included.
People who get the archive do not need Buildtools.
All they need is a program to unzip the archive and ruby ​​environment.

You can choose a compression converter by giving an option to arch_tex.
Three compression types are supprted.

- -b: bzip2
- -g: gzip
- -z: zip

### Install and uninstall

You need ruby ​​and tex environment.
Ruby 3.1 is used to develop Buildtools, but it may work even if the ruby version is ​​2.0 or later.
Texlive is recommended for the tex environment.

The TeX engine is lualatex.
If you want to use another engine, Modify Rakefile.
Only a small modification is enough.

Linux was the OS to develop Buildtools, but I think that it will also work on Windows.

To install, tyoe as follows for Linux

~~~
$ ruby ​​install.rb
~~~

The executable file is copied into `$HOME/bin`.
At the time of installation, newtex and arch_tex are rewritten.

Uninstall:

~~~
$ ruby ​​install.rb-
~~~

### licence

Copyright (C) 2022  ToshioCP (Toshio Sekiya)

Buildtools is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

Buildtools is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the [GNU General Public License](https://www.gnu.org/licenses/gpl-3.0.html) for more details.
