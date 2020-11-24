#! /usr/bin/env bash

# lb [maintexfile|subfile]

# delimiter=newline
IFS='
'

# Space can be included in the right hand side of the following equation,
# because the delimiter is only newline.

definition='
rootfile=main.tex
builddir=_build
engine=
latex_option=-halt-on-error
dvipdf=
preview=
'

usage() {
  echo "lb [LaTeXfile]" 1>&2
  echo "  If the argument is a rootfile, then lb compiles it with its subfiles." 1>&2
  echo "  If the argument is a subfile, then lb compiles it only." 1>&2
  echo "If you want to specify latex-engine, build directory and so on," 1>&2
  echo " modify lb.conf file and put it in the directory which includes your tex file." 1>&2
  exit 1
}

if [[ $1 == "--help" ]]; then
  usage
fi

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

if [[ $# -eq 1 ]]; then
  texfile=$(echo "$1" | sed 's/.tex$//').tex
elif [[ $# -eq 0 ]]; then
  texfile=$(echo "$rootfile" | sed 's/.tex$//').tex
else
  echo "No LaTeXfile is given." 1>&2
  echo "Maybe the lb.conf file defines \"rootfile=\", that means lb.conf has no default rootfile." 1>&2
  usage
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

if [[ -n $builddir && ! -d $builddir ]]; then
  mkdir "$builddir"
fi
# includeするファイルがサブディレクトリ以下にある場合は、そのディレクトリも作らなければならない
if [[ $texfiletype -eq 0 ]]; then
  includeonlyfiles=$(tfiles -i "$rootfile")
  for x in $includeonlyfiles; do
    directory=$(dirname "$x")
    if [[ $directory != "." ]]; then
      if [[ -n $builddir ]]; then
        mkdir -p "$builddir/$directory"
      else
        mkdir -p "$directory"
      fi
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
  if [[ -n $dvipdf ]]; then
    popt="-p $dvipdf"
  else
    popt="-p dvipdfmx"
  fi
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
    latex)    latexmk -dvi -latex="latex $latex_option %O %S" $outdir $rootfile;;
    platex)   latexmk -dvi -latex="platex $latex_option %O %S" $outdir $rootfile;;
  esac
  if [[ $engine == latex || $engine == platex ]]; then
    dvifile=$(echo $rootfile | sed 's/\.tex$/.dvi/')
    pdffile=$(echo $rootfile | sed 's/\.tex$/.pdf/')
    if [[ -n $builddir ]]; then
      dvifile=$builddir/$dvifile
      pdffile=$builddir/$pdffile
    fi
    if [[ $dvipdf == dvipdfmx || $dvipdf == dvipdfm ]]; then
      $dvipdf -o $pdffile $dvifile
    elif [[ $dvipdf == dvipdf ]]; then
      $dvipdf $dvifile $pdffile
    fi
  fi
else # subfile
  ttex $bopt -e $engine $popt $vopt -r "$rootfile" "$subfile"
fi

