#!/bin/bash

# Change to the directory where the script lives
# So that everything is relative to this script directory.
pushd `dirname $0` > /dev/null
HERE=`pwd`
popd > /dev/null


echo --------------------------------------------------------
echo The fullpath to here is:
echo --------------------------------------------------------
echo $HERE

echo --------------------------------------------------------
echo Updating Submodules
echo --------------------------------------------------------
git submodule init
git submodule update
git submodule foreach --recursive git submodule update --init
git submodule foreach --recursive git checkout master

#############################################################
# Source in functions from "core"
### Simply for my custom function "relink", that safely creates
### symlinks, or copies of the contents if they already exist
#############################################################
source ./config/shell-config/common/core


echo --------------------------------------------------------
echo Setting up bin dir
echo --------------------------------------------------------
ln -vsnf ./config/scripts-config/bin $HERE/bin

echo --------------------------------------------------------
echo Setting up apps dir
echo --------------------------------------------------------
[ ! -e $APPS ] && mkdir -v $APPS

echo --------------------------------------------------------
echo Setting up local storage
echo --------------------------------------------------------
[ ! -e $STORE ] && mkdir -v --parents $STORE/{apps,cache}
ln -vsnf $STORE $STORELINK

echo --------------------------------------------------------
echo Symlinking Home Dotfiles
echo --------------------------------------------------------
for file in `ls ./dotfiles`; do 
	#eg "config" to ".config"#
	sourceFile=$HERE/dotfiles/$file
	dotFile="$HOME/.${file}"

	relink $sourceFile $dotFile
done


echo --------------------------------------------------------
echo Overlaying Custom Configurations into their existing locations
echo --------------------------------------------------------
for overlay in `find $HERE/overlays/ -mindepth 1  -type d -printf "%f\n"`; do
	for link in `ls $HERE/overlays/$overlay`; do
		relink $HERE/overlays/$overlay/$link $HOME/$overlay/$link
	done
done

echo --------------------------------------------------------
echo Refreshing Fonts
echo --------------------------------------------------------
fc-cache -vf ~/.fonts

echo --------------------------------------------------------
echo Creating app links
echo --------------------------------------------------------
for app in $( ls $APPSTORE ); do
	prefix=${app%%-*}
	[ -e $APPSTORE/.versions/$prefix ] && ln -vsnf $APPSTORE/$app $APPS/$prefix
done

echo --------------------------------------------------------
echo Updating ~/.bashrc
echo --------------------------------------------------------
appendage="source ~/.shell/config/shell-config/bash/profile"
grep -nq "$appendage" ~/.bashrc || echo "$appendage" >> ~/.bashrc
source ~/.bashrc
