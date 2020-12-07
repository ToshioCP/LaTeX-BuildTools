#! /bin/bash
#
# The script newtex reads newtex.conf first.
# Then,
# 1. It makes a directory and its name is the same as the document name you give in newtex.conf
# 2. Then, it generates template files under the directory. They are a rootfile, subfiles, helper.tex, cover.tex, gecko.png, Makefile, Rakefile and lb.conf.

# スクリプトnewtexは、まず、newtex.confを読み込む。そして、
# 1. 文書名（newtex.confの中で指定されたもの）と同じ名前のディレクトリを作る。
# 2. その後、そのディレクトリの下にテンプレート・ファイルを生成する。それらは、ルートファイル、サブファイル、helper.tex、cover.tex、gecko.png、Makefile、Rakefile、lb.confである。

usage() {
  echo "Usage:" 1>&2
  echo "  newtex --help" 1>&2
  echo "    Show this message." 1>&2
  echo "  Newtex.conf needs to be edited before running newtex." 1>&2
  echo "  newtex" 1>&2
  echo "    A directory is made and some template files are generated under the directory." 1>&2
  exit 1
}

declare -a buf key value # arrays
declare -i i j n # integers

# show help message
if [[ $1 == "--help" || $# != 0 || ! -f newtex.conf ]]; then
  usage
fi

i=0
j=0

mapfile -t buf <newtex.conf
n=${#buf[@]} # number of the elements in the array
for (( i=0 ; i<n ; i++ )) ; do
  s=$(printf "%s" "${buf[i]%%\#*}" | sed 's/^[[:space:]]*//;s/[[:space:]]*=[[:space:]]*/=/;s/[[:space:]]*$//') # remove comments, spaces at the top, end and around equal sign.
  pattern='^[_[:alpha:]][_[:alnum:]]*=.*$'
  if [[ $s =~ $pattern ]]; then
    key[j]=${s%%=*}
    value[j]=${s##*=}
    let j++
  fi
done

# required keys
keys="title rootfile builddir engine latex_option dvipdf preview documentclass"
# chapter/section
chapsec="chapter section"

# Check required keys
found=true
for x in $keys; do
  f=false
  for (( j=0 ; j<$n ; j++ )) ; do
    if [[ ${key[j]} == $x ]]; then
      f=true
      break;
    fi
  done
  if [[ $f == false ]]; then
    found=false
    break;
  fi
done
if [[ $found == false ]]; then
  echo "Key \"$x\" not found in newtex.conf." 1>&2
  exit 1
fi

# Check illegal keys
n=${#key[@]}
exist=true
for (( j=0 ; j<$n ; j++ )) ; do
  e=false
  for x in $keys $chapsec; do
    if [[ ${key[j]} == $x ]]; then
      e=true
      break;
    fi
  done
  if [[ $e == false ]]; then
    exist=false
    break;
  fi
done
if [[ $exist == false ]]; then
  echo "Key \"${key[j]}\" in newtex.conf is an illegal key." 1>&2
  exit 1
fi

# Now, the syntax in newtex.conf is OK.
# Get the values correspond to keys.
for x in $keys; do
  for (( j=0 ; j<$n ; j++ )) ; do
    if [[ $x == ${key[j]} ]]; then
      declare $x="$(printf "%s" "${value[j]}" | sed 's/^"//;s/"$//')"
    fi
  done
done

# Make a directory which name is value of title.
# How ever, if the name includes spaces, make cannot recognizes the directory correctly.
# It is a good way to substitute underscore for space character.
directory_name=$(printf "%s" "$title" | sed 's/ /_/g')
# The direcotry above and target file share the name which is the value of directory_name.

# Rootfile and builddir shouldn't have spaces for the same reason.
if [[ $rootfile =~ [[:space:]] ]]; then
  echo "Rootfile name cannot include space character." 1>&2
  exit 1
fi
if [[ $builddir =~ [[:space:]] ]]; then
  echo "Builddir name cannot include space character." 1>&2
  exit 1
fi
# The value of rootfile is the body of the filename of the rootfile.
# That means it doesn't have suffix (.tex).
rootfile=$(echo $rootfile | sed ' s/.tex$//')

if [[ -z "$title" ]]; then
  echo "Title is empty." 1>&2
  exit 1
elif [[ -d "$directory_name" ]]; then
  echo "Directory \"$directory_name\" has already existed. Change the title." 1>&2
  exit 1
else
  mkdir "$directory_name"
fi
cd "$directory_name"
  
# Make lb.conf
lb_keys="rootfile builddir engine latex_option dvipdf preview"
for x in $lb_keys; do
  echo "$x=${!x}" >> lb.conf
done

# Make Makefile
cat <<EOF >Makefile
#SHELL = /bin/bash

${directory_name}.pdf: ${builddir}/${rootfile}.pdf
	cp ${builddir}/${rootfile}.pdf ${directory_name}.pdf
${builddir}/${rootfile}.pdf: FORCE
	lb ${rootfile}.tex

FORCE:

.Phony: FORCE clean ar zip

clean:
	rm -rf ${builddir}
ar:
	arl ${rootfile}.tex
	tar -rf ${rootfile}.tar Makefile
	gzip ${rootfile}.tar
	mv ${rootfile}.tar.gz ${directory_name}.tar.gz
zip:
	arl -z ${rootfile}.tex
	zip ${rootfile}.zip Makefile
	mv ${rootfile}.zip ${directory_name}.zip
EOF

#Make Rakefile
cat <<EOF >Rakefile
require 'rake/clean'

# use Latex-BuildTools
@tex_files = (\`tfiles -a\` + \`tfiles -p\`).split("\n")
@graphic_files = []
@tex_files.each do |file|
  @graphic_files += \`gfiles #{file}\`.split("\n")
end

task default: "${directory_name}.pdf"

file "${directory_name}.pdf" => "${builddir}/${rootfile}.pdf" do
  sh "cp ${builddir}/${rootfile}.pdf ${directory_name}.pdf"
end

file "${builddir}/${rootfile}.pdf" => (@tex_files+@graphic_files) do
  sh "lb ${rootfile}.tex"
end

CLEAN << "${builddir}"
task :clean

task :ar do
  sh "arl ${rootfile}.tex"
  sh "tar -rf ${rootfile}.tar Rakefile"
  sh "gzip ${rootfile}.tar"
  sh "mv ${rootfile}.tar.gz ${directory_name}.tar.gz"
end

task :zip do
  sh "arl -z ${rootfile}.tex"
  sh "zip ${rootfile}.zip Rakefile"
  sh "mv ${rootfile}.zip ${directory_name}.zip"
end
EOF

# Make cover.tex
cat <<EOF >cover.tex
\begin{center}
\begin{tikzpicture}
  \node at (0,0) {\includegraphics[width=100pt]{gecko.png}};
  \node at (70pt,0) {\includegraphics[width=100pt]{gecko.png}};
  \node at (140pt,0) {\includegraphics[width=100pt]{gecko.png}};
  \node at (210pt,0) {\includegraphics[width=100pt]{gecko.png}};
  \node at (280pt,0) {\includegraphics[width=100pt]{gecko.png}};
  \node at (350pt,0) {\includegraphics[width=100pt]{gecko.png}};
\end{tikzpicture}
\end{center}

\vspace{2cm}
\begin{center}
{\fontsize{64}{0} \selectfont ${title}
\end{center}
\vspace{1cm}
\begin{center}
{\huge Author}
\end{center}
\vspace{6.5cm}
\begin{center}
{\Large Foobar University}
\end{center}
\begin{center}
{\Large School of Foobar}
\end{center}

\vspace{3cm}
\begin{center}
\begin{tikzpicture}
  \node at (0,0) {\includegraphics[width=100pt]{gecko.png}};
  \node at (70pt,0) {\includegraphics[width=100pt]{gecko.png}};
  \node at (140pt,0) {\includegraphics[width=100pt]{gecko.png}};
  \node at (210pt,0) {\includegraphics[width=100pt]{gecko.png}};
  \node at (280pt,0) {\includegraphics[width=100pt]{gecko.png}};
  \node at (350pt,0) {\includegraphics[width=100pt]{gecko.png}};
\end{tikzpicture}
\end{center}
EOF

# Make helper.tex
if [[ $engine == pdflatex ]]; then
  driver=pdftex
elif [[ $engine == lualatex ]]; then
  driver=luatex
elif [[ $engine == xelatex ]]; then
  driver=xetex
elif [[ $engine == latex || $engine == platex ]]; then
  if [[ $dvipdf == dvipdf ]]; then
    driver=dvipdf
  elif [[ $dvipdf == dvipdfm ]]; then
    driver=dvipdfm
  elif [[ $dvipdf == dvipdfmx ]]; then
    driver=dvipdfmx
  else
    driver=dvips
  fi
fi

# It is a good idea that you make your own helper.tex and substitute it for this file.
# Another good idea is to modify the follwing here document to adapt your tex style.

cat <<EOF >helper.tex
% Helper.tex is a tex file included into the preamble in the rootfile.
% This file contails mainly \usepackage commands and \newcommand commands.
% You need to rewrite this file to fit your tex file.

% Packages
\usepackage{amsmath,amssymb}
\usepackage[${driver}]{graphicx}
\usepackage{tikz}
%\usetikzlibrary{calc}

%\usepackage{fancybox}
\usepackage{booktabs}

%\usepackage[margin=2.4cm]{geometry}

\usepackage[colorlinks=true,linkcolor=black]{hyperref}

% Sample macro for English
%\newcommand{\solution}{\begin{flushleft}\textbf{Solution:}\end{flushleft}}
%\newcommand{\proof}{\begin{flushleft}\textbf{Proof}\end{flushleft}}
%\newcommand{\qed}{\begin{flushright}\textbf{q. e. d.}\end{flushright}}
%\newcommand{\answer}[1]{\begin{flushleft}\textbf{Exercise~\ref{#1}}\end{flushleft}}

% Theorem environment.
%\newtheorem{theorem}{Theorem}[section]
%\newtheorem{lemma}{Lemma}[section]
%\newtheorem{corollary}{Corollary}[section]
%\newtheorem{definition}{Definition}[section]
%\newtheorem{example}{Example}[section]
%\newtheorem{exercise}{Exercise}[section]

% Sample macro for Japanese
% マクロのサンプル（解答、証明、q.e.d.、解答）
%\newcommand{\solution}{\begin{flushleft}\textbf{解:}\end{flushleft}}
%\newcommand{\proof}{\begin{flushleft}\textbf{証明}\end{flushleft}}
%\newcommand{\qed}{\begin{flushright}\textbf{証明終}\end{flushright}}

% 定理環境（定理、補題、系、定義、例、練習問題）
%\newtheorem{theorem}{定理}[section]
%\newtheorem{lemma}{補題}[section]
%\newtheorem{corollary}{系}[section]
%\newtheorem{definition}{定義}[section]
%\newtheorem{example}{例}[section]
%\newtheorem{exercise}{問題}[section]

% 凹凸増減表の矢印 ----------------------------------------------------------------------------
% concave north east arrow 上に凸で増加
%\newcommand{\ccnearrow}{
%\begin{tikzpicture}
%  \draw[very thin,->] (0,0) .. controls (0,0.2) and (0.05,0.25) .. (0.25,0.25);
%\end{tikzpicture}
%}
% concave south east arrow 上に凸で減少
%\newcommand{\ccsearrow}{
%\begin{tikzpicture}
%  \draw[very thin,->] (0,0) .. controls (0.2,0) and (0.25,-0.05) .. (0.25,-0.25);
%\end{tikzpicture}
%}
% convex north east arrow 下に凸で増加
%\newcommand{\cvnearrow}{
%\begin{tikzpicture}
%  \draw[very thin,->] (0,0) .. controls (0.2,0) and (0.25,0.05) .. (0.25,0.25);
%\end{tikzpicture}
%}
% convex south east arrow 下に凸で減少
%\newcommand{\cvsearrow}{
%\begin{tikzpicture}
%  \draw[very thin,->] (0,0) .. controls (0,-0.2) and (0.05,-0.25) .. (0.25,-0.25);
%\end{tikzpicture}
%}
%-----------------------------------------------------------------------------------------------
EOF

# Make rootfile
cat <<EOF >> ${rootfile}.tex
\documentclass{$documentclass}
\input{helper.tex}
\title{$title}
\author{} % Write your name if necessary.
\begin{document}
EOF

if [[ $documentclass == beamer ]]; then
  echo >> ${rootfile}.tex # nothing
elif [[ $documentclass == book || $documentclass == jbook || $documentclass == jsbook || $documentclass == ltjsbook ]]; then

cat <<EOF >> ${rootfile}.tex
\frontmatter
\begin{titlepage}
\input{cover.tex}
\end{titlepage}
\tableofcontents
\mainmatter
EOF

else # article, report

cat <<EOF >> ${rootfile}.tex
\maketitle
% If you want a table of contents here, uncomment the following line.
%\tableofcontents
EOF

fi

echo >> ${rootfile}.tex
for (( j=0 ; j<$n ; j++ )) ; do
  name=${value[j]#\"}
  name=${name%%\"*}
  file=${value[j]%\"}
  file=${file##*\"}
  if [[ ${key[j]} == chapter ]]; then
    echo "\\chapter{$name}" >> ${rootfile}.tex
    echo "  \\input{${file}.tex}" >> ${rootfile}.tex
    touch ${file}.tex
  elif [[ ${key[j]} == section ]]; then
    echo "\\section{$name}" >> ${rootfile}.tex
    echo "  \\input{${file}.tex}" >> ${rootfile}.tex
    touch ${file}.tex
  fi
done

echo "\\end{document}" >> ${rootfile}.tex

# generate gecko.png
base64 -d <<EOF >gecko.png
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
AAAASUVORK5CYII=
EOF
