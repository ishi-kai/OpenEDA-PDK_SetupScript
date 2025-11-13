#!/bin/sh
export GDS_NAME=chip_top.gds
export GDS_TOP_NAME=chip_top

export TOOLS_ROOT="$HOME/tools"
export PDK=gf180mcuD
export PDK_ROOT=gf180mcu

cd "$TOOLS_ROOT/gf180mcu-precheck"

nix-shell

export PDK_ROOT=$PDK_ROOT && export PDK=$PDK
python3 precheck.py --input $GDS_NAME --top $GDS_TOP_NAME
