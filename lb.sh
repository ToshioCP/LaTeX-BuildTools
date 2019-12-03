#! /usr/bin/env bash

# lb [maintexfile|subfile]

#for debug
print_options () {
for x in rootfile builddir engine latex_option preview; do
  declare -n xvalue=$x
  echo $x = $xvalue
done
}

definition='
rootfile=main.tex
builddir=_build
engine=
latex_option=-halt-on-error
preview=texworks
'
# delimiter=newline
IFS='
'
for s in $definition; do
  s1=$(echo $s | sed 's/=.*$//')
  s2=$(echo $s | sed 's/^.*=//')
  declare $s1="$s2"
  variables="$variables $s1"
done
# delimiter=space, tab, newline
IFS=' '$'\t'$'\n'
if [[ -f lb.conf ]]; then
  while read s ; do
    s=$(echo $s |
      sed 's/#.*$//' |
      grep '[[:alpha:]_][[:alnum:]]*=' |
      sed 's/^ *//; s/ *$//')
    if [[ -n $s ]]; then
      s1=$(echo $s | sed 's/=.*$//')
      s2=$(echo $s | sed 's/^.*=//')
      declare $s1="$s2"
    fi
  done <lb.conf
fi
if [[ $latex_engine =~ pdflatex|lualatex ]]; then
  dvi2pdf=
fi

if [[ $# -eq 1 ]]; then
  texfile=$(echo "$1" | sed 's/.tex$//').tex
elif [[ $# -eq 0 ]]; then
  texfile=$(echo "$rootfile" | sed 's/.tex$//').tex
else
  echo "lb [rootfile|subfile]" 1>&2
  exit 1
fi

# look for rootfile
# texfileの存在についてもここでチェックしている
tftype -q "$texfile"
texfiletype=$?
if [[ $texfiletype -eq 0 ]]; then
  rootfile="$texfile"
elif [[ $texfiletype -eq 1 ]]; then
  subfile="$texfile"
  rootfile=$(srf "$subfile")
  if [[ -z $rootfile ]]; then
    echo "lb: Rootfile not found" 1>&2
    exit 1
  fi
else
  echo "lb: No such file: $texfile" 1>&2
  exit 1
fi

# cd $dname すべてのパスを$dnameからの相対パスへ
rootfile=$(realpath "$rootfile")
dname=$(dirname "$rootfile")
rootfile=$(basename "$rootfile")
if [[ -n $subfile ]]; then
  subfile=$(realpath --relative-to "$dname" "$subfile")
fi
cd "$dname"

if [[ ! -d $builddir ]]; then
  mkdir "$builddir"
fi
# includeするファイルがサブディレクトリ以下にある場合は、そのディレクトリも作らなければならない
if [[ $texfiletype -eq 0 ]]; then
  includeonlyfiles=$(tfiles -i "$rootfile")
  for x in $includeonlyfiles; do
    directory=$(dirname "$x")
    if [[ $directory != "." ]]; then
      mkdir -p "$builddir/$directory"
    fi
  done
fi
# determine engine
if [[ -z $engine ]]; then
  engine=$(ltxengine "$rootfile" 2>/dev/null)
fi

if [[ $engine == lualatex ]]; then
  latex_option=$(echo $latex_option | sed 's/^-/--/; s/ -/ --/g')
fi

if [[ -n $builddir ]]; then
  outdir="-output-directory=$builddir"
  bopt="-b $builddir"
else
  outdir=
  bopt=
fi

if [[ $engine =~ ^p?latex$ ]]; then
  popt="-p $dvipdf"
else
  popt=
fi

if [[ -n $preview ]]; then
  vopt="-v $preview"
else
  vopt=
fi

if [[ $texfiletype -eq 0 ]]; then # root file
  case $engine in
    pdflatex) latexmk -pdf -pdflatex="pdflatex $latex_option %O %S" $outdir $rootfile ;;
    lualatex) latexmk -lualatex -pdflualatex="lualatex $latex_option %O %S" $outdir $rootfile;;
    xelatex)  latexmk -xelatex -pdfxelatex="xelatex $latex_option %O %S" $outdir $rootfile;;
    latex)    latexmk -pdfdvi -latex="latex $latex_option %O %S" $outdir $rootfile;;
    platex)   latexmk -pdfdvi -latex="platex $latex_option %O %S" $outdir $rootfile;;
  esac
else # subfile
  ttex $bopt -e $engine $popt $vopt -r "$rootfile" "$subfile"
fi

