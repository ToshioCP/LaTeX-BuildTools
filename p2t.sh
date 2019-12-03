#!/bin/bash

# plain to tex
# This is a filter program to replace the special charactors with latex format.
#  # => \#
#  $ => \$
#  % => \%
#  & => \&
#  _ => \_
#  { => \{
#  } => \}
#  ~ => \textasciitilde
#  ^ => \textasciicircum
#  \ => \textbackslash
#  | => \textbar
#  < => \textless
#  > => \textgreater

split () {
  sed -E 's/(.)/\1\n/g'
}

connect () {
  sed -n '
    /^$/ {x; s/\n//g; p}
    /^$/! H
    '
}

trans () {
  sed -E '
    s/\\/{\\textbackslash}/g
    s/([#$%&_{}])/\\\1/g
    s/~/{\\textasciitilde}/g
    s/\^/{\\textasciicircum}/g
    s/\|/{\\textbar}/g
    s/</{\\textless}/g
    s/>/{\\textgreater}/g
     '
}

if [[ $# -eq 1 && $1 == --help || $1 == -h ]]; then
  echo "Usage : bash p2t.sh [filename]" 1>&2
  exit 1
fi

split | trans | connect

