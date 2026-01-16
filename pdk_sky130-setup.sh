#!/bin/bash
# ========================================================================
# Initialization of IIC Open-Source EDA Environment for Ubuntu WSL2 and macOS.
# This script is for use with SKY130.
# ========================================================================

# Define setup environment
# ------------------------
export PDK_ROOT="$HOME/pdk"
export MY_STDCELL=sky130_fd_sc_hd
export SRC_DIR="$HOME/src"
my_path=$(realpath "$0")
my_dir=$(dirname "$my_path")
export SCRIPT_DIR="$my_dir"
export PDK=sky130A
# ciel ls-remote --pdk sky130
export CIEL_H=54435919abffb937387ec956209f9cf5fd2dfbee

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
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  OS='Linux'
  VERSION_ID=`lsb_release -a`
fi



# --------
echo ""
echo ">>>> Initializing..."
echo ""

echo ">>>> Installing Ciel"
if [ ! -d "$SRC_DIR/ciel" ]; then
	git clone https://github.com/fossi-foundation/ciel "$SRC_DIR/ciel"
	cd "$SRC_DIR/ciel" || exit
else
	echo ">>>> Updating ciel"
	cd "$SRC_DIR/ciel" || exit
	git pull
fi

if [ "$(uname)" == 'Darwin' ]; then
  OS='Mac'
  python3 -m pip install --upgrade --no-cache-dir ciel --break-system-packages
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  OS='Linux'
  sudo apt install libcurl4-openssl-dev
  if [ "$(expr substr $VERSION_ID 1 5)" == '22.04' ]; then
    python3 -m pip install --upgrade --no-cache-dir ciel
  elif [ "$(expr substr $VERSION_ID 1 5)" == '24.04' ]; then
    python3 -m pip install --upgrade --no-cache-dir ciel --break-system-packages
  elif [ "$(expr substr $VERSION_ID 1 5)" == '26.04' ]; then
    python3 -m pip install --upgrade --no-cache-dir ciel --break-system-packages
  else
    echo "Your platform Ubuntu $VERSION_ID is not supported."
  fi
elif [ "$(expr substr $(uname -s) 1 10)" == 'MINGW32_NT' ]; then
  OS='Cygwin'
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
else
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
fi


# Copy KLayout Configurations
# ----------------------------------
if [ ! -d "$HOME/.klayout" ]; then
	# cp -rf klayout $HOME/.klayout
	mkdir $HOME/.klayout
	mkdir $HOME/.klayout/libraries
	mkdir $HOME/.klayout/d25
	mkdir $HOME/.klayout/drc
	mkdir $HOME/.klayout/lvs
	mkdir $HOME/.klayout/macros
	mkdir $HOME/.klayout/pymacros
	mkdir $HOME/.klayout/python
	mkdir $HOME/.klayout/tech
fi
cd $my_dir
cp -f sky130/klayoutrc $HOME/.klayout/

# Delete previous PDK
# ---------------------------------------------
if [ -d "$PDK_ROOT" ]; then
	echo ">>>> Delete previous PDK"
	sudo rm -rf "$PDK_ROOT"
	sudo mkdir "$PDK_ROOT"
	sudo chown "$USER:staff" "$PDK_ROOT"
fi

# Install PDK
# -----------------------------------
if [ "$(uname)" == 'Darwin' ]; then
	OS='Mac'
	python3 -m pip install sky130 flayout pip-autoremove --break-system-packages
	ciel enable --pdk sky130 $CIEL_H
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
	OS='Linux'
	if [ "$(expr substr $VERSION_ID 1 5)" == '22.04' ]; then
		pip install sky130 flayout
		ciel enable --pdk sky130 $CIEL_H
	elif [ "$(expr substr $VERSION_ID 1 5)" == '24.04' ]; then
		pip install sky130 flayout --break-system-packages
		ciel enable --pdk sky130 $CIEL_H
	elif [ "$(expr substr $VERSION_ID 1 5)" == '26.04' ]; then
		pip install sky130 flayout --break-system-packages
		ciel enable --pdk sky130 $CIEL_H
	else
		echo "Your platform Ubuntu $VERSION_ID is not supported."
	fi
elif [ "$(expr substr $(uname -s) 1 10)" == 'MINGW32_NT' ]; then
	OS='Cygwin'
	echo "Your platform ($(uname -a)) is not supported."
	exit 1
else
	echo "Your platform ($(uname -a)) is not supported."
	exit 1
fi



# Create .spiceinit
# -----------------
{
	echo "set num_threads=$(nproc)"
	echo "set ngbehavior=hsa"
	echo "set ng_nomodcheck"
} > "$HOME/.spiceinit"


# Create iic-init.sh
# ------------------
if [ ! -d "$HOME/.xschem" ]; then
	mkdir "$HOME/.xschem"
fi
if [ "$(uname)" == 'Darwin' ]; then
	OS='Mac'
	{
		echo "export PDK_ROOT=$PDK_ROOT"
		echo "export PDK=$PDK"
		echo "export STD_CELL_LIBRARY=$MY_STDCELL"
	} >> "$HOME/.zshrc"
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
	OS='Linux'
	{
		echo "export PDK_ROOT=$PDK_ROOT"
		echo "export PDK=$PDK"
		echo "export STD_CELL_LIBRARY=$MY_STDCELL"
	} >> "$HOME/.bashrc"
elif [ "$(expr substr $(uname -s) 1 10)" == 'MINGW32_NT' ]; then
	OS='Cygwin'
	echo "Your platform ($(uname -a)) is not supported."
	exit 1
else
	echo "Your platform ($(uname -a)) is not supported."
	exit 1
fi



# Copy various things
# -------------------
export PDK_ROOT=$PDK_ROOT
export PDK=$PDK
export STD_CELL_LIBRARY=$MY_STDCELL
cd $my_dir
cp -f $PDK_ROOT/$PDK/libs.tech/xschem/xschemrc $HOME/.xschem
cp -f $PDK_ROOT/$PDK/libs.tech/magic/$PDK.magicrc $HOME/.magicrc

cp -rf $PDK_ROOT/$PDK/libs.tech/klayout/macros/* $HOME/.klayout/macros/
cp -rf $PDK_ROOT/$PDK/libs.tech/klayout/drc/* $HOME/.klayout/drc/
cp -rf $PDK_ROOT/$PDK/libs.tech/klayout/lvs/* $HOME/.klayout/lvs/
cp -rf $PDK_ROOT/$PDK/libs.tech/klayout/macros/* $HOME/.klayout/macros/
cp -rf $PDK_ROOT/$PDK/libs.tech/klayout/pymacros/* $HOME/.klayout/pymacros/
cp -rf $PDK_ROOT/$PDK/libs.tech/klayout/python/* $HOME/.klayout/python/
cp -rf $PDK_ROOT/$PDK/libs.tech/klayout/tech/* $HOME/.klayout/tech/
cp -f $PDK_ROOT/$PDK/libs.ref/sky130_fd_pr/gds/sky130_fd_pr.gds $HOME/.klayout/libraries/
cp -f $PDK_ROOT/$PDK/libs.ref/sky130_fd_sc_hd/gds/sky130_fd_sc_hd.gds $HOME/.klayout/libraries/

cd $my_dir
cp -rf sky130/macros/* $HOME/.klayout/macros/



# Fix paths in xschemrc to point to correct PDK directory
# -------------------------------------------------------
if [ "$(uname)" == 'Darwin' ]; then
	OS='Mac'
	echo 'set XSCHEM_LIBRARY_PATH {}' >> "$HOME/.xschem/xschemrc"
	echo 'append XSCHEM_LIBRARY_PATH :$env(PWD)' >> "$HOME/.xschem/xschemrc"
	echo 'append XSCHEM_LIBRARY_PATH :$env(PDK_ROOT)/$env(PDK)/libs.tech/xschem' >> "$HOME/.xschem/xschemrc"
	echo 'append XSCHEM_LIBRARY_PATH :${XSCHEM_SHAREDIR}/xschem_library' >> "$HOME/.xschem/xschemrc"
	sed -i -e '' 's/^set SKYWATER_MODELS/# set SKYWATER_MODELS/g' "$HOME/.xschem/xschemrc"
	echo 'set SKYWATER_MODELS $env(PDK_ROOT)/$env(PDK)/libs.tech/ngspice' >> "$HOME/.xschem/xschemrc"
	sed -i -e '' 's/^set SKYWATER_STDCELLS/# set SKYWATER_STD_CELLS/g' "$HOME/.xschem/xschemrc"
	echo 'set SKYWATER_STDCELLS $env(PDK_ROOT)/$env(PDK)/libs.ref/sky130_fd_sc_hd/spice' >> "$HOME/.xschem/xschemrc"
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
	OS='Linux'
	echo 'set XSCHEM_LIBRARY_PATH {}' >> "$HOME/.xschem/xschemrc"
	echo 'append XSCHEM_LIBRARY_PATH :$env(PWD)' >> "$HOME/.xschem/xschemrc"
	echo 'append XSCHEM_LIBRARY_PATH :$env(PDK_ROOT)/$env(PDK)/libs.tech/xschem' >> "$HOME/.xschem/xschemrc"
	echo 'append XSCHEM_LIBRARY_PATH :${XSCHEM_SHAREDIR}/xschem_library' >> "$HOME/.xschem/xschemrc"
	sed -i -e 's/^set SKYWATER_MODELS/# set SKYWATER_MODELS/g' "$HOME/.xschem/xschemrc"
	echo 'set SKYWATER_MODELS $env(PDK_ROOT)/$env(PDK)/libs.tech/ngspice' >> "$HOME/.xschem/xschemrc"
	sed -i -e 's/^set SKYWATER_STDCELLS/# set SKYWATER_STD_CELLS/g' "$HOME/.xschem/xschemrc"
	echo 'set SKYWATER_STDCELLS $env(PDK_ROOT)/$env(PDK)/libs.ref/sky130_fd_sc_hd/spice' >> "$HOME/.xschem/xschemrc"
elif [ "$(expr substr $(uname -s) 1 10)" == 'MINGW32_NT' ]; then
	OS='Cygwin'
	echo "Your platform ($(uname -a)) is not supported."
	exit 1
else
	echo "Your platform ($(uname -a)) is not supported."
	exit 1
fi


# Finished
# --------
echo ""
echo ">>>> All done. Please restart or re-read .bashrc"
echo ""
