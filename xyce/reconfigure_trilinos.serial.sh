#!/bin/sh
# Configure Trilinos (serial) for Xyce
#   $1: install directory (default: /usr/local)
#   $2: Xyce source directory (uses Xyce's Trilinos initial cache file)
ARCHDIR=${1:-/usr/local}
XYCE_SRCDIR=$2
SRCDIR=..
cmake \
-G "Unix Makefiles" \
-C $XYCE_SRCDIR/cmake/trilinos/trilinos-base.cmake \
-DCMAKE_C_COMPILER=gcc \
-DCMAKE_CXX_COMPILER=g++ \
-DCMAKE_Fortran_COMPILER=gfortran \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_INSTALL_PREFIX=$ARCHDIR \
-DAMD_LIBRARY_DIRS="/usr/lib/$(gcc -dumpmachine);/usr/lib" \
-DAMD_INCLUDE_DIRS="/usr/include/suitesparse" \
$SRCDIR
