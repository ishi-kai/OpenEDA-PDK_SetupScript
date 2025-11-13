#!/bin/sh
./configure \
ARCHDIR="/usr/local" \
CXXFLAGS="-O3 -fPIC" \
CPPFLAGS="-I/usr/include/suitesparse" \
--enable-stokhos \
--enable-amesos2 \
--enable-user-plugin \
--enable-admsmodels \
--enable-shared \
--enable-xyce-shareable
