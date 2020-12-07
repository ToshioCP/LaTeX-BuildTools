# install.sh

binfiles="arl.sh
gfiles.sh
lb.sh
ltxengine.sh
newtex.sh
srf.sh
tfiles.sh
tftype.sh
ttex.sh"

usage() {
  echo "Usage: bash install.sh [--help]" 1>&2
  echo "   Install the script files in this directory into the bin directory." 1>&2
  echo "   If a user runs it, $HOME is chosen as the parent directory of the bin directory." 1>&2
  echo "   If the root runs it, /usr/local is chosen as the parent directory of the bin directory." 1>&2
  echo "Option:" 1>&2
  echo "   --help: Show this help message." 1>&2
  exit 1
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

me=$(whoami)

# install commands
if [[ ! -d $bin ]] ; then
  mkdir $bin
fi
for src in $binfiles; do
  dst=$(echo $src | sed 's/\..*$//')
  cp $src $bin/$dst
  chown ${me}:${me} $bin/$dst
  chmod 755 $bin/$dst
done

