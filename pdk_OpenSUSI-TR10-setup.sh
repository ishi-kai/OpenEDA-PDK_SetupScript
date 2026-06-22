#!/usr/bin/env bash
# ========================================================================
# Initialization of IIC Open-Source EDA Environment for OpenRule1umPDK
#
# SPDX-FileCopyrightText: 2023-2026 Mori Mizuki, Noritsuna Imamura, D. Bailey
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

set -euo pipefail

# Define setup environment
# ------------------------
export PDK_ROOT="$HOME/pdk"
export PDK=TR-1um

export KLAYOUT_VERSION=0.30.7

export TCL_VERSION=8.6.14
export TK_VERSION=8.6.14
export GTK_VERSION=3.24.42

# for Mac
if [[ "$(uname)" == 'Darwin' ]]; then
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
if [[ "$(uname -s)" == Linux* ]]; then
  OS='Linux'
  export UBUNTU_VERSION_ID=`lsb_release -r | awk -F: '{ print $2 }'`
fi

# setup OpenSUSI-TR10
# ----------------------------------
if [[ ! -d "$PDK_ROOT/$PDK" ]]; then
	mkdir -p "$PDK_ROOT"
	cd "$PDK_ROOT"
  	git clone https://github.com/OpenSUSI/TR-1um.git "$PDK"
else
	echo ">>>> Updating OpenSUSI-TR10"
	cd "$PDK_ROOT/$PDK" || exit
	git pull
fi

if [[ ! -d "$HOME/.xschem" ]]; then
	mkdir "$HOME/.xschem"
fi
cp "$PDK_ROOT/$PDK/libs.tech/xschem/xschemrc" "$HOME/.xschem/"
cp "$PDK_ROOT/$PDK/libs.tech/xschem/top.sch" "$HOME/.xschem/"

# Add the klayout technology
tmp_py=$(mktemp /tmp/import_klayout_tech.XXXXXX).py

cat > "$tmp_py" <<'PY'
import pya
app = pya.Application.instance()

tech = pya.Technology()
tech.load(tech_file)
name = tech.name
if name in pya.Technology.technology_names():
    pya.Technology.remove_technology(name)
pya.Technology.create_technology(name).load(tech_file)

app.set_config("technology-data", pya.Technology.technologies_to_xml())

print("Imported", name)
PY

klayout -zz \
	-c $HOME/.klayout/klayoutrc \
	-rd tech_file="$PDK_ROOT/$PDK/libs.tech/klayout/tech/TR-1um.lyt" \
	-rm "$tmp_py" 

rm -f "$tmp_py"

# Add export
# ------------------
if [[ "$(uname)" == 'Darwin' ]]; then
	OS='Mac'
	startup="$HOME/.zshrc"
elif [[ "$(uname -s)" == Linux* ]]; then
	OS='Linux'
	startup="$HOME/.bashrc"
elif [[ "$(uname -s)" == MINGW32_NT* ]]; then
	OS='Cygwin'
	echo "Your platform ($(uname -a)) is not supported."
	exit 1
else
	echo "Your platform ($(uname -a)) is not supported."
	exit 1
fi

grep -qxF 'source $HOME/current_pdk' "$startup" || \
    echo 'source $HOME/current_pdk' >> "$startup"

cat > "$HOME/current_pdk" <<EOF
export PDK_ROOT="$PDK_ROOT"
export PDK="$PDK"
EOF
source "$HOME/current_pdk"

# Finished
# --------
echo ""
echo ">>>> All done."
echo ""
