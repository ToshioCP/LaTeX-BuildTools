#!/bin/bash

# plain to tex
# This is a filter program to replace the special characters with latex format.
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

usage () {
  echo "Usage: p2t [--help]" 1>&2
  echo "  Option: --help   show this message." 1>&2
  echo "  p2t read data from standard input and escape the special characters with latex format." 1>&2
  echo "  For example, backslash(\) is translated into \textbackslash." 1>&2
  exit 1
}

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

if [[ $# -eq 1 && $1 == --help ]]; then
  usage
fi

split | trans | connect

