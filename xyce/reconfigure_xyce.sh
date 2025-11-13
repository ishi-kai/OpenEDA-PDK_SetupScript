#!/bin/sh
./configure \
ARCHDIR="/usr/local" \
CC=mpicc \
CXX=mpic++ \
F77=mpif77 \
CXXFLAGS="-O3 -fPIC" \
CPPFLAGS="-I/usr/include/suitesparse" \
--enable-stokhos \
--enable-amesos2 \
--enable-user-plugin \
--enable-admsmodels \
--enable-shared \
--enable-xyce-shareable \
--enable-mpi
