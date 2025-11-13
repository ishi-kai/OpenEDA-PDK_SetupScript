#!/bin/bash
# ========================================================================
# Initialization of IIC Open-Source EDA Environment for Ubuntu WSL2
# This script is for use with SG13G2.
# ========================================================================

# Define setup environment
# ------------------------
export PDK_ROOT="$HOME/pdk"
export MY_STDCELL=sg13g2_stdcells
export SRC_DIR="$HOME/src"
my_path=$(realpath "$0")
my_dir=$(dirname "$my_path")
export SCRIPT_DIR="$my_dir"
export PDK_GIT_NAME="IHP-Open-PDK"
export PDK_NAME="ihp-sg13g2"
export PDK="$PDK_GIT_NAME/$PDK_NAME"
export OPENVAF_VERSION="_23_5_0_"

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


# Delete previous PDK
# ---------------------------------------------
if [ -d "$PDK_ROOT" ]; then
	echo ">>>> Delete previous PDK"
	rm -rf "$PDK_ROOT"
fi
mkdir "$PDK_ROOT"


# Install OpenVAF
# -----------------------------------
echo ">>>> Install OpenVAF"
if [ "$(uname)" == 'Darwin' ]; then
	OS='Mac'
	echo ">>>> Not supported OpenVAF on macOS."
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
	OS='Linux'
	cd $HOME
	mkdir bin
	cd bin
	wget https://openva.fra1.cdn.digitaloceanspaces.com/openvaf$OPENVAF_VERSIONlinux_amd64.tar.gz
	tar zxf openvaf$OPENVAF_VERSIONlinux_amd64.tar.gz
	rm openvaf$OPENVAF_VERSIONlinux_amd64.tar.gz
	mv openvaf.exe openvaf
	export PATH=$HOME/bin:$PATH
elif [ "$(expr substr $(uname -s) 1 10)" == 'MINGW32_NT' ]; then
	OS='Cygwin'
	echo "Your platform ($(uname -a)) is not supported."
	exit 1
else
	echo "Your platform ($(uname -a)) is not supported."
	exit 1
fi


# Install PDK
# -----------------------------------
if [ ! -d "$PDK_ROOT/$PDK_GIT_NAME" ]; then
  cd $PDK_ROOT
  git clone --recursive https://github.com/IHP-GmbH/IHP-Open-PDK.git
  cd $PDK_GIT_NAME
else
	echo ">>>> Updating xschem"
	cd "$SRC_DIR/$PDK_GIT_NAME" || exit
	git pull
fi

if [ "$(uname)" == 'Darwin' ]; then
	OS='Mac'
	python3 -m pip install -r requirements.txt pip-autoremove --break-system-packages
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
	OS='Linux'
	pip3 install -r requirements.txt
fi
cd $PDK_NAME/libs.tech/xschem/
export PDK_ROOT="$HOME/pdk/$PDK_GIT_NAME"
python3 install.py
export PDK_ROOT="$HOME/pdk"
export PYTHONPYCACHEPREFIX=/tmp

# Copy KLayout Configurations
# ----------------------------------
if [ ! -d "$HOME/.klayout" ]; then
	mkdir $HOME/.klayout
fi
if [ ! -d "$HOME/.klayout/tech" ]; then
	mkdir -p $HOME/.klayout/tech/
fi
if [ ! -d "$HOME/.klayout/libraries" ]; then
	mkdir -p $HOME/.klayout/libraries
fi
cp -f $PDK_ROOT/$PDK/libs.tech/klayout/tech/sg13g2.lyp $HOME/.klayout/tech/
cp -f $PDK_ROOT/$PDK/libs.tech/klayout/tech/sg13g2.lyt $HOME/.klayout/tech/

cp -rf $PDK_ROOT/$PDK/libs.tech/klayout/tech/drc $HOME/.klayout/
cp -rf $PDK_ROOT/$PDK/libs.tech/klayout/tech/lvs $HOME/.klayout/
cp -rf $PDK_ROOT/$PDK/libs.tech/klayout/tech/macros $HOME/.klayout/
cp -rf $PDK_ROOT/$PDK/libs.tech/klayout/tech/pymacros $HOME/.klayout/
cp -rf $PDK_ROOT/$PDK/libs.tech/klayout/python $HOME/.klayout/
ln -s $HOME/.klayout/python/pycell4klayout-api/source/python/cni/ $HOME/.klayout/python/cni


# Install OpenEMS
# -----------------------------------
echo ">>>> Install OpenEMS"
#if [ "$(uname)" == 'Darwin' ]; then
#  OS='Mac'
#  if [ ! -d "$HOME/Library/Caches/Homebrew/openems--git/" ]; then
#	  brew install cmake boost tinyxml hdf5 cgal vtk octave paraview
#	  python3 -m pip install cython numpy h5py matplotlib pip-autoremove --break-system-packages
#	  brew tap thliebig/openems https://github.com/thliebig/openEMS-Project.git
#	  brew install --HEAD openems
#	  cd $HOME/Library/Caches/Homebrew/openems--git/
#	  cd CSXCAD
#	  cd python
#	  python3 -m pip install . --user pip-autoremove --break-system-packages
#	  cd ..
#	  cd openEMS
#	  cd python
#	  python3 -m pip install . --user pip-autoremove --break-system-packages
#	  cd ..
#	  echo 'export PATH="$(brew --prefix)/opt/openEMS/bin:$PATH"' >> ~/.zshrc
#	  echo 'addpath("$(brew --prefix)/share/openEMS/matlab:$(brew --prefix)/share/CSXCAD/matlab:$(brew --prefix)/share/hyp2mat/matlab:$(brew --prefix)/share/CTB/matlab");' >> ~/.octaverc
#  else
#	  brew upgrade --fetch-HEAD openems
#  fi

cd $SRC_DIR
if [ "$(uname)" == 'Darwin' ]; then
  OS='Mac'
  if [ ! -d "$SRC_DIR/openEMS-Project" ]; then
	  brew install cmake boost tinyxml hdf5 cgal vtk octave paraview
	  python3 -m pip install cython numpy h5py matplotlib pip-autoremove --break-system-packages
	  echo 'export PATH="$HOME/opt/openEMS/bin:$PATH"' >> ~/.zshrc
	  echo 'addpath("$HOME/opt/openEMS/share/CSXCAD/matlab:$HOME/opt/openEMS/share/CSXCAD/matlab:$HOME/opt/openEMS/share/hyp2mat/matlab:$HOME/opt/openEMS/share/CTB/matlab");' >> ~/.octaverc
  fi
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  OS='Linux'
  if [ ! -d "$SRC_DIR/openEMS-Project" ]; then
	  sudo apt-get install -y build-essential cmake git libhdf5-dev libvtk7-dev libboost-all-dev libcgal-dev libtinyxml-dev qtbase5-dev libvtk7-qt-dev octave liboctave-dev gengetopt hel  p2man groff pod2pdf bison flex libhpdf-dev libtool qtbase5-dev libvtk9-qt-dev paraview
	  pip3 install numpy matplotlib cython h5py
	  echo 'export PATH="$HOME/bin:$HOME/.local/bin:$HOME/opt/openEMS/bin:$PATH"' >> ~/.bashrc
	  echo 'addpath("$HOME/opt/openEMS/share/CSXCAD/matlab:$HOME/opt/openEMS/share/CSXCAD/matlab:$HOME/opt/openEMS/share/hyp2mat/matlab:$HOME/opt/openEMS/share/CTB/matlab");' >> ~/.octaverc
  fi
elif [ "$(expr substr $(uname -s) 1 10)" == 'MINGW32_NT' ]; then
  OS='Cygwin'
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
else
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
fi
if [ ! -d "$SRC_DIR/openEMS-Project" ]; then
  git clone --recursive https://github.com/thliebig/openEMS-Project.git
  cd openEMS-Project
else
  cd openEMS-Project
  git pull --recurse-submodules
fi
./update_openEMS.sh ~/opt/openEMS --with-hyp2mat --with-CTB --python

if [ "$(uname)" == 'Darwin' ]; then
  OS='Mac'

elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  OS='Linux'
  mv $HOME/.local/lib/python3.10/site-packages/CSXCAD-0.6.2-py3.10-linux-x86_64.egg $HOME/.local/lib/python3.10/site-packages/CSXCAD-0.6.2-py3.10-linux-x86_64.egg.zip
  mkdir $HOME/.local/lib/python3.10/site-packages/CSXCAD-0.6.2-py3.10-linux-x86_64.egg
  mv $HOME/.local/lib/python3.10/site-packages/CSXCAD-0.6.2-py3.10-linux-x86_64.egg.zip $HOME/.local/lib/python3.10/site-packages/CSXCAD-0.6.2-py3.10-linux-x86_64.egg/
  cd $HOME/.local/lib/python3.10/site-packages/CSXCAD-0.6.2-py3.10-linux-x86_64.egg/
  unzip CSXCAD-0.6.2-py3.10-linux-x86_64.egg.zip

  mv $HOME/.local/lib/python3.10/site-packages/openEMS-0.0.36-py3.10-linux-x86_64.egg  $HOME/.local/lib/python3.10/site-packages/openEMS-0.0.36-py3.10-linux-x86_64.egg.zip
  mkdir $HOME/.local/lib/python3.10/site-packages/openEMS-0.0.36-py3.10-linux-x86_64.egg
  mv $HOME/.local/lib/python3.10/site-packages/openEMS-0.0.36-py3.10-linux-x86_64.egg.zip $HOME/.local/lib/python3.10/site-packages/openEMS-0.0.36-py3.10-linux-x86_64.egg/
  cd $HOME/.local/lib/python3.10/site-packages/openEMS-0.0.36-py3.10-linux-x86_64.egg/
  unzip openEMS-0.0.36-py3.10-linux-x86_64.egg.zip
fi

cd $SRC_DIR


# Setup ngspice libs
# -----------------
export PDK_ROOT=$PDK_ROOT/$PDK_GIT_NAME
export PDK=$PDK_NAME
cd $PDK_ROOT/$PDK/libs.tech/xschem/
sed -i 's/openvaf psp103_nqs.va/openvaf --target x86_64-unknown-linux psp103_nqs.va/g' install.py
python3 install.py
cd $SRC_DIR


# Setup Qucs-S libs
# -----------------
export PDK_ROOT=$PDK_ROOT/$PDK_GIT_NAME
export PDK=$PDK_NAME
cd $PDK_ROOT/$PDK/libs.tech/qucs/
sed -i 's/openvaf psp103_nqs.va/openvaf --target x86_64-unknown-linux psp103_nqs.va/g' install.py
python3 install.py
cd $SRC_DIR


# Setup Xyce libs
# -----------------
cd $PDK_ROOT/$PDK/libs.tech/xyce/adms/
buildxyceplugin psp103.va .
cp Xyce_Plugin_PSP103_VA.so ../../xschem/simulations/
mv Xyce_Plugin_PSP103_VA.so ../../xschem/examples/
echo 'Xyce on xschem Usage: mpirun /usr/local/bin/Xyce -plugin $env(PDK_ROOT)/$env(PDK)/libs.tech/xyce/adms/Xyce_Plugin_PSP103_VA.so "$N"'


# Copy various things
# -------------------
rm $HOME/.xschem/xschemrc
cp -f $PDK_ROOT/$PDK/libs.tech/xschem/xschemrc $HOME/.xschem/


# Create .spiceinit
# -----------------
{
	echo "set num_threads=$(nproc)"
} >> "$HOME/.spiceinit"

# Create iic-init.sh
# ------------------
if [ ! -d "$HOME/.xschem" ]; then
	mkdir "$HOME/.xschem"
fi
{
	echo "export PDK_ROOT=$PDK_ROOT"
	echo "export PDK=$PDK"
	echo "export STD_CELL_LIBRARY=$MY_STDCELL"
	echo "export PYTHONPYCACHEPREFIX=/tmp"
	echo 'export PATH="$HOME/bin:$PATH"'
} >> "$HOME/.bashrc"


# Fix paths in xschemrc to point to correct PDK directory
# -------------------------------------------------------

# Finished
# --------
echo ""
echo ">>>> All done. Please restart or re-read .bashrc"
echo ">>>> "
echo '>>>> Xyce on xschem Usage: mpirun /usr/local/bin/Xyce -plugin $env(PDK_ROOT)/$env(PDK)/libs.tech/xyce/adms/Xyce_Plugin_PSP103_VA.so "$N"'
echo ""
