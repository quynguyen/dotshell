#!/bin/bash

# Change to the directory where the script lives
# So that everything is relative to this script directory.
pushd `dirname $0` > /dev/null
HERE=`pwd`
popd > /dev/null

echo --------------------------------------------------------
echo
echo Updating Submodules: *************START*****************
echo
echo --------------------------------------------------------
git pull --rebase
git submodule foreach --recursive git checkout master
git submodule foreach --recursive git pull --rebase
echo --------------------------------------------------------
echo
echo Updating Submodules: **************DONE*****************
echo
echo --------------------------------------------------------
