#!/bin/bash

echo --------------------------------------------------------
echo The fullpath to here is:
echo --------------------------------------------------------
pushd `dirname $0` > /dev/null
HERE=`pwd`
popd > /dev/null
echo $HERE

echo --------------------------------------------------------
echo Symlinking Home Dotfiles
echo --------------------------------------------------------
for dotfile in `ls ./dotfiles`; do ln -snf $HERE/dotfiles/$dotfile "$HOME/.$dotfile"; done


echo --------------------------------------------------------
echo Symlinking Home Dotfiles
echo --------------------------------------------------------
for overlay in `find $HERE/overlays/ -mindepth 1  -type d -printf "%f\n"`; do
	for link in `ls $HERE/overlays/$overlay`; do
		ln -snf $HERE/overlays/$overlay/$link $HOME/$overlay/$link
	done
done

echo --------------------------------------------------------
echo Refreshing Fonts
echo --------------------------------------------------------
fc-cache -vf ~/.fonts
