# install.sh

# bash install.sh [-s|-u]
# option: -s taget directorys are /usr/local/bin and /usr/local/share/ltxtools (default when root)
#          -u taget directorys are $HOME/bin and $HOME/share/ltxtools (default when user mode)

# インストール用スクリプト。bash install.sh のように bash の引数の形で起動する。
# オプション: -s システム領域（/usr/local/binや/usr/local/share/ltxtools）にインストール。複数ユーザで共有
#           -u ユーザ領域（$HOME/binや$HOME/share/ltxtools）にインストール。インストールしたユーザのみが使用できる

if [[ $# -eq 1 && $1 == "-u" ]] ; then
  bin="$HOME/bin"
  share="$HOME/share"
elif [[ $# -eq 1 && $1 == "-s" ]] ; then
  # root privilege is needed to install.
  bin="/usr/local/bin"
  share="/usr/local/share"
elif [[ $# -eq 0 ]] ; then
  # If no argument is given, the folder to install is determined from whether /usr/local/bin is writable or not.
  # 引数なしのときは、/usr/local/binの書き込み権限を見て、rootか一般ユーザかを見てインストール先を決定する
  if [[ -w /usr/local/bin ]] ; then
    bin="/usr/local/bin"
    share="/usr/local/share"
  else
    bin="$HOME/bin"
    share="$HOME/share"
  fi
else
  # argument error, print usage to stderr
  echo "Usage : bash install.sh [-s|-u]" 1>&2
  exit 1
fi

ltxtools="$share/ltxtools"
me=$(whoami)

bcopy() {
cp $1.$2 $bin/$1
chown ${me}:${me} $bin/$1
chmod 755 $bin/$1
}

tcopy() {
  cp -u $1 $ltxtools/$1
  chown ${me}:${me} $ltxtools/$1
  chmod 644 $ltxtools/$1
}

if [[ ! -d $bin ]] ; then
  mkdir $bin
fi
if [[ ! -d $share ]] ; then
  mkdir $share
fi

# generate bin scripts
bcopy newtex sh
bcopy ttex sh
bcopy tfiles sh
bcopy p2t sh
bcopy ltxengine sh
bcopy tftype sh
bcopy srf sh
bcopy gfiles sh
bcopy lb sh
bcopy arl sh

if [[ ! -d $ltxtools ]] ; then
  mkdir $ltxtools
fi
for x in en ja ; do
  if [[ ! -d $ltxtools/tsrc_$x ]] ; then
    mkdir $ltxtools/tsrc_$x
  fi
  tcopy tsrc_$x/Makefile
  tcopy tsrc_$x/main.tex
  tcopy tsrc_$x/helper.tex
  tcopy tsrc_$x/cover.tex
  tcopy tsrc_$x/skeleton.txt
  tcopy tsrc_$x/gecko.png
done

