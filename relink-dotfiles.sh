#!/bin/bash

# Change to the directory where the script lives
# So that everything is relative to this script directory.
pushd $(dirname $0) >/dev/null
HERE=$(pwd)
popd >/dev/null

#############################################################
# Source in functions from "core"
### Simply for my custom function "relink", that safely creates
### symlinks, or copies of the contents if they already exist
#############################################################
source ./.submodules/shell-config/common/core

echo --------------------------------------------------------
echo Symlinking Home Dotfiles
echo --------------------------------------------------------
for file in $(ls $DOTFILES); do
	#eg "config" to ".config"#
	sourceFile=$DOTFILES/$file
	dotFile="$HOME/.${file}"

	relink $sourceFile $dotFile
done

exec zsh
