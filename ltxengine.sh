#! /bin/bash

usage() {
  echo "Usage: ltxengine rootfile" 1>&2
  exit 1
}

IFS=$'\n'

if [[ $1 == "--help" ]]; then
  usage
fi
if [[ $# -ne 1 ]]; then
  usage
fi

rootfile=$(echo "$1" | sed 's/.tex$//').tex
texfiles_preamble=$(tfiles -p "$rootfile")

# check the magic comment
# ERE
pattern_tw_prog='^ *% *!TeX +program *= *([^ ]+) *$'
engine=$(cat "$rootfile" |
  grep -E "$pattern_tw_prog" |
  sed -E "s/$pattern_tw_prog/\1/")
if [[ -n $engine ]]; then
  echo "$engine"
  exit
fi

engine=pdflatex # default engine
documentclass=$(cat "$rootfile" |
  sed 's/%.*$//' |
  sed -nE '/\\begin\{verbatim\}/,/\\end\{verbatim\}/! p' |
  grep \\documentclass)
option=$(echo "$documentclass" | grep '\[' | sed -E 's/^ *\\documentclass\[(.*)]\{([^}]*)\}.*$/\1/')
dcname=$(echo "$documentclass" | sed -E 's/^.*\\documentclass.*\{([^}]*)\}.*$/\1/')
packages=$(cat "$rootfile" $texfiles_preamble |
  sed 's/%.*$//' |
  sed -nE '/\\begin\{verbatim\}/,/\\end\{verbatim\}/! p' |
  grep "\\usepackage")
driver=$(echo "$packages" |
  grep -E "\\usepackage\[.*\]\{graphicx\}" |
  sed -E 's/^.*\\usepackage\[([^]]*)\]\{graphicx\}.*$/\1/')
luatexja=$(echo $packages | grep -E "\\usepackage\{luatexja\}")
if [[ $dcname =~ ^(article|book|letter|report|slides|beamer)$ ]]; then
  if [[ $driver =~ dvipdfmx? ]]; then
    engine=latex
  elif [[ $driver == pdftex ]]; then
    engine=pdflatex
  elif [[ $driver == luatex ]]; then
    engine=lualatex
  else
    engine=pdflatex #default
  fi
  if [[ -n $luatexja ]]; then
    engine=lualatex
  fi
elif [[ $dcname =~ ^ltjs.*$ ]]; then
  engine=lualatex
elif [[ $dcname =~ ^j.*$ ]]; then
  engine=platex
fi
echo $engine

