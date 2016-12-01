#!/bin/bash

echo --------------------------------------------------------
echo The fullpath to here is:
echo --------------------------------------------------------
pushd `dirname $0` > /dev/null
HERE=`pwd`
popd > /dev/null
echo $HERE

echo --------------------------------------------------------
echo Updating Submodules
echo --------------------------------------------------------
git submodule init
git submodule update
git submodule foreach --recursive git submodule update --init

echo --------------------------------------------------------
echo Symlinking Home Dotfiles
echo --------------------------------------------------------
for file in `ls ./dotfiles`; do 
	#eg "config" to ".config"#
	sourceFile=$HERE/dotfiles/$file
	dotFile="$HOME/.${file}"
	renamedDotFile="${dotFile}-$(date +%^s)"

	#Is the dotFile a directory that already exists
	#.. and dotFile isn't pointing to the same location to the sourceFile
	if [ -d $dotFile ] && [ ! $dotFile -ef $sourceFile ]; then
		echo -----------------------------------------
		echo "Renaming ${dotFile} to ${renamedDotFile}"
		echo -----------------------------------------
		#rename it
		mv -v $dotFile $renamedDotFile
	fi

	#Create the symlinks in $HOME
	ln -vsnf $sourceFile $dotFile; 

	#Move over any existing files
	if [ -d $renamedDotFile ]; then
		echo -----------------------------------------
		echo "Moving files from ${renamedDotFile} to ${dotFile}" 
		echo -----------------------------------------
		mv -v $renamedDotFile/* $dotFile/
		rm -vrf $renamedDotFile
		unset renamedDotFile
	fi
done


echo --------------------------------------------------------
echo Handling Overlays
echo --------------------------------------------------------
for overlay in `find $HERE/overlays/ -mindepth 1  -type d -printf "%f\n"`; do
	for link in `ls $HERE/overlays/$overlay`; do
		ln -vsnf $HERE/overlays/$overlay/$link $HOME/$overlay/$link
	done
done

echo --------------------------------------------------------
echo Refreshing Fonts
echo --------------------------------------------------------
fc-cache -vf ~/.fonts
