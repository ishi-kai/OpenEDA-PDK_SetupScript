#!/bin/sh
export GDS_NAME=chip_top.gds
export GDS_TOP_NAME=chip_top

export TOOLS_ROOT="$HOME/tools"
export PDK=gf180mcuD
export PDK_ROOT=gf180mcu
export SRC_DIR="$HOME/src"

# Exit immediately if a command fails
set -e

cd "$TOOLS_ROOT/gf180mcu-precheck"

rm -fr $PDK_ROOT/$PDK
make clone-pdk

# the exit status of the interactive nix-shell is not an error
nix-shell || true

export PDK_ROOT=$PDK_ROOT
export PDK=$PDK
# Restore the PDK even if precheck fails, then exit with the precheck status
PRECHECK_STATUS=0
python3 precheck.py --input $GDS_NAME --top $GDS_TOP_NAME || PRECHECK_STATUS=$?

rm -fr $PDK_ROOT/$PDK
mkdir -p $PDK_ROOT/$PDK/
cp -aR $SRC_DIR/$PDK/* $PDK_ROOT/$PDK/
exit $PRECHECK_STATUS
