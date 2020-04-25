#!/bin/bash

pushd $( dirname ${BASH_SOURCE:-$0} ) > /dev/null # go there the directory of this currently 'sourced' script ( quietly )

recurse=""
[ "$1" == "-r" ] && recurse="--recursive"

echo --------------------------------------------------------
echo
echo Updating Submodules: *************START*****************
echo
echo --------------------------------------------------------
git pull --rebase
git submodule foreach --recursive git checkout master
git submodule foreach $recurse git pull --rebase
echo --------------------------------------------------------
echo
echo Updating Submodules: **************DONE*****************
echo
echo --------------------------------------------------------

echo --------------------------------------------------------
echo
echo Updating Vim Plugins: **************START*****************
echo
echo --------------------------------------------------------
pushd .submodules/vim-config/ > /dev/null
./updatePlugins.sh
popd  > /dev/null
echo --------------------------------------------------------
echo
echo Updating Vim Plugins: **************DONE*****************
echo
echo --------------------------------------------------------
popd  > /dev/null # go back to working directory ( quietly )
