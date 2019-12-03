# /bin/bash


# LaTeXの root file の検索
# 1. サブファイルの置かれているディレクトリにカレントディレクトリを移す
# 2. 最初の行を調べる
# % !TeX root = root-filename or pathname ... Texworks Texstudio で使われるマジックコメントがあれば、そのルートファイルの絶対パスを返す
# % mainfile: mainfile.tex ... gedit-evince のsynctex前方参照で使われるマジックコメントがあれば、そのルートファイルの絶対パスを返す
# 3. サブファイルと同じディレクトリにルートファイルがないか調べ、あればその絶対パスを返す
#  すべての.texファイルに対し、
#  - documentclass があるかどうかをチェック
#  - そこから現在のファイルにたどりつけるかどうかをチェック
# 3. それで見つからなければ、一つ上のディレクトリにカレントディレクトリを移動して、ルートファイルを探し、あればその絶対パスを返す
# 4. それで見つからなければ、no such file エラー報告(exit 1)をする

# 検索結果は絶対パスで返す

# Usage: srf subfile
# srfは Search Root File



# main routine

IFS=$'\n'

if [[ $# -ne 1 ]]; then
  echo "Usage: srf subfile" 1>&2
fi
subfile=$(echo "$1" | sed 's/.tex$//').tex
tftype -q "$subfile"
filetype=$?
if [[ $filetype -eq 0 ]]; then
  echo "$(realpath $subfile)" # $subfile is a rootfile
  exit 0
elif [[ $filetype -eq 2 ]]; then
  echo "tftype: No such file $subfile." 1>&2
  exit 1
fi

cd "$(dirname "$subfile")"
subfile=$(basename "$subfile")

# ERE
pattern_tw='s/^ *% *!TeX +root *= *([^ ]+) *$'
pattern_ge='s/^ *% *mainfile: *([^ ]+) *$'

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

exit 1
