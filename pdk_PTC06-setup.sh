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
export KLAYOUT_VERSION=0.29.10

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


if [ ! -d "$HOME/.xschem/symbols" ]; then
  mkdir -p $HOME/.xschem/symbols
  mkdir -p $HOME/.xschem/lib
fi
cd $my_dir
cp ./xschem/xschemrc_PTC06 $HOME/.xschem/xschemrc
cp ./xschem/title_PTC06.sch $HOME/.xschem/title_PTC06.sch
cp -aR ./xschem/symbols/* $HOME/.xschem/symbols/
cp -aR ./xschem/lib/PTC06/* $HOME/.xschem/lib/

cd $my_dir
if [ ! -d "$HOME/.klayout" ]; then
  mkdir -p $HOME/.klayout/
fi
cp -f ./klayout/klayoutrc $HOME/.klayout/klayoutrc

# setup OpenRule1umPDK
# ----------------------------------
if [ ! -d "$HOME/.klayout/salt" ]; then
  mkdir -p $HOME/.klayout/salt
fi
if [ ! -d "$SRC_DIR/OpenRule1um" ]; then
  cd $SRC_DIR
  git clone  https://github.com/mineda-support/OpenRule1um.git
  cp -aR OpenRule1um $HOME/.klayout/salt/
else
  echo ">>>> Updating OpenRule1um"
  cd $SRC_DIR/OpenRule1um || exit
  git pull
  if [ ! -d "$HOME/.klayout/salt/OpenRule1um" ]; then
    mkdir -p $HOME/.klayout/salt/OpenRule1um
  fi
  cp -aR ./* $HOME/.klayout/salt/OpenRule1um/
fi
cd $my_dir
rm $HOME/.klayout/salt/OpenRule1um/tech/tech/lvs/lvs.lylvs
cp ./klayout/lvs/or1_lvs.* $HOME/.klayout/salt/OpenRule1um/tech/tech/lvs/
cp ./klayout/macros/get_reference.lym $HOME/.klayout/salt/OpenRule1um/tech/tech/macros/

if [ ! -d "$SRC_DIR/AnagixLoader" ]; then
  cd $SRC_DIR
  git clone  https://github.com/mineda-support/AnagixLoader.git
  cp -aR AnagixLoader $HOME/.klayout/salt/
else
  echo ">>>> Updating AnagixLoader"
  cd $SRC_DIR/AnagixLoader || exit
  git pull
  if [ ! -d "$HOME/.klayout/salt/AnagixLoader" ]; then
    mkdir -p $HOME/.klayout/salt/AnagixLoader
  fi
  cp -aR ./* $HOME/.klayout/salt/AnagixLoader/
fi


# Finished
# --------
echo ""
echo ">>>> All done."
echo ""
