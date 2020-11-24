#! /bin/bash

# ttex is a script to test tex subfile.
# If you compile LaTeX root file with all the subfiles, it takes quite long time.
# This script makes temporary rootfile to test the given subfile.
# First, copy preamble and \begin{document} in the rootfile to the temporary rootfile.
# Then adds \mainmatter if necessary, and finally adds \input{subfile} and \end{document} at the end of the temporary rootfile.
# Then, invoke a latex engine to compile the temporary rootfile.

# ttexという名前はtest tex scriptから来ており、す部ファイルをテストするスクリプトである。
# もしも、サブファイルをテストするために、ルートファイルとすべてのサブファイルをコンパイルするのはかなり時間がかかる。
# ttexは与えられたサブファイルをテストするために、テンポラリ・ルートファイル作成する。
# はじめに、ルートファイルのプリアンブルと\begin{document}をテンポラリ・ルートファイルにコピーする。
# そして、必要ならば\mainmatterを加え、最後に\input{subfile}と\end{document}をテンポラリ・ルートファイルの最後に付け加える。
# 次にテンポラリ・ルートファイルをlatexエンジンでコンパイルする。

usage () {
  echo "Usage : ttex [-b builddir] -e latex_engine [-p dvipdf] [-v previewr] -r rootfile subfile" 1>&2
  exit 1
}

# main routine

if [[ $1 == "-b" ]]; then
  shift
  builddir=$1
  shift
fi
if [[ $1 == "-e" ]]; then
  shift
  engine=$1
  shift
else
  usage
fi
if [[ ! $engine =~ ^(pdflatex|lualatex|xelatex|latex|platex)$ ]]; then
  echo "Unknown latex engine: $engine" 1>&2
  exit 1
fi
if [[ $1 == "-p" ]]; then
  shift
  dvipdf=$1
  shift
else
  dvipdf=dvipdfmx #default
fi
if [[ $1 == "-v" ]]; then
  shift
  previewer=$1
  shift
fi
if [[ $1 == "-r" ]]; then
  shift
  rootfile=$(echo "$1" | sed 's/\.tex$//').tex
  shift
else
  usage
fi
if [[ $# -eq 1 ]]; then
  subfile=$(echo "$1" | sed 's/\.tex$//').tex
else
  usage
fi

if [[ ! -f $rootfile ]]; then
  echo "ttex: No such file: $rootfile" 1<&2
  exit 1
fi
if [[ ! -f $subfile ]]; then
  echo "ttex: No such file: $subfile" 1<&2
  exit 1
fi

if [[ -n $builddir ]]; then
  temprfile=$builddir/test_$(basename "$subfile")
else
  temprfile=test_$(basename "$subfile")
fi
cat "$rootfile" | sed -nE '/\\documentclass/,/\\begin\{document\}/p' > "$temprfile"
if [[ -n $(grep -E '\\documentclass.*\{book\}' "$temprfile") ]]; then
  echo \\mainmatter >> "$temprfile"
fi
echo "\\input{$subfile}" >> "$temprfile"
echo "\\end{document}" >> "$temprfile"

option="-synctex=1--halt-on-error"
if [[ -n $builddir ]]; then
  option="$option -output-directory $builddir"
fi
if [[ $engine == "lualatex" ]]; then
  option=$(echo "$option" | sed 's/ -/ --/g')
fi

$engine $option "$temprfile"
if [[ $engine =~ ^(latex|platex)$ ]]; then
  $dvipdf $(echo "$temprfile" | sed 's/\.tex$//').dvi
fi
if [[ -n $previewer ]]; then
  $previewer $(echo "$temprfile" | sed 's/\.tex$/.pdf/') >/dev/null 2>&1 &
fi
