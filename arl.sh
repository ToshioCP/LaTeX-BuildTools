#! /bin/bash

# archive LaTeX source

IFS=$'\n'

if [[ $1 =~ ^-[bz]$ ]]; then
  opt=$1
  shift
fi
if [[ $# -eq 0 ]]; then
  rootfile=main.tex
elif [[ $# -eq 1 ]]; then
  rootfile=$(echo "$1" | sed 's/\.tex$//').tex
else
  echo "Usage : arl [-b|-z] [LaTeXrootfile]" 1>&2
  exit 1
fi
dname=$(dirname "$rootfile")
bname=$(basename "$rootfile")
cd "$dname"

bodyname=$(echo "$bname" | sed 's/\..*$//')
arname=${bodyname}.tar

texfiles=$(tfiles -a "$bname")
graphicfiles=$(gfiles "$texfiles")
if [[ -z graphicfiles ]]; then
  files="$texfiles"
else
  files="$texfiles"$'\n'"$graphicfiles"
fi

if [[ $opt == "-b" ]]; then
  tar -cjf $arname.bz2 $files
elif [[ $opt == "-z" ]]; then
  zip $bodyname.zip $files
else
  tar -czf $arname.gz $files
fi

