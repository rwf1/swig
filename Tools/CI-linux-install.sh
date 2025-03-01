#!/bin/bash
# expected to be called from elsewhere with certain variables set
# e.g. RETRY=travis-retry SWIGLANG=python GCC=7
set -e # exit on failure (same as -o errexit)

if [[ -n "$GCC" ]]; then
	$RETRY sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
	$RETRY sudo apt-get -qq update
	$RETRY sudo apt-get install -qq g++-$GCC
fi

$RETRY sudo apt-get -qq install libboost-dev libpcre3-dev
# testflags.py needs python
$RETRY sudo apt-get install -qq python

WITHLANG=$SWIGLANG

case "$SWIGLANG" in
	"")     ;;
	"csharp")
		$RETRY sudo apt-get -qq install mono-devel
		;;
	"d")
		$RETRY wget http://downloads.dlang.org/releases/2.x/${VER}/dmd_${VER}-0_amd64.deb
		$RETRY sudo dpkg -i dmd_${VER}-0_amd64.deb
		;;
	"go")
		if [[ "$VER" ]]; then
		  eval "$(gimme ${VER}.x)"
		fi
		;;
	"javascript")
		case "$ENGINE" in
			"node")
				$RETRY wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.10/install.sh | bash
				export NVM_DIR="$HOME/.nvm"
				[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
				$RETRY nvm install ${VER}
				nvm use ${VER}
				if [ "$VER" == "0.10" ] || [ "$VER" == "0.12" ] || [ "$VER" == "4" ] || [ "$VER" == "6" ] ; then
#					$RETRY sudo apt-get install -qq nodejs node-gyp
					$RETRY npm install -g node-gyp@$VER
				elif [ "$VER" == "8" ] ; then
					$RETRY npm install -g node-gyp@6
				elif [ "$VER" == "10" ] || [ "$VER" == "12" ] || [ "$VER" == "14" ]  || [ "$VER" == "16" ]; then
					$RETRY npm install -g node-gyp@7
				else
					$RETRY npm install -g node-gyp
				fi
				;;
			"jsc")
				$RETRY sudo apt-get install -qq libwebkitgtk-dev
				;;
			"v8")
				$RETRY sudo apt-get install -qq libv8-dev
				;;
		esac
		;;
	"guile")
		$RETRY sudo apt-get -qq install guile-2.0-dev
		;;
	"lua")
		if [[ -z "$VER" ]]; then
			$RETRY sudo apt-get -qq install lua5.2 liblua5.2-dev
		else
			$RETRY sudo apt-get -qq install lua${VER} liblua${VER}-dev
		fi
		;;
	"mzscheme")
		$RETRY sudo apt-get -qq install racket
		;;
	"ocaml")
		$RETRY sudo apt-get -qq install ocaml camlp4
		;;
	"octave")
		if [[ "$OCTAVE_USE_FLATPAK" ]]; then
			$RETRY sudo apt-get -qq install flatpak
			$RETRY sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
			$RETRY sudo flatpak install --system --assumeyes --noninteractive flathub org.octave.Octave
		else
			$RETRY sudo apt-get -qq install liboctave-dev
		fi
		;;
	"php")
		$RETRY sudo add-apt-repository -y ppa:ondrej/php
		$RETRY sudo apt-get -qq update
		$RETRY sudo apt-get -qq install php$VER-cli php$VER-dev
		;;
	"python")
		pip install --user pycodestyle
		if [[ "$VER" ]]; then
			$RETRY sudo add-apt-repository -y ppa:deadsnakes/ppa
			$RETRY sudo apt-get -qq update
			$RETRY sudo apt-get -qq install python${VER}-dev
			WITHLANG=$SWIGLANG$PY3=$SWIGLANG$VER
                else
		        $RETRY sudo apt-get install -qq python${PY3}-dev
		        WITHLANG=$SWIGLANG$PY3
		fi
		;;
	"r")
		$RETRY sudo apt-get -qq install r-base
		;;
	"ruby")
		if [[ "$VER" == "2.7" || "$VER" == "3.0" ]]; then
			# Ruby 2.7+ support is currently only rvm master (30 Dec 2019)
			$RETRY rvm get master
			rvm reload
			rvm list known
		fi
		if [[ "$VER" ]]; then
			$RETRY rvm install $VER
		fi
		;;
	"scilab")
		# Travis has the wrong version of Java pre-installed resulting in error using scilab:
		# /usr/bin/scilab-bin: error while loading shared libraries: libjava.so: cannot open shared object file: No such file or directory
		echo "JAVA_HOME was set to $JAVA_HOME"
		unset JAVA_HOME
		$RETRY sudo apt-get -qq install scilab
		;;
	"tcl")
		$RETRY sudo apt-get -qq install tcl-dev
		;;
esac

set +e # turn off exit on failure (same as +o errexit)
