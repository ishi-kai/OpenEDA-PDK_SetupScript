#!/bin/sh
export DYLD_LIBRARY_PATH="$(brew --prefix ruby@3.3)/lib:$DYLD_LIBRARY_PATH"
export PATH="$(brew --prefix ruby@3.3)/bin:$PATH"
cd $HOME/bin/klayout.app/
./klayout.app/Contents/MacOS/klayout -e
