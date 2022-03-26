# /bin/bash

# How srf search a rootfile?
# 1. If the argument wasn't a subfile but rootfile, then srf outputs the absolute path of the rootfile itself.
# 2. First, srf searches the directory to which the given subfile belongs.
#    If srf doesn't find it, then it searches the parent directory of the directory above.
# 3. If srf find it, it outputs the absolute path of the rootfile. Otherwise it stops searching.

# srfの検索機能
# 1. 引数がサブファイルでなく、ルートファイルだった場合はそのルートファイルの絶対パスを出力する。
# 2. 検索はサブファイルのディレクトリをまず行い、見つからなければその親ディレクトリを検索する。
# 3. 見つかった場合はルートファイルの絶対パスを出力し、見つからない場合は検索を中止する。

usage () {
  echo "Usage: srf --help" 1>&2
  echo "  Show this message." 1>&2
  echo "Usage: srf subfile" 1>&2
  echo "  Search the rootfile from the subfile and output it to stdout." 1>&2
  exit 1
}

# main routine

IFS=$'\n'

if [[ $1 == "--help" ]]; then
  usage
fi
if [[ $# -ne 1 ]]; then
  usage
fi

subfile=$(echo "$1" | sed 's/.tex$//').tex
tftype -q "$subfile"
filetype=$?
if [[ $filetype -eq 0 ]]; then
  echo "$(realpath $subfile)" # $given argument is a rootfile, not subfile.
  exit 0
elif [[ $filetype -eq 2 ]]; then
  echo "srf: tftype returned \"No such file $subfile\" error." 1>&2
  exit 1
fi

cd "$(dirname "$subfile")"
subfile=$(basename "$subfile")

# ERE
pattern_tw='^ *% *!TeX +root *= *([^ ]+) *$'
pattern_ge='^ *% *mainfile: *([^ ]+) *$'

s=$(head -n 1 "$subfile")
if [[ $s =~ $pattern_tw ]]; then
  rootfile=$(echo "$s" | sed -E "s/$pattern_tw/\1/")
elif [[ $s =~ $pattern_ge ]]; then
  rootfile=$(echo "$s" | sed -E "s/$pattern_ge/\1/")
else
  rootfile=
fi
if [[ -n $rootfile ]]; then
  rootfile=$(echo "$rootfile" | sed 's/.tex$//').tex
  echo "$(realpath "$rootfile")"
  exit 0
fi

for rootfile in $(tftype -r *.tex); do
  for x in $(tfiles "$rootfile"); do
    if [[ $x == $subfile || $x == "./$subfile" ]]; then
      echo "$(realpath "$rootfile")"
      exit 0
    fi
  done
  for x in $(tfiles -p "$rootfile"); do
    if [[ $x == $subfile || $x == "./$subfile" ]]; then
      echo "$(realpath "$rootfile")"
      exit 0
    fi
  done
done

subfile="$(basename $(pwd))/$subfile"
cd ..

for rootfile in $(tftype -r *.tex); do
  for x in $(tfiles "$rootfile"); do
    if [[ $x == $subfile ]]; then
      echo "$(realpath "$rootfile")"
      exit 0
    fi
  done
  for x in $(tfiles -p "$rootfile"); do
    if [[ $x == $subfile ]]; then
      echo "$(realpath "$rootfile")"
      exit 0
    fi
  done
done

echo "srf: Not found rootfile." 1>&2
exit 1
