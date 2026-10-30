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


# Install Qucs-S
# ----------------------------------
echo ">>>> Install Qucs-S"
if [ "$(uname)" == 'Darwin' ]; then
  OS='Mac'
  brew install --cask ra3xdh/qucs-s/qucs-s@nightly
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  OS='Linux'
  echo 'deb http://download.opensuse.org/repositories/home:/ra3xdh/xUbuntu_22.04/ /' | sudo tee /etc/apt/sources.list.d/home:ra3xdh.list
  curl -fsSL https://download.opensuse.org/repositories/home:ra3xdh/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_ra3xdh.gpg > /dev/null
  sudo apt update
  sudo apt -qq install -y qucs-s
elif [ "$(expr substr $(uname -s) 1 10)" == 'MINGW32_NT' ]; then
  OS='Cygwin'
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
else
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
fi

cp $my_dir/xyce/qmpirun $HOME/bin/
chmod +x $HOME/bin/qmpirun
cp $my_dir/qucs-s/Xyce_plugin $HOME/bin/
chmod +x $HOME/bin/Xyce_plugin

# Finished
# --------
echo ""
echo ">>>> All done."
echo ""
