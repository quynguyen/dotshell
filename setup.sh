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

#############################################################
# Source in functions from "core"
### Simply for my custom function "relink", that safely creates
### symlinks, or copies of the contents if they already exist
#############################################################
source ./config/shell-config/common/core

echo --------------------------------------------------------
echo Symlinking Home Dotfiles
echo --------------------------------------------------------
for file in `ls ./dotfiles`; do 
	#eg "config" to ".config"#
	sourceFile=$HERE/dotfiles/$file
	dotFile="$HOME/.${file}"
#	renamedDotFile="${dotFile}-$(date +%^s)"

	relink $sourceFile $dotFile

	#Is the dotFile a directory that already exists
	#.. and dotFile isn't pointing to the same location to the sourceFile
#	if [ -d $dotFile ] && [ ! $dotFile -ef $sourceFile ]; then
#		echo -----------------------------------------
#		echo "Renaming ${dotFile} to ${renamedDotFile}"
#		echo -----------------------------------------
#		#rename it
#		mv -v $dotFile $renamedDotFile
#	fi
#
#	#Create the symlinks in $HOME
#	ln -vsnf $sourceFile $dotFile; 
#
#	#Move over any existing files
#	if [ -d $renamedDotFile ]; then
#		echo -----------------------------------------
#		echo "Moving files from ${renamedDotFile} to ${dotFile}"
#		echo -----------------------------------------
#		mv -v $renamedDotFile/* $dotFile/
#		rm -vrf $renamedDotFile
#		unset renamedDotFile
#	fi
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
