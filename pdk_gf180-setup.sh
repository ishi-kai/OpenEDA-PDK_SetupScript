#!/bin/sh
# ========================================================================
# Initialization of IIC Open-Source EDA Environment for Ubuntu WSL2
# This script is for use with GF180.
# ========================================================================

# Define setup environment
# ------------------------
export PDK_ROOT="$HOME/pdk"
export TOOLS_ROOT="$HOME/tools"
export MY_STDCELL=gf180mcu_fd_sc_mcu7t5v0
export SRC_DIR="$HOME/src"
my_path=$(realpath "$0")
my_dir=$(dirname "$my_path")
export SCRIPT_DIR="$my_dir"
export GF_PDK_OPTION=D
export PDK=gf180mcuD
export VOLARE_H=6d4d11780c40b20ee63cc98e645307a9bf2b2ab8

# --------
echo ""
echo ">>>> Initializing..."
echo ""

# Copy KLayout Configurations
# ----------------------------------
if [ ! -d "$HOME/.klayout" ]; then
	mkdir $HOME/.klayout
	mkdir $HOME/.klayout/libraries/
	cp -f gf180/klayoutrc $HOME/.klayout/
fi

# Delete previous PDK
# ---------------------------------------------
if [ -d "$PDK_ROOT" ]; then
	echo ">>>> Delete previous PDK"
	sudo rm -rf "$PDK_ROOT"
	sudo mkdir "$PDK_ROOT"
	sudo chown "$USER:staff" "$PDK_ROOT"
fi

# Install GDSfactory and PDK
# -----------------------------------
# pip install gdsfactory
pip install gf180 --break-system-packages
volare enable --pdk gf180mcu $VOLARE_H

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
{
	echo "export PDK_ROOT=$PDK_ROOT"
	echo "export PDK=$PDK"
	echo "export GF_PDK_OPTION=$GF_PDK_OPTION"
	echo "export STD_CELL_LIBRARY=$MY_STDCELL"
} >> "$HOME/.bashrc"


# Install wafer.space PDK
# -----------------------------------
if [ ! -d "$TOOLS_ROOT" ]; then
  mkdir $TOOLS_ROOT
fi
if [ ! -d "$TOOLS_ROOT/gf180mcu" ]; then
  git clone https://github.com/wafer-space/gf180mcu.git "$TOOLS_ROOT/gf180mcu"
else
  echo ">>>> Updating gf180mcu"
  cd "$TOOLS_ROOT/gf180mcu" || exit
  git pull
fi
if [ ! -d "$TOOLS_ROOT/gf180mcu-project-template" ]; then
  git clone https://github.com/wafer-space/gf180mcu-project-template.git "$TOOLS_ROOT/gf180mcu-project-template"
else
  echo ">>>> Updating gf180mcu-project-template"
  cd "$TOOLS_ROOT/gf180mcu-project-template" || exit
  git pull
fi
cp -aR $TOOLS_ROOT/gf180mcu/$PDK/* $PDK_ROOT/$PDK/
cp -f $TOOLS_ROOT/gf180mcu-project-template/ip/gf180mcu_ws_ip__id/gds/gf180mcu_ws_ip__id.gds $HOME/.klayout/libraries/


# Copy various things
# -------------------
export PDK_ROOT=$PDK_ROOT
export PDK=$PDK
export STD_CELL_LIBRARY=$MY_STDCELL
cp -f $PDK_ROOT/$PDK/libs.tech/xschem/xschemrc $HOME/.xschem
cp -f $PDK_ROOT/$PDK/libs.tech/magic/$PDK.magicrc $HOME/.magicrc
#cp -rf $PDK_ROOT/$PDK/libs.tech/klayout/drc $HOME/.klayout/
#cp -rf $PDK_ROOT/$PDK/libs.tech/klayout/lvs $HOME/.klayout/
#cp -rf $PDK_ROOT/$PDK/libs.tech/klayout/pymacros $HOME/.klayout/
cp -rf $PDK_ROOT/$PDK/libs.tech/klayout/tech $HOME/.klayout/
cp -rf $PDK_ROOT/$PDK/libs.tech/klayout/tech $HOME/.klayout/
cp -f $my_dir/gf180/tech/gf180mcu.lyp  $HOME/.klayout/tech/
cp -f $PDK_ROOT/$PDK/libs.ref/gf180mcu_fd_io/gds/gf180mcu_fd_io.gds $HOME/.klayout/libraries/
cp -f $PDK_ROOT/$PDK/libs.ref/gf180mcu_fd_io/gds/gf180mcu_ef_io.gds $HOME/.klayout/libraries/
cp -f $PDK_ROOT/$PDK/libs.ref/gf180mcu_fd_sc_mcu7t5v0/gds/gf180mcu_fd_sc_mcu7t5v0.gds $HOME/.klayout/libraries/
cp -f $PDK_ROOT/$PDK/libs.ref/gf180mcu_fd_sc_mcu9t5v0/gds/gf180mcu_fd_sc_mcu9t5v0.gds $HOME/.klayout/libraries/

# Fix paths in xschemrc to point to correct PDK directory
# -------------------------------------------------------
sed -i 's/models\/ngspice/$env(PDK)\/libs.tech\/ngspice/g' "$HOME/.xschem/xschemrc"
# echo 'append XSCHEM_LIBRARY_PATH :${PDK_ROOT}/$env(PDK)/libs.tech/xschem' >> "$HOME/.xschem/xschemrc"
echo 'set 180MCU_STDCELLS ${PDK_ROOT}/$env(PDK)/libs.ref/gf180mcu_fd_sc_mcu7t5v0/spice' >> "$HOME/.xschem/xschemrc"
echo 'puts stderr "180MCU_STDCELLS: $180MCU_STDCELLS"' >> "$HOME/.xschem/xschemrc"


# Install precheck tool
# -----------------------------------
if [ ! -d "$TOOLS_ROOT/gf180mcu-precheck" ]; then
  sudo apt install nix-shell
  git clone https://github.com/wafer-space/gf180mcu-precheck.git "$TOOLS_ROOT/gf180mcu-precheck"

  git clone https://github.com/librelane/librelane.git "$TOOLS_ROOT/gf180mcu-precheck/librelane"
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --prefer-upstream-nix --no-confirm --extra-conf " \
      extra-substituters = https://nix-cache.fossi-foundation.org \
      extra-trusted-public-keys = nix-cache.fossi-foundation.org:3+K59iFwXqKsL7BNu6Guy0v+uTlwsxYQxjspXzqLYQs= \
  "
else
  echo ">>>> Updating gf180mcu-precheck"
  cd "$TOOLS_ROOT/gf180mcu-precheck" || exit
  git pull
  cd "$TOOLS_ROOT/gf180mcu-precheck/librelane" || exit
  git pull
fi
cd "$TOOLS_ROOT/gf180mcu-precheck" || exit
make clone-pdk
cd $my_dir
cp -f ./gf180/run_precheck.sh $TOOLS_ROOT/gf180mcu-precheck/
chmod +x  $TOOLS_ROOT/gf180mcu-precheck/run_precheck.sh


# Finished
# --------
echo ""
echo ">>>> All done. Please restart or re-read .bashrc"
echo ""
