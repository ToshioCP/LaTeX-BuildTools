#!/bin/bash

# tfiles [-p|-a|-i] [rootfile]
#   look for subfiles of the given rootfile (default is main.tex)
#   no option => output the list of subfiles (specified in include/iinput command located between \begin{document} and \end{document})
#   -p output subfiles specified in the preamble
#   -a output the rootfile and subfiles (the same as the non-option output)
#   -i output the list of files given by \include command.

# tfiles [-p|-a] [rootfile]
#   ルートファイルからサブファイルを検索する（デフォルトはmain.tex）
#   オプション無し => サブファイル（\begin{document}から\end{document}までのinclude/inputコマンドで指定されたファイル）のリストを標準出力に出力する
#   -p プリアンブルで取り込まれるサブファイルのリストを標準出力に出力する
#   -a オプション無しのリストにルートファイルを加えて標準出力に出力する
#   -i includeコマンドで取り込まれるファイルを標準出力に出力する

#----------------- input, include, includeonly の基礎知識 -----------------------------
#input

#- \input{ファイル名}でその場所にファイルを取り込む
#- ファイル名に.tex拡張子がない場合、まず拡張子をつけてファイルを探し、それがない場合は拡張子なしのファイルを探す
#- ファイル名に.tex拡張子がある場合はそのファイルのみを探す
#- inputはネストして良い（inputで呼ばれたファイルの中にinputがあってよい）
#- inputはプリアンブルにあってもよいし、ボディにあってもよい

#include

#- \include{拡張子の無いファイル名}でその場所にファイルを取り込む
#- ファイルを取り込む場所の直前と直後に\clearpage命令を入れる
#- ファイル名は拡張子をつけない。しかし取り込まれるファイルを探すときには.texの拡張子をつけて探す
#- includeはネストできない
#- includeはボディのみに記述でき、プリアンブルには記述できない
#- プリアンブルにincludeonlyがある場合はその影響を受ける
#- 補助ファイルは、サブファイルごとに作られる（後述）

#includeonly

#- プリアンブルに記述する
#- \includeonly{拡張子無しのファイル名,拡張子無しのファイル名, ...}の形で記述する
#- includeonlyのファイル名には拡張子をつけないが、実際のファイルには拡張子.texをつける
#- ファイル名のリストはコンマで区切る
#- ここに現れたファイルがボディでinclude命令に再び現れると、includeが有効に機能する
#- ここに現れていないファイルがボディでinclude命令に再び現れた場合、includeは無効になる

#includeを使った場合の補助ファイル

#- ルートファイルの補助ファイルと各サブファイルの補助ファイルが作られる
#- ルートファイルの補助ファイルは、各サブファイルの補助ファイルをinputする
#- includeonlyからあるファイルが消される（コメントアウト）のちも対応する補助ファイルは残り、ルートファイルのinputも残る
#- ということは、コメントアウトされたファイルへの参照が可能である
#-------------------------------------------------------------------------------------------

# searchf
# The variable files contains the list of the files that are included through the input command.
# This function adds the files that are the second level of nesting or more.
# Important note!
# This function and the main routine share the variable files.

# searchf
# 変数filesはinputするファイルのリストである。
# この関数はネストされた2段階目以降のファイルをfilesに付け足す
# 重要な注意!
# この関数とメインルーチンは変数filesを共有

searchf () {
  # The value n=10 is the maximum times of the loop.
  # The variable i contains the files that are added to the variable files and not checked the further nested files.
  # The variable j is obtained by the variable i and its contents are one level further than the one in the variable i.

  # nは無限ループを避けるための最大値
  # i filesに追加したが、まだ下位を調べていないファイル
  # j iから得られた一つ下位のファイル => その中でfilesにないものを抽出して新たに次のiを得る
  declare -i n=10
  i="$files"
  while [[ $n -gt 0 && -n $i ]]; do
    j=
    for x in $i; do
      x=$(echo "$x" | sed 's/\.tex$//').tex
      k=$(cat "$x" |
        sed 's/%.*$//' |
        sed -nE '/\\begin\{verbatim\}/,/\\end\{verbatim\}/! p' |
        sed 's/\\/\n\\/g' |
        grep -E '\\input *\{' |
        sed -E 's/^\\input *\{([^}]*)\}.*$/\1/')
      if [[ -z $j ]]; then
        j="$k"
      else
        j="$j"$'\n'"$k"
      fi
    done
    if [[ -n $j ]]; then
      j=$(echo "$j" | sed -E 's/^"(.*)"$/\1/' | sort | uniq)
    fi
    i=
    for x in $j; do
      x=$(echo "$x" | sed 's/\.tex$//').tex
      if [[ ! $files =~ $x ]]; then
        if [[ -z $i ]]; then
          i="$x"
        else
          i="$i"$'\n'"$x"
        fi
      fi
    done
    if [[ -n $i ]]; then
      files="$files"$'\n'"$i"
    fi
    let --n
  done
}

# main routine

# メインルーチン

IFS=$'\n'

if [[ $1 =~ ^-[api]$ ]]; then
  opt=$1
  shift
fi
if [[ $# -gt 1 ]]; then
  echo "Usage: tfiles [-p|-a|-i] [rootfile]" 1>&2
  exit 1
elif [[ $# -eq 1 ]]; then
  arg_rootfile=$(echo "$1" | sed 's/.tex$//').tex
else
  arg_rootfile=main.tex
fi
if [[ ! -f $arg_rootfile ]]; then
  echo "tfiles: No such file: $arg_rootfile" 1>&2
  exit 1
fi
tftype -q "$arg_rootfile"
filetype=$?
if [[ $filetype -ne 0 ]]; then
  echo "Usage: tfiles [-p|-a] [rootfile]" 1>&2
  echo "  $arg_rootfile is not a rootfile." 1>&2
  exit 1
fi

# Usually, the paths described in include/input command are relative from the directory of the rootfile.
# Therefore, this script changes its current directory into the directory above.
# The rootfile is accessed with the relative path contained in the variable $rootpath.

#\includeや\inputはルートファイルからの相対パスで表す（通常はそうである）ため、カレントディレクトリをルートファイルのディレクトリに写す
#以下ではルートファイルを相対パスの$rootfileでアクセスする

dname=$(dirname "$arg_rootfile")
rootfile=$(basename "$arg_rootfile")
cd "$dname"

# In case of -p option
# -p オプションの時

if [[ $opt == "-p" ]]; then
  files=$(cat "$rootfile" |
    sed 's/%.*$//' |
    sed -nE '1,/\\begin\{document\}/ p' |
    sed 's/\\/\n\\/g' |
    grep -E '\\input *\{' |
    sed -E 's/^\\input *\{([^}]*)\}.*$/\1/' |
    sed -E 's/^"(.*)"$/\1/' )
  files=$(echo "$files" | sort | uniq)
  searchf
  files=$(echo "$files" | sort | uniq)
  echo "$files"
  exit
fi

# In the case other than -p option.
# -p オプション以外の時

# includeonly and include

includeonlyfiles=$(cat "$rootfile" |
  sed 's/%.*$//' |
  sed -nE '1,/\\begin\{document\}/ p' |
  tr -s '\t\n ' ' ' |
  grep -E '\\includeonly *\{' |
  sed -E 's/^.*\\includeonly *\{([^}]*)\}.*$/\1/' |
  tr -s ',' '\n' |
  sed -E 's/^ *//;s/ *$//' |
  grep -v '^$' | 
  sed -E 's/^"(.*)"$/\1/' )
includefiles=$(cat "$rootfile" |
  sed 's/%.*$//' |
  sed -nE '/\\begin\{verbatim\}/,/\\end\{verbatim\}/! p' |
  sed -nE '/\\begin\{document\}/, /\\end\{document\}/ p' |
  sed 's/\\/\n\\/g' |
  grep -E '\\include *\{' |
  sed -E 's/^\\include *\{([^}]*)\}.*$/\1/' |
  sed -E 's/^"(.*)"$/\1/' )
final_includefiles=
for x in $includeonlyfiles; do
  for y in $includefiles; do
    if [[ $x == $y ]]; then
# The file names specified by include command doesn't have suffix. It is added in the following line. 
# includeコマンドのファイルには拡張子がないので、ここで付けるようにする
      if [[ -z $final_includefiles ]]; then
        final_includefiles="$x".tex
      else
        final_includefiles="$final_includefiles"$'\n'"$x".tex
      fi
    fi
  done
done
if [[ -z $includeonlyfiles ]]; then
  for x in $includefiles; do
# The file names specified by include command doesn't have suffix. It is added in the following line. 
# includeコマンドのファイルには拡張子がないので、ここで付けるようにする
    if [[ -z $final_includefiles ]]; then
      final_includefiles="$x".tex
    else
      final_includefiles="$final_includefiles"$'\n'"$x".tex
    fi
  done
fi

if [[ $opt == "-i" ]]; then
  echo "$final_includefiles"
  exit
fi
# input

files=$(cat "$rootfile" |
  sed 's/%.*$//' |
  sed -nE '/\\begin\{verbatim\}/,/\\end\{verbatim\}/! p' |
  sed -nE '/\\begin\{document\}/, /\\end\{document\}/ p' |
  sed 's/\\/\n\\/g' |
  grep -E '\\input *\{' |
  sed -E 's/^\\input *\{([^}]*)\}.*$/\1/' |
  sed -E 's/^"(.*)"$/\1/' )
files=$(echo "$files" | sort | uniq)
# look into the file nested
# ネストしたファイルのチェック
searchf
if [[ -n $final_includefiles ]]; then
  files="$files"$'\n'"$final_includefiles" 
fi
files=$(echo "$files" | sort | uniq)
if [[ $opt == "-a" ]]; then
  echo "$rootfile"$'\n'"$files"
else
  echo "$files"
fi

