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
export PDK_ROOT="$HOME/pdk"
export PDK=TR-1um

export SRC_DIR="$HOME/src"
my_path=$(realpath "$0")
my_dir=$(dirname "$my_path")
export SCRIPT_DIR="$my_dir"
export KLAYOUT_VERSION=0.30.7

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

# for Ubuntu
if [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  OS='Linux'
  export UBUNTU_VERSION_ID=`lsb_release -r | awk -F: '{ print $2 }'`
fi

# ---------------
# Now go to work!
# ---------------
if [ ! -d "$HOME/.xschem/symbols" ]; then
  mkdir -p $HOME/.xschem/symbols
  mkdir -p $HOME/.xschem/lib
fi

cd $my_dir
if [ ! -d "$HOME/.klayout" ]; then
  mkdir -p $HOME/.klayout/
fi


# Delete previous PDK
# ---------------------------------------------
if [ -d "$PDK_ROOT" ]; then
	echo ">>>> Delete previous PDK"
	sudo rm -rf "$PDK_ROOT"
	sudo mkdir "$PDK_ROOT"
	sudo chown "$USER:staff" "$PDK_ROOT"
fi


# setup OpenSUSI-TR10
# ----------------------------------
if [ ! -d "$HOME/.klayout/salt/TR-1um" ]; then
  mkdir -p $HOME/.klayout/salt/TR-1um
fi
if [ ! -d "$SRC_DIR/TR-1um" ]; then
  cd $SRC_DIR
  git clone  https://github.com/OpenSUSI/TR-1um.git
else
  echo ">>>> Updating OpenSUSI-TR10"
  cd $SRC_DIR/TR-1um || exit
  git pull
fi

cd $my_dir
cp $SRC_DIR/TR-1um/xschem/xschemrc $HOME/.xschem/
cp $SRC_DIR/TR-1um/xschem/top.sch $HOME/.xschem/

cp -aR $SRC_DIR/TR-1um/libs.tech/klayout/* $HOME/.klayout/salt/TR-1um/
cp -f $SRC_DIR/TR-1um/libs.tech/klayout/klayoutrc $HOME/.klayout/klayoutrc

cp -aR $SRC_DIR/TR-1um/ $PDK_ROOT/


# Add export
# ------------------
if [ ! -d "$HOME/.xschem" ]; then
	mkdir "$HOME/.xschem"
fi
if [ "$(uname)" == 'Darwin' ]; then
	OS='Mac'
	{
		echo "export PDK_ROOT=$PDK_ROOT"
		echo "export PDK=$PDK"
	} >> "$HOME/.zshrc"
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
	OS='Linux'
	{
		echo "export PDK_ROOT=$PDK_ROOT"
		echo "export PDK=$PDK"
	} >> "$HOME/.bashrc"
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
