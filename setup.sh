#!/bin/bash

# Change to the directory where the script lives
# So that everything is relative to this script directory.
pushd `dirname $0` > /dev/null
HERE=`pwd`
popd > /dev/null

echo --------------------------------------------------------
echo The fullpath to here is:
echo --------------------------------------------------------
export ENV=$HERE
echo $ENV

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
[ ! -e $STORE ] && mkdir -v -p $STORE/{apps,cache}
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
echo Handling concats
echo --------------------------------------------------------

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
bash_lines=(
	"export ENV=$ENV"
	"source $ENV/.submodules/shell-config/bash/profile"
)
for l in "${bash_lines[@]}"; do
	grep -nq "$l" ~/.bashrc || echo "$l" >> ~/.bashrc
done
[ -z ${BASH+X} ] && source ~/.bashrc

echo --------------------------------------------------------
echo Updating ~/.zshrc
echo --------------------------------------------------------
zsh_lines=(
	"plugins=(git)"
	"export ENV=$ENV"
	"source $ENV/.submodules/shell-config/zsh/profile"
)
for l in "${zsh_lines[@]}"; do
	grep -nq "$l" ~/.zshrc || echo "$l" >> ~/.zshrc
done
[ -z ${ZSH_NAME+X} ] && source ~/.zshrc
