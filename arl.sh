#! /bin/bash

# archive LaTeX source

usage() {
  echo "Usage: arl [-b|-g|-z] [LaTeXrootfile]" 1>&2
  echo "option:" 1>&2
  echo "  -b:     compress the archive file into a bzip2 file" 1>&2
  echo "  -g:     compress the archive file into a gzip file" 1>&2
  echo "  -z:     compress the archive file into a zip file" 1>&2
  exit 1
}

IFS=$'\n'

if [[ $1 == "--help" ]]; then
  usage
fi

if [[ $1 =~ ^-[bgz]$ ]]; then
  opt=$1
  shift
fi
if [[ $# -eq 0 ]]; then
  rootfile=main.tex
elif [[ $# -eq 1 ]]; then
  rootfile=$(echo "$1" | sed 's/\.tex$//').tex
else
  usage
fi

dname=$(dirname "$rootfile")
bname=$(basename "$rootfile")
cd "$dname"

bodyname=$(echo "$bname" | sed 's/\..*$//')
arname=${bodyname}.tar

texfiles=$(tfiles -a "$bname")
preamblefiles=$(tfiles -p "$bname")
graphicfiles=$(gfiles $texfiles)
if [[ -z graphicfiles ]]; then
  files="$texfiles"$'\n'"$preamblefiles"
else
  files="$texfiles"$'\n'"$preamblefiles"$'\n'"$graphicfiles"
fi

case "$opt" in
  -b) tar -cjf $arname.bz2 $files;;
  -g) tar -czf $arname.gz $files;;
  -z) zip $bodyname.zip $files;;
  *) tar -cf $arname $files;;
esac

