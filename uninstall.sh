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
  echo "Usage: bash uninstall.sh [--help]" 1>&2
  echo "   Uninstall the script files from bin directory." 1>&2
  echo "   If a user runs it, $HOME is chosen as the parent directory of the bin directory." 1>&2
  echo "   If the root runs it, /usr/local is chosen as the parent directory of the bin directory." 1>&2
  echo "Option:" 1>&2
  echo "   --help: Show this help message." 1>&2
}

if [[ $# -eq 1  && $1 == --help ]] ; then
  usage
elif [[ $# -eq 0 ]] ; then
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

