#!/bin/bash

# Change to the directory where the script lives
# So that everything is relative to this script directory.
pushd `dirname $0` > /dev/null
HERE=`pwd`
popd > /dev/null

echo --------------------------------------------------------
echo The fullpath to here is:
echo --------------------------------------------------------
echo $ENV
export ENV=$HERE

echo --------------------------------------------------------
echo Updating Submodules
echo --------------------------------------------------------
git submodule update --init --remote
git submodule foreach --recursive git submodule update --init

#############################################################
# Source in functions from "core"
### Simply for my custom function "relink", that safely creates
### symlinks, or copies of the contents if they already exist
#############################################################
source ./.submodules/shell-config/common/core

echo --------------------------------------------------------
echo Setting up bin dir
echo --------------------------------------------------------
ln -vsnf ./.submodules/scripts-config/bin $HERE/bin

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
for file in $( ls $DOTFILES ); do 
	#eg "config" to ".config"#
	sourceFile=$DOTFILES/$file
	dotFile="$HOME/.${file}"

	relink $sourceFile $dotFile
done

echo --------------------------------------------------------
echo Moving Repos and Caches to $STORE, and replacing them with symlinks
echo --------------------------------------------------------
cat $CACHES | while read cache; do 
	dotCache="$HOME/.${cache}"
	name=$cache
	moveAndLink $dotCache $CACHESTORE $name
done

echo --------------------------------------------------------
echo Overlaying Custom Configurations into their existing locations
echo --------------------------------------------------------
for overlay in $( find $OVERLAYS -mindepth 1  -type d -printf "%f\n" ); do
	for link in `ls $OVERLAYS/$overlay`; do
		relink $OVERLAYS/$overlay/$link $HOME/$overlay/$link
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
line1="export ENV=$ENV"
line2="source $ENV/.submodules/shell-config/bash/profile"
grep -nq "$line1" ~/.bashrc || echo "$line1" >> ~/.bashrc
grep -nq "$line2" ~/.bashrc || echo "$line2" >> ~/.bashrc
source ~/.bashrc
