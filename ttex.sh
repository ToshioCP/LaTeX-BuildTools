#! /bin/bash

# ttex (test tex script ... script to test tex sub file)
# If you compile LaTeX root file with all the subfiles, it takes quite long time.
# This script makes temporary root file to test the given subfile.
# First search its root file and copy its preamble and \begin{document} to the temporary root file,
# then adds \mainmatter if necessary, and finally adds \input{subfile} and \end{document} at the end of the temporary root file.
# Then, invoke a latex engine to compile the temporary root file.
# This is quick and reasonable if you just want to test a subfile.

# ルートファイル・・コンパイル対象のサブファイルのルートファイル（デフォルトmain.tex）
# テンポラリ・ルートファイルは_buildの中に生成される。サブファイルのテスト用のファイルである
# ttexはテンポラリ・ルートファイルをコンパイルする。サブファイルはテンポラリ・ルートファイルから呼び出される。
# エンジンのカレントディレクトリはルートファイル（テンポラリでない）のディレクトリである
# すべてのパス名は（ルートファイルの存在するディレクトリからの）相対ディレクトリでなければならない
# それは、テンポラリ・ルートファイルからの相対ディレクトリではないことに注意

usage () {
  echo "Usage : ttex [-b builddir] -e latex_engine [-p dvipdf] [-v previewr] -r rootfile subfile" 1>&2
  exit 1
}

# main routine

if [[ $1 == "-b" ]]; then
  shift
  builddir=$1
  shift
else
  builddir=
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
  temprfile=test$(basename "$subfile")
fi
cat "$rootfile" | sed -nE '/\\documentclass/,/\\begin\{document\}/p' > "$temprfile"
if [[ -n $(grep -E '\\documentclass.*\{book\}' "$temprfile") ]]; then
  echo \\mainmatter >> "$temprfile"
#  echo "\\chapter{Test pdf result of $(echo "$subfile" |p2t)}" >> "$temprfile"
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
