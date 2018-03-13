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

echo --------------------------------------------------------
echo
echo Initializing Submodules: **************DONE*************
echo
echo --------------------------------------------------------
git submodule update --init --remote
git submodule foreach --recursive git submodule update --init
git submodule foreach git config --local core.excludesfile ../../.gitignore_submodules
echo --------------------------------------------------------
echo
echo Initializing Submodules: **************DONE*************
echo
echo --------------------------------------------------------

source update.sh
source setup.sh
