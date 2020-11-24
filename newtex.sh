#! /bin/bash
#
# The script newtex is executed twice by the user.
# 1. In the first execution with an argument of a book name, it makes a folder and put the following files under the folder.
#    Sample files of Makefile, Rakefile, main.tex, helper.tex, cover.tex and skeleton.txt.
# 2. Then, user edits skeleton.txt and modifies or adds chapters and subfile names correspond to each chapter.
# 3. Execute newtex again without any arguments　in the folder above. Then, the chapters and the input commands are added to main.tex and corresponding subfiles are generated.

# スクリプトnewtexは、ユーザによって、2回実行される。
# 1. 1回めの実行で書名を引数に与えると、ディレクトリが作られ、その中に下記ファイルを設置する
#    Makefile, Rakefile, main.tex, helper.tex, cover.tex, skeleton.txtの雛形
# 2. ユーザはこのあとskeleton.txtを編集する。章と対応するサブファイルを書く直し、あるいは付け加える。
# 3. その後、そのディレクトリの中で、引数なしで2回目の実行をする。すると、main.texに章とinput文が付け加えられ、サブファイルが生成される。

usage() {
  echo "Usage:" 1>&2
  echo "  newtex --help" 1>&2
  echo "    Show this message." 1>&2
  echo "  newtex [-en | -ja] bookname" 1>&2
  echo "    A directory bookname is made and some template files are generated under the directory." 1>&2
  echo "    Then, bookname/skeleton.txt needs to be edited to specify chapters and subfiles." 1>&2
  echo "  cd bookname" 1>&2
  echo "  newtex" 1>&2
  echo "    Chapters and input commands are added to main.tex and corresponding subfiles are generated." 1>&2
  echo "    If some bad things happen, make.tex.bak is the backup file copied from the original main.tex." 1>&2
  echo "    If everything is OK, you can remove make.tex.bak." 1>&2
  exit 1
}

# show help message
if [[ $1 == "--help" ]]; then
  usage
fi

# 2nd time
if [[ $# == 0 && -f Makefile && -f Rakefile && -f main.tex && -f helper.tex && -f cover.tex && -f skeleton.txt ]]; then
# generate main.tex and subfile
  declare -a buf chapters subfiles # arrays
  declare -i i n j nc # integers

  i=0

  mapfile buf <skeleton.txt
  n=${#buf[@]} # number of the elements in the array
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
  usage
fi
bookname=$1

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
  echo "Maybe you need to install this script to ${sysbin} or ${usrbin}, or modify this script to fit your environment." 1>&2
  exit 1
fi

if [[ ! -d $srcfolder ]]; then
  echo "${srcfolder} doesn't exist or it isn't a directory. Maybe the language option -$ntlang is wrong." 1>&2
  echo
  usage
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
# generate Rakefile
cat ${srcfolder}/Rakefile | sed "s/bookname/${bookdir}/" >${bookdir}/Rakefile
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

