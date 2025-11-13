#!/bin/bash
# ========================================================================
# IIC Open-Source EDA Environment for Ubuntu WSL2 and macOS.
# This script will delete some stuffs in your home directory
# to change the PDK. 
# ========================================================================
rm -f $HOME/.magicrc
rm -f $HOME/.spiceinit
rm -rf $HOME/.klayout
rm -rf $HOME/.xschem
rm -rf $HOME/.gaw
if [ "$(uname)" == 'Darwin' ]; then
	OS='Mac'
	sed -i -e '' '/export PDK_ROOT=/d' $HOME/.bashrc
	sed -i -e '' '/export PDK=/d' $HOME/.bashrc
	sed -i -e '' '/export STD_CELL_LIBRARY=/d' $HOME/.bashrc
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
	OS='Linux'
	sed -i -e '/export PDK_ROOT=/d' $HOME/.bashrc
	sed -i -e '/export PDK=/d' $HOME/.bashrc
	sed -i -e '/export STD_CELL_LIBRARY=/d' $HOME/.bashrc
elif [ "$(expr substr $(uname -s) 1 10)" == 'MINGW32_NT' ]; then
	OS='Cygwin'
	echo "Your platform ($(uname -a)) is not supported."
	exit 1
else
	echo "Your platform ($(uname -a)) is not supported."
	exit 1
fi
echo ">> All done. Now you can re-install or change the PDK."
echo ">>"
echo ">> You have to remove local pip packages by yourself."
echo ">> If you installed GF180MCU: pip-autoremove gf180"
echo ">> If you installed SKY130  : pip-autoremove sky130 flayout"
echo ">>"
echo ">> Please check the dependencies if you are using this"
echo ">> environment with other than Open-Source EDA tools."
