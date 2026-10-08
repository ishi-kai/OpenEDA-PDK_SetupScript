#!/bin/sh
export GDS_NAME=chip_top.gds
export GDS_TOP_NAME=chip_top

export TOOLS_ROOT="$HOME/tools"
export PDK=gf180mcuD
export PDK_ROOT=gf180mcu

cd "$TOOLS_ROOT/gf180mcu-precheck"

rm -fr $PDK_ROOT/$PDK
make clone-pdk

nix-shell

export PDK_ROOT=$PDK_ROOT && export PDK=$PDK
python3 precheck.py --input $GDS_NAME --top $GDS_TOP_NAME

rm -fr $PDK_ROOT/$PDK
mkdir $PDK_ROOT/$PDK/
cp -aR $SRC_DIR/$PDK/* $PDK_ROOT/$PDK/
