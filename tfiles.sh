#!/bin/bash

# tfiles [-p|-a|-i] [rootfile]
#   look for subfiles of the given rootfile (default is main.tex)
#   no option => output the list of subfiles (specified in include/iinput command located between \begin{document} and \end{document})
#   -p output subfiles specified in the preamble
#   -a output add the rootfile to the files listed when no option.  
#   -i output the list of files given by \include command.

# tfiles [-p|-a|-i] [rootfile]
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
#- ファイル名には拡張子をつけない。しかし取り込まれるファイルを探すときには.texの拡張子をつけて探す
#- includeはネストできない
#- includeはボディのみに記述でき、プリアンブルには記述できない
#- プリアンブルにincludeonlyがある場合はその影響を受ける
#- 補助ファイルは、サブファイルごとに作られる（後述）

#includeonly

#- プリアンブルに記述する
#- \includeonly{拡張子無しのファイル名,拡張子無しのファイル名, ...}の形で記述する
#- includeonlyのファイル名には拡張子をつけないが、それは拡張子.texのついたファイルを意味する
#- ファイル名のリストはコンマで区切る
#- ここに現れたファイルがボディでinclude命令に再び現れると、includeが有効に機能する
#- ここに現れていないファイルがボディでinclude命令に再び現れた場合、includeは無効になる

#includeを使った場合の補助ファイル

#- ルートファイルの補助ファイルと各サブファイルの補助ファイルが作られる
#- ルートファイルの補助ファイルは、各サブファイルの補助ファイルをinputする
#- includeonlyからあるファイルが消された（コメントアウトされた）のちも対応する補助ファイルは残り、ルートファイルのinputも残る
#- ということは、コメントアウトされたファイルへの参照が可能である
#-------------------------------------------------------------------------------------------

usage () {
  echo "Usage: tfiles --help"  1>&2
  echo "  Show this message."  1>&2
  echo "Usage: tfiles [-p|-a|-i] [rootfile]"  1>&2
  echo "  Look for subfiles of the given rootfile (default is main.tex)." 1>&2
  echo "  Option:" 1>&2
  echo "    no option: Output the list of subfiles (specified in include/iinput command located between \begin{document} and \end{document})." 1>&2
  echo "   -p:         Output subfiles specified in the preamble." 1>&2
  echo "   -a:         Output the files' list with no option. Then output the rootfile." 1>&2  
  echo "   -i:         Output the list of files specified by \include command." 1>&2
  exit 1
}

# searchf
# This function and the main routine share the variable "files".
# When this function is invoked, the variable files has a list of tex files.
# This function searches the files in the list for files specified by the \input command.
# And it searches the files found in the search above for files specified by the \input command again. It repeats. The number of repeat is less than or equal to 10.
# All the files found by the search above are added to the variable files.

# searchf
# この関数とメインルーチンは変数filesを共有している。
# この関数が呼ばれたときに、変数filesにはtexファイルのリストが代入されている。
# リストの各ファイルから、inputコマンドで取り込み指定されているファイルを探す。
# この検索で見つかったファイルからもinputコマンドで取り込み指定されているファイルを探す。この検索はくり返され、最大10回の深さまで行われる。
# 見つかったすべてのファイル（重複を除く）を変数filesに付け加える。

searchf () {
  # The value n=10 is the maximum number of times of the loop.

  # n=10はループ回数の最大値

  declare -i n=10
  i="$files"
  while [[ $n -gt 0 && -n $i ]]; do
    j=
    for x in $i; do
      x=$(echo "$x" | sed 's/\.tex$//').tex
      k=$(cat "$x" |
        sed 's/%.*$//' |
        sed -nE '/\\begin\{verbatim\}/,/\\end\{verbatim\}/! p' |
        sed 's/\\input/\n\\input/g' |
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

if [[ $1 == "--help" ]]; then
  usage
fi
if [[ $1 =~ ^-[api]$ ]]; then
  opt=$1
  shift
fi
if [[ $# -gt 1 ]]; then
  usage
elif [[ $# -eq 1 ]]; then
  arg_rootfile=$(echo "$1" | sed 's/.tex$//').tex
else
  arg_rootfile=main.tex # default rootfile
fi
if [[ ! -f $arg_rootfile ]]; then
  echo "tfiles: No such file: $arg_rootfile" 1>&2
  exit 1
fi
tftype -q "$arg_rootfile"
filetype=$?
if [[ $filetype -ne 0 ]]; then
  echo "tfiles: tftype says $arg_rootfile is not a rootfile." 1>&2
  exit 1
fi

# Usually, the paths described in include/input command are relative from the directory of the rootfile.
# Therefore, this script changes its current directory into the directory the given rootfile belongs.

#\includeや\inputはルートファイルからの相対パスで通常は表されるので、カレントディレクトリをルートファイルのディレクトリに移動する

dname=$(dirname "$arg_rootfile")
rootfile=$(basename "$arg_rootfile")
cd "$dname"

if [[ $opt == "-p" ]]; then
  files=$(cat "$rootfile" |
    sed 's/%.*$//' |
    sed -nE '1,/\\begin\{document\}/ p' |
    sed 's/\\input/\n\\input/g' |
    grep -E '\\input *\{' |
    sed -E 's/^\\input *\{([^}]*)\}.*$/\1/' |
    sed -E 's/^"(.*)"$/\1/' )
  files=$(echo "$files" | sort | uniq)
  searchf
  files=$(echo "$files" | sort | uniq)
  echo "$files"
  exit 0
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
  sed 's/\\include/\n\\include/g' |
  grep -E '\\include *\{' |
  sed -E 's/^\\include *\{([^}]*)\}.*$/\1/' |
  sed -E 's/^"(.*)"$/\1/' )
if [[ -z $includeonlyfiles ]]; then
  final_includefiles=$includefiles
else
  final_includefiles=
  for x in $includeonlyfiles; do
    for y in $includefiles; do
      if [[ $x == $y ]]; then
        if [[ -z $final_includefiles ]]; then
          final_includefiles="$x"
        else
          final_includefiles="$final_includefiles"$'\n'"$x"
        fi
      fi
    done
  done
fi
# The file names specified by include command doesn't have suffix. It is added in the following line. 
# includeコマンドのファイルには拡張子がないので、ここで付けるようにする
if [[ -n $final_includefiles ]]; then
  final_includefiles="$(echo "$final_includefiles" | sed 's/$/.tex/')"
fi

if [[ $opt == "-i" ]]; then
  echo "$final_includefiles"
  exit 0
fi

#input
files=$(cat "$rootfile" |
  sed 's/%.*$//' |
  sed -nE '/\\begin\{verbatim\}/,/\\end\{verbatim\}/! p' |
  sed -nE '/\\begin\{document\}/, /\\end\{document\}/ p' |
  sed 's/\\input/\n\\input/g' |
  grep -E '\\input *\{' |
  sed -E 's/^\\input *\{([^}]*)\}.*$/\1/' |
  sed -E 's/^"(.*)"$/\1/' )
files="$(echo "$files" | sort | uniq)"
# look into the file nested
# ネストしたファイルのチェック
searchf
if [[ -n $final_includefiles ]]; then
  files="$files"$'\n'"$final_includefiles" 
fi
files="$(echo "$files" | sort | uniq)"
if [[ $opt == "-a" ]]; then
  echo "$rootfile"$'\n'"$files"
else
  echo "$files"
fi

