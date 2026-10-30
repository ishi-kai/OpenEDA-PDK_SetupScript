#!/bin/bash
# ========================================================================
# Initialization of IIC Open-Source EDA Environment for OpenRule1umPDK
#
# SPDX-FileCopyrightText: 2023-2025 Mori Mizuki, Noritsuna Imamura 
# ISHI-KAI
# 
# SPDX-FileCopyrightText: 2021-2022 Harald Pretl, Johannes Kepler 
# University, Institute for Integrated Circuits
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0
#
# This script installs Xyce (with Trilinos and ADMS).
# This script supports WSL(Windows Subsystem for Linux), Ubuntu 22.04/24.04.
# ========================================================================

# Exit immediately if a command fails
set -e

# Define setup environment
# ------------------------
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

# ---------------
# Now go to work!
# ---------------

# Update installation
# ----------------------------------
# the sed is needed for xschem build
echo ">>>> Update packages"
if [ "$(uname)" == 'Darwin' ]; then
  OS='Mac'
  if [ ! -d "/opt/homebrew" ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> $HOME/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
    brew update
    brew upgrade
    brew install wget
  fi
  brew update
  brew upgrade
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  OS='Linux'
  if [ -f /etc/apt/sources.list ]; then
    sudo sed -i 's/# deb-src/deb-src/g' /etc/apt/sources.list
  fi
  sudo apt -qq update -y
  sudo apt -qq upgrade -y
elif [ "$(expr substr $(uname -s) 1 10)" == 'MINGW32_NT' ]; then
  OS='Cygwin'
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
else
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
fi
mkdir -p $SRC_DIR
cd $SRC_DIR


# Build mode: parallel(MPI, default), serial or all
#   bash eda-xyce-option.sh          -> parallel(MPI) build into /usr/local
#   bash eda-xyce-option.sh serial   -> serial build into /usr/local
#   bash eda-xyce-option.sh all      -> parallel(MPI) build into /usr/local and
#                                       serial build into /usr/local/xyce_serial
#                                       (/usr/local/bin/Xyce_serial)
# ----------------------------------
case "$1" in
  ''|mpi)
    XYCE_BUILD_MPI=1
    XYCE_BUILD_SERIAL=0
    ;;
  serial)
    XYCE_BUILD_MPI=0
    XYCE_BUILD_SERIAL=1
    ;;
  all)
    XYCE_BUILD_MPI=1
    XYCE_BUILD_SERIAL=1
    ;;
  *)
    echo "Usage: bash $0 [mpi|serial|all]"
    exit 1
    ;;
esac
export XYCE_INSTALL_DIR=/usr/local
export XYCE_SERIAL_INSTALL_DIR=/usr/local/xyce_serial
export TRILINOS_VERSION=14-4-0
export XYCE_VERSION=7.10.0
export CMAKE_MIN_VERSION=3.23.0
export CMAKE_DL_VERSION=3.31.8
export NPROC=$(nproc)


# Install Xyce
# ----------------------------------
echo ">>>> Install Xyce"
if [ "$(uname)" == 'Darwin' ]; then
  OS='Mac'
  echo "Xyce installation on macOS is not supported by this script."
  exit 1
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  OS='Linux'
  sudo apt -qq install -y build-essential gcc g++ gfortran make cmake git wget bc \
    autoconf automake libtool bison flex libfl-dev gperf libxml-libxml-perl \
    libblas-dev liblapack-dev libfftw3-dev libsuitesparse-dev \
    libmatio-dev gnuplot-x11
  if [ $XYCE_BUILD_MPI -eq 1 ]; then
    sudo apt -qq install -y libopenmpi-dev openmpi-bin
  fi

  # CMake (Trilinos 14.4 requires CMake 3.23 or later)
  CMAKE_CUR_VERSION=$(cmake --version | head -1 | awk '{print $3}')
  if [ "$(printf '%s\n' $CMAKE_MIN_VERSION $CMAKE_CUR_VERSION | sort -V | head -1)" != "$CMAKE_MIN_VERSION" ]; then
    echo ">>>> CMake $CMAKE_CUR_VERSION is too old. Use CMake $CMAKE_DL_VERSION"
    cd $SRC_DIR
    CMAKE_DL_NAME=cmake-$CMAKE_DL_VERSION-linux-$(uname -m)
    if [ ! -d $CMAKE_DL_NAME ]; then
      wget https://github.com/Kitware/CMake/releases/download/v$CMAKE_DL_VERSION/$CMAKE_DL_NAME.tar.gz
      tar zxf $CMAKE_DL_NAME.tar.gz
    fi
    export PATH=$SRC_DIR/$CMAKE_DL_NAME/bin:$PATH
  fi

  # ADMS (admsXml: required for Verilog-A plugin)
  cd $SRC_DIR
  if [ ! -d ADMS ]; then
    git clone https://github.com/Qucs/ADMS.git
  fi
  cd ADMS
  mkdir -p build
  cd build
  cmake ../ -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=$XYCE_INSTALL_DIR \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5
  make -j$NPROC
  sudo make install
  sudo ldconfig

  # Xyce source (Trilinos configuration uses Xyce's cache files)
  cd $SRC_DIR
  if [ ! -f Xyce-Release-$XYCE_VERSION.tar.gz ]; then
    wget -O Xyce-Release-$XYCE_VERSION.tar.gz https://github.com/Xyce/Xyce/archive/refs/tags/Release-$XYCE_VERSION.tar.gz
  fi
  rm -rf Xyce-Release-$XYCE_VERSION
  tar zxf Xyce-Release-$XYCE_VERSION.tar.gz
  export XYCE_SRC_DIR=$SRC_DIR/Xyce-Release-$XYCE_VERSION
  # Trilinos 14.4 (Kokkos) requires C++17, so build Verilog-A plugins with C++17
  sed -i 's/set(CMAKE_CXX_STANDARD 11)/set(CMAKE_CXX_STANDARD 17)/' $XYCE_SRC_DIR/utils/XycePluginProject.cmake.in

  # Trilinos source
  cd $SRC_DIR
  if [ ! -f trilinos-release-$TRILINOS_VERSION.tar.gz ]; then
    wget https://github.com/trilinos/Trilinos/archive/refs/tags/trilinos-release-$TRILINOS_VERSION.tar.gz
  fi
  rm -rf Trilinos-trilinos-release-$TRILINOS_VERSION
  tar zxf trilinos-release-$TRILINOS_VERSION.tar.gz
  export TRILINOS_SRC_DIR=$SRC_DIR/Trilinos-trilinos-release-$TRILINOS_VERSION

  # Build Trilinos and Xyce
  #   $1: reconfigure script suffix ('' : MPI, '.serial' : serial)
  #   $2: install directory
  #   $3: build directory name
  build_trilinos_xyce() {
    # Trilinos
    mkdir -p $TRILINOS_SRC_DIR/$3
    cd $TRILINOS_SRC_DIR/$3
    cp $my_dir/xyce/reconfigure_trilinos$1.sh ./reconfigure_trilinos.sh
    bash reconfigure_trilinos.sh $2 $XYCE_SRC_DIR
    make -j$NPROC
    sudo make install
    sudo ldconfig

    # Xyce
    mkdir -p $XYCE_SRC_DIR/$3
    cd $XYCE_SRC_DIR/$3
    cp $my_dir/xyce/reconfigure_xyce$1.sh ./reconfigure_xyce.sh
    bash reconfigure_xyce.sh $2 $2
    make -j$NPROC
    sudo make install
    sudo ldconfig
  }

  if [ $XYCE_BUILD_MPI -eq 1 ]; then
    echo ">>>> Build Xyce (MPI)"
    build_trilinos_xyce '' $XYCE_INSTALL_DIR build-mpi
  fi
  if [ $XYCE_BUILD_SERIAL -eq 1 ]; then
    echo ">>>> Build Xyce (serial)"
    if [ $XYCE_BUILD_MPI -eq 1 ]; then
      build_trilinos_xyce '.serial' $XYCE_SERIAL_INSTALL_DIR build-serial
      sudo ln -sf $XYCE_SERIAL_INSTALL_DIR/bin/Xyce $XYCE_INSTALL_DIR/bin/Xyce_serial
    else
      build_trilinos_xyce '.serial' $XYCE_INSTALL_DIR build-serial
    fi
  fi

  # buildxyceplugin (compatible command name with autotools-built Xyce)
  sudo cp $my_dir/xyce/buildxyceplugin $XYCE_INSTALL_DIR/bin/
  sudo chmod +x $XYCE_INSTALL_DIR/bin/buildxyceplugin

  $XYCE_INSTALL_DIR/bin/Xyce -v
  if [ $XYCE_BUILD_MPI -eq 1 ] && [ $XYCE_BUILD_SERIAL -eq 1 ]; then
    $XYCE_INSTALL_DIR/bin/Xyce_serial -v
  fi

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
echo ">>>> All done."
echo ""
