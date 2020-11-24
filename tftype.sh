#!/bin/bash

# $ tftype(sh) [-r|-s|-q] files ...
# -r （デフォルト）引数のファイルの中からルートファイルのみを抽出して出力する
# -s 引数のファイルの中からサブファイルのみを抽出して出力する
# -q （quiet）上記の出力を抑制する。引数は1つのファイルのみで、そのファイルタイプをexitステータスで返す
#     0 .. ルートファイル
#     1 .. サブファイル
#     2 .. エラー（例えばファイルが見つからない）

usage () {
  echo "Usage: tftype(sh) [-r|-s|-q] files ..." 1>&2
  echo "  Option:" 1>&2
  echo "    -r: This is default. Rootfiles in the given arguments are printed out to the standard output." 1>&2
  echo "    -s: Subfiles in the given arguments are printed out to the standard output." 1>&2
  echo "    -q: Quiet mode. Nothing is printed to the standard output. Instead, return the exit status to the caller. Only one argument is allowed." 1>&2
  echo "        Exit status;" 1>&2
  echo "          0: The argument is a rootfile." 1>&2
  echo "          1: The argument is a subfile." 1>&2
  echo "          2: Error. (For example, there's no such file given by the argument.)" 1>&2
  exit 1
}

if [[ $1 == "--help" ]]; then
  usage
fi

if [[ $1 =~ ^-(r|s|q)$ ]]; then
  opt=$1
  shift
fi
if [[ $# -eq 0 || $# -gt 1 && $opt == "-q" ]]; then
  usage
fi
texfile=$(echo "$1" | sed 's/\.tex$//').tex

if [[ $opt == "-q" ]]; then
  if [[ -f $texfile ]]; then
    s=$(cat "$texfile" | sed 's/%.*//' | grep \\documentclass)
    if [[ -n $s ]]; then
      exit 0
    else
      exit 1
    fi
  else
    exit 2
  fi
else
  while [[ $# -ge 1 ]]; do
    if [[ -f $texfile ]]; then
      s=$(cat "$texfile" | sed 's/%.*//' | grep \\documentclass)
     # The option -r is the default ($opt=""). If $opt is empty, then $opt != "-s" is true.
      # デフォルトが -r なので、オプションなしのとき($opt=="")でも通用するように$opt != "-s"となっている
      if [[ $opt != "-s" && -n $s || $opt == "-s" && -z $s ]]; then
        echo "$texfile"
      fi
    fi
    shift
    texfile="$(echo $1 | sed 's/\.tex$//').tex"
  done
fi
