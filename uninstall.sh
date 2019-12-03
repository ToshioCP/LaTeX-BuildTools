# uninstall.sh

# bash uninstall.sh [-s|-u]
# option: -s taget directorys are /usr/local/bin and /usr/local/share/ltxtools (default when root)
#          -u taget directorys are $HOME/bin and $HOME/share/ltxtools (default when user mode)

# アンインストールのスクリプト。bash uninstall.sh のように、bash の引数に指定する。
# オプション: -s インストール先ディレクトリを/usr/local/binと/usr/local/share/ltxtoolsとしてアンインストール。
#          -u インストール先ディレクトリを$HOME/binと$HOME/share/ltxtoolsとしてアンストール。

binfiles="newtex ttex tfiles p2t ltxengine tftype srf gfiles lb arl"
toolfiles="Makefile main.tex helper.tex cover.tex skeleton.txt gecko.png"

if [[ $# -eq 1 && $1 == "-u" ]] ; then
  bin="$HOME/bin"
  share="$HOME/share"
elif [[ $# -eq 1 && $1 == "-s" ]] ; then
  # root privilege is needed to install.
  bin="/usr/local/bin"
  share="/usr/local/share"
elif [[ $# -eq 0 ]] ; then
  if [[ -w /usr/local/bin ]] ; then
    bin="/usr/local/bin"
    share="/usr/local/share"
  else
    bin="$HOME/bin"
    share="$HOME/share"
  fi
else
  # argument error, print usage to stderr
  echo "Usage : bash uninstall.sh [-s|-u]" 1>&2
  exit 1
fi

ltxtools="$share/ltxtools"

for file in $binfiles ; do
  if [[ -f $bin/$file ]] ; then
    rm $bin/$file
  fi
done

if [[ -d $ltxtools ]] ; then
  for x in en ja ; do
    for file in $toolfiles ; do
      if [[ -f $ltxtools/tsrc_$x/$file ]] ; then
        rm $ltxtools/tsrc_$x/$file
      fi
      if [[ -z $(ls $ltxtools/tsrc_$x) ]] ; then
        rmdir $ltxtools/tsrc_$x
      fi
    done
  done
fi

if [[ -z $(ls $ltxtools) ]] ; then
  rmdir $ltxtools
fi
