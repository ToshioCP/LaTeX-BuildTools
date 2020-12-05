# uninstall.sh

binfiles="arl
gfiles
lb
ltxengine
newtex
srf
tfiles
tftype
ttex"

usage() {
  echo "Usage: bash uninstall.sh [--help| -s| -u]" 1>&2
  echo "   Uninstall the script files in this directory from bin directory." 1>&2
  echo "Option:" 1>&2
  echo "   --help: Show this help message." 1>&2
  echo "       -s: /usr/local is chosen as the parent directory of the bin directory." 1>&2
  echo "       -u: $HOME is chosen as the parent directory of the bin directory." 1>&2
}

if [[ $# -eq 1 ]] ; then
  case "$1" in
    --help) usage;;
    -s)
      if [[ ! -w /usr/local/bin ]] ; then
        echo "install.sh: Intallation failed." 1>&2
        echo "  You don't have permission to write any files under /usr/local/bin." 1>&2
        echo "  Use sudo or su." 1>&2
        exit 1
      fi
      bin="/usr/local/bin";;
    -u)
      bin="$HOME/bin";;
    *) usage;;
  esac
elif [[ $# -eq 0 ]] ; then
  # If no argument is given, the folder to install is determined from whether /usr/local/bin is writable or not.
  # 引数なしのときは、/usr/local/binの書き込み権限を見て、rootか一般ユーザかを見てインストール先を決定する
  if [[ -w /usr/local/bin ]] ; then
    bin="/usr/local/bin"
  else
    bin="$HOME/bin"
  fi
else
  # argument error, print usage to stderr
  usage
fi

for file in $binfiles ; do
  if [[ -f $bin/$file ]] ; then
    rm $bin/$file
  fi
done

