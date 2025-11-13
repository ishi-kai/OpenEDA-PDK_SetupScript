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
# This script installs xschem, ngspice, magic, netgen, klayout
# and a few other tools for use with OpenRule1umPDK.
# This script supports WSL(Windows Subsystem for Linux), Ubuntu 22.04, macOS.
# ========================================================================

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
  sudo sed -i 's/# deb-src/deb-src/g' /etc/apt/sources.list
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
mkdir $SRC_DIR
cd $SRC_DIR


# Install Xyce
# ----------------------------------
echo ">>>> Install Xyce"
if [ "$(uname)" == 'Darwin' ]; then
  OS='Mac'



elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  OS='Linux'
  sudo apt -qq install -y libmatio-dev libsuitesparse-dev gnuplot-x11

  cd $SRC_DIR
  git clone https://github.com/Qucs/ADMS.git
  cd ADMS
  mkdir build
  cd build
  cmake ../ -DCMAKE_BUILD_TYPE=RELEASE
  make
  sudo make install

  cd $SRC_DIR
  wget https://github.com/trilinos/Trilinos/archive/refs/tags/trilinos-release-12-12-1.tar.gz
  tar zxfv trilinos-release-12-12-1.tar.gz
  cd Trilinos-trilinos-release-12-12-1/
  mkdir build
  cd build
  cp $my_path/xyce/reconfigure_trilinos.sh .
  bash reconfigure_trilinos.sh
  make
  sudo make install

  cd $SRC_DIR
  wget https://xyce.sandia.gov/files/xyce/Xyce-7.9.tar.gz
  tar zxfv Xyce-7.9.tar.gz
  cd Xyce-7.9
  cp $my_dir/xyce/reconfigure_xyce.sh .
  bash reconfigure_xyce.sh
  make
  sudo make install

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
