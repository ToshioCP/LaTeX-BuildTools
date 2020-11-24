#!/bin/bash

# gfiles
#
# Find the graphics file that is included by the LaTeX source file given as arguments.
#
# 引数で与えられたLaTeXソースファイルによって取り込まれる画像ファイル名を出力する。

usage() {
  echo "Usage: gfiles LaTeXfiles ..." 1>&2
  echo "       gfiles --help" 1>&2
  echo "   gfiles outputs the graphic files included by the LaTeXfiles." 1>&2
  echo "   When --help option is given, gfiles shows this help message." 1>&2
  exit 1
}

if [[ $# -eq 0 ]]; then
  usage
fi
if [[ $1 == "--help" ]]; then
  usage
fi

gfiles=
while [[ $# -gt 0 ]]; do
  texfile=$(echo "$1" | sed 's/\.tex$//').tex
  gfile=$(cat "$texfile" |
    sed 's/%.*$//' |
    sed -nE '/\\begin\{verbatim\}/,/\\end\{verbatim\}/! p' |
    grep '\\includegraphics' |
# The following sed commands split LaTeX commands on the same line into different lines.
# ここのsedは同一行に複数のコマンドがあった場合にそれを別の行に分けて、次のsedの置換を助けるためのもの
    sed 's/\\includegraphics/\n\\includegraphics/g' |
    sed -nE '/\\includegraphics/ {s/^\\includegraphics *(\[[^]]*]|) *\{([^}]+)\}.*$/\2/; p}')
  if [[ -z $gfiles ]]; then
    gfiles="$gfile"
  else
    gfiles="$gfiles"$'\n'"$gfile"
  fi
  shift
done
gfiles=$(echo "$gfiles" | sort | uniq)
echo "$gfiles"
