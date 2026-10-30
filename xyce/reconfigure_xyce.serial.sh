#!/bin/sh
# Configure Xyce (serial)
#   $1: install directory (default: /usr/local)
#   $2: Trilinos install directory (default: same as $1)
ARCHDIR=${1:-/usr/local}
TRILINOS_DIR=${2:-$ARCHDIR}
SRCDIR=..
cmake \
-G "Unix Makefiles" \
-DCMAKE_C_COMPILER=gcc \
-DCMAKE_CXX_COMPILER=g++ \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_INSTALL_PREFIX=$ARCHDIR \
-DTrilinos_ROOT=$TRILINOS_DIR \
-DXyce_PLUGIN_SUPPORT=ON \
$SRCDIR
