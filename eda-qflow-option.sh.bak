#!/bin/bash
# ========================================================================
# QFlow options for Ubuntu WSL2 and macOS.
# ========================================================================

# Define setup environment
# ------------------------
export PDK_ROOT="$HOME/pdk"
export SRC_DIR="$HOME/src"
my_path=$(realpath "$0")
my_dir=$(dirname "$my_path")
export SCRIPT_DIR="$my_dir"

export TCL_VERSION=8.6.14
export TK_VERSION=8.6.14
export GTK_VERSION=3.24.42

# for Mac
if [ "$(uname)" == 'Darwin' ]; then
  VER=`sw_vers -productVersion | awk -F. '{ print $1 }'`
  case $VER in
    "14")
      export MAC_OS_NAME=Sonoma
      export CC_VERSION=-14
      export CXX_VERSION=-14
      ;;
    "15")
      export MAC_OS_NAME=Sequoia
      export CC_VERSION=-14
      export CXX_VERSION=-14
      ;;
    "26")
      export MAC_OS_NAME=Tahoe
      export CC_VERSION=-15
      export CXX_VERSION=-15
      ;;
    *)
      echo "Your Mac OS Version ($VER) is not supported."
      exit 1
      ;;
  esac
  export MAC_ARCH_NAME=`uname -m`
fi

# Install/update qrouter
# --------------------
if [ ! -d "$SRC_DIR/qrouter" ]; then
	echo ">>>> Installing qrouter"
	git clone https://github.com/RTimothyEdwards/qrouter.git "$SRC_DIR/qrouter"
	cd "$SRC_DIR/qrouter" || exit
	if [ "$(uname)" == 'Darwin' ]; then
		OS='Mac'
		./configure CFLAGS="-Wno-error=implicit-int"
		sed -i '' 's/-noprebind/ /g' Makefile
	elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
		OS='Linux'
		./configure
	elif [ "$(expr substr $(uname -s) 1 10)" == 'MINGW32_NT' ]; then
		OS='Cygwin'
		echo "Your platform ($(uname -a)) is not supported."
		exit 1
	else
		echo "Your platform ($(uname -a)) is not supported."
		exit 1
	fi
else
	echo ">>>> Updating qrouter"
	cd "$SRC_DIR/qrouter" || exit
	git pull
fi
make && sudo make install
make clean

# Install/update graywolf
# --------------------
if [ ! -d "$SRC_DIR/graywolf" ]; then
	echo ">>>> Installing graywolf"
	if [ "$(uname)" == 'Darwin' ]; then
		OS='Mac'
		brew install cmake
		brew install gsl
		brew install libx11
		brew install gsed
		git clone https://github.com/rubund/graywolf.git "$SRC_DIR/graywolf"
		cd "$SRC_DIR/graywolf" || exit
		sed -i '' 's/\*strrchr()\, \*strcat()/\*strrchr()/g' src/Ylib/relpath.c
		sed -i '' 's/(VOID)/ /g' src/genrows/draw.c
		sed -i '' 's/date = getCompileDate()/0/g' src/Ylib/program.c
		sed -i '' 's/char    \*date \,/char    \*date/g' src/Ylib/program.c
		sed -i '' 's/\*getCompileDate()/ /g' src/Ylib/program.c
		gsed -i '7iSET(CMAKE_C_FLAGS "-Wno-dev -Wno-error=implicit-int -Wno-error=int-conversion -Wno-error=implicit-function-declaration -Wno-error=return-type -Wno-error=return-mismatch -Wno-error=format -I/opt/X11/include -I/opt/homebrew/Cellar/gsl/${GSL_VERSION}/include/ -L/opt/X11/lib -L/opt/homebrew/Cellar/gsl/${GSL_VERSION}/lib")' CMakeLists.txt
	elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
		OS='Linux'
		sudo apt -qq install -y libgsl-dev
		git clone https://github.com/RTimothyEdwards/graywolf.git "$SRC_DIR/graywolf"
		cd "$SRC_DIR/graywolf" || exit
	elif [ "$(expr substr $(uname -s) 1 10)" == 'MINGW32_NT' ]; then
		OS='Cygwin'
		echo "Your platform ($(uname -a)) is not supported."
		exit 1
	else
		echo "Your platform ($(uname -a)) is not supported."
		exit 1
	fi
else
	echo ">>>> Updating graywolf"
	cd "$SRC_DIR/graywolf" || exit
	git pull
fi
mkdir build
cd build
cmake ..
make  
sudo make install  

# Install/update yosys
# --------------------
if [ ! -d "$SRC_DIR/yosys" ]; then
	echo ">>>> Installing yosys"
	git clone https://github.com/YosysHQ/yosys.git "$SRC_DIR/yosys"
	cd "$SRC_DIR/yosys" || exit
	git submodule update --init
	if [ "$(uname)" == 'Darwin' ]; then
		OS='Mac'
		brew install bison flex readline gawk libffi git graphviz pkgconfig boost zlib m4
		export PATH="/opt/homebrew/opt/m4/bin:$PATH"
	elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
		OS='Linux'
		sudo apt -qq install -y clang bison flex \
		libreadline-dev gawk tcl-dev libffi-dev git \
		graphviz xdot pkg-config python3 libboost-system-dev \
		libboost-python-dev libboost-filesystem-dev zlib1g-dev
	elif [ "$(expr substr $(uname -s) 1 10)" == 'MINGW32_NT' ]; then
		OS='Cygwin'
		echo "Your platform ($(uname -a)) is not supported."
		exit 1
	else
		echo "Your platform ($(uname -a)) is not supported."
		exit 1
	fi
else
	echo ">>>> Updating yosys"
	cd "$SRC_DIR/yosys" || exit
	git pull
	if [ "$(uname)" == 'Darwin' ]; then
		OS='Mac'
		export PATH="/opt/homebrew/opt/m4/bin:$PATH"
	fi
fi
make config-clang
make -j"$(nproc)" && sudo make install
make clean

# Install/update qflow
# --------------------
if [ ! -d "$SRC_DIR/qflow" ]; then
	echo ">>>> Installing qflow"
	git clone https://github.com/RTimothyEdwards/qflow.git "$SRC_DIR/qflow"
	cd "$SRC_DIR/qflow" || exit
	if [ "$(uname)" == 'Darwin' ]; then
		OS='Mac'
		brew install python-tk
	elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
		OS='Linux'
		sudio apt -qq install -y python-tk
	elif [ "$(expr substr $(uname -s) 1 10)" == 'MINGW32_NT' ]; then
		OS='Cygwin'
		echo "Your platform ($(uname -a)) is not supported."
		exit 1
	else
		echo "Your platform ($(uname -a)) is not supported."
		exit 1
	fi
else
	echo ">>>> Updating yosys"
	cd "$SRC_DIR/qflow" || exit
	git pull
fi
./configure
make && sudo make install
make clean