#! /bin/bash
#
# This script is executed twice by the user.
# 1. In the first execution, it makes a folder and put the following files under the folder.
#    Sample files of Makefile, main.tex, helper.tex, cover.tex and skeleton.txt.
# 2. The user edits skeleton.txt so that chapters and subfile names correspond to each chapter are described.
# 3. Then, the user executes this script again without an argument so that the chapters and the input commands are added to main.tex and the subfiles are generated.

# このプログラムは、ユーザによって、2回実行される。
# 1. 1回めの実行で（newtex bookname）、ディレクトリを作り、その中に下記ファイルを設置する
#    Makefile, main.texの雛形, helper.tex, cover.texの雛形, skeleton.txtの雛形
# 2. ユーザはこのあとskeleton.txtを編集する。章と対応するサブファイルを書く。
# 3. その後、そのディレクトリの中で2回めのを実行する（引数なしで良い）。main.texに章とinput文を付け加え、サブファイルを生成する。

# 2nd time
if [[ -f Makefile && -f main.tex && -f helper.tex && -f cover.tex && -f skeleton.txt ]]; then
# generate main.tex and subfile
  declare -a buf chapters subfiles
  declare -i i n j nc

  i=0

  mapfile buf <skeleton.txt
  n=${#buf[@]}
  for (( i=0 ; i<$n ; i++ )) ; do
    s=$(echo -n "${buf[$i]}" | sed -E 's/^ *([^#]*)#.*$/\1/')
    if [[ -n $s ]]; then
      pattern='^ *"[^"]*" *[^ ]* *$'
      if [[ ! $s =~ $pattern ]]; then
        echo "Syntax error in skeleton.txt" 1>&2
        echo "$s" 1>&2
        exit 1
      fi
      chapter=$(echo "$s" | sed -E 's/^ *"([^"]*)" *[^ ]* *$/\1/')
      subfile=$(echo "$s" | sed -E 's/^ *"[^"]*" *([^ ]*) *$/\1/' | sed 's/.tex$//').tex
      echo "\\chapter{$chapter}" >> temp_main.txt
      echo "\\input{\"$subfile\"}" >> temp_main.txt
      echo >$subfile
    fi
  done

  mv main.tex main.tex.bak
  sed '/\\mainmatter/ r temp_main.txt' <main.tex.bak >main.tex
  rm temp_main.txt
  exit 0
fi

# 1st time
if [[ $1 =~ ^-(en|ja)$ ]]; then
  ntlang=$(echo $1 | sed 's/^-//')
  shift
else
  ntlang=en #default
fi
if [[ $# -ne 1 ]]; then
  echo "Usage:" 1>&2
  echo "1st time  =>  $ newtex [-en|-ja|...] bookname" 1>&2
  echo "2nd time  =>  $ newtex" 1>&2
  exit 1
fi
bookname=$1

# srcfolder includes Makefile, ... etc.
# modify the following line to fit your environment.
sysbin="/usr/local/bin"
sysshare="/usr/local/share"
usrbin="$HOME/bin"
usrshare="$HOME/share"

prog=$(basename $0)
wd=$(dirname $0)
if [[ $wd == $sysbin ]] ; then
  bin=$sysbin
  srcfolder=$sysshare/ltxtools/tsrc_$ntlang
elif [[ $wd == $usrbin ]] ; then
  bin=$usrbin
  srcfolder=$usrshare/ltxtools/tsrc_$ntlang
else
  echo "This script should have been located at ${sysbin} or ${usrbin}." 1>&2
  exit 1
fi

if [[ !(-n $srcfolder) ]]; then
  echo "There is no source folder ${srcfolder}. Maybe the language option -$ntlang is mistaken." 1>&2
  exit 1
fi

bookdir=$(echo "$bookname" | sed 's/ /_/g')
# make directory
if [[ -d $bookdir ]] ; then
  echo "Directory $bookdir already exists."
  exit 1
fi
mkdir "$bookdir"

# generate Makefile
cat ${srcfolder}/Makefile | sed "s/bookname/${bookdir}/" >${bookdir}/Makefile
# generate main.tex
cat ${srcfolder}/main.tex >${bookdir}/main.tex
# generate helper.tex
cat ${srcfolder}/helper.tex >${bookdir}/helper.tex
# generate cover.tex
cat ${srcfolder}/cover.tex | sed "s/bookname/${bookname}/" >${bookdir}/cover.tex
# generate skeleton.txt
cat ${srcfolder}/skeleton.txt >${bookdir}/skeleton.txt
# copy sample image
cat ${srcfolder}/gecko.png >${bookdir}/gecko.png

