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
echo Install Required Packages
echo --------------------------------------------------------
if [[ ! -d $REQUIRED_PACKAGES_INSTALLED ]]; then
	packageList=$( dynamicLookup $REQUIRED_PACKAGES )
	case `uname` in
	  Darwin)
		brew install $(cat $packageList)¬
	  ;;
	  Linux)
		sudo apt update --yes
		sudo apt upgrade --yes
		sudo apt --yes --ignore-missing install $(cat $packageList)
	  ;;
	esac
	mkdir -v $REQUIRED_PACKAGES_INSTALLED
	cp $packageList $REQUIRED_PACKAGES_INSTALLED
fi

echo --------------------------------------------------------
echo Setting up bin dir
echo --------------------------------------------------------
ln -vsnf ./.submodules/scripts-config/bin $HERE/bin
[ ! -e $LOCAL_BIN ] && mkdir -v -p $LOCAL_BIN

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
echo Overlaying Custom Configurations into their existing locations
echo --------------------------------------------------------
for overlay in $( find $OVERLAYS -mindepth 1 -maxdepth 1 -type d -printf "%f\n" ); do
	for link in `ls $OVERLAYS/$overlay`; do
		relink $OVERLAYS/$overlay/$link $HOME/$overlay/$link
	done
done

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
envsubst < $CACHES | while read sourceLocation destinationName; do 
	moveAndLink $sourceLocation $CACHESTORE $destinationName
done


echo --------------------------------------------------------
echo Handling concats
echo --------------------------------------------------------

echo --------------------------------------------------------
echo Refreshing Fonts
echo --------------------------------------------------------
if [[ $(type -a fc-cache > /dev/null) ]]; then
	fc-cache -vf ~/.fonts
fi

echo --------------------------------------------------------
echo Creating app links
echo --------------------------------------------------------
for app in $( ls $APPSTORE ); do
	prefix=${app%%-*}
	[ -e $APPSTORE/.versions/$prefix ] && ln -vsnf $APPSTORE/$app $APPS/$prefix
	#Note: Use the buddy-script ~/.shell/bin/appAdd to add an app to the app store directory
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
	"export ENV=$ENV"
	"source $ENV/.submodules/shell-config/zsh/profile"
	"eval \"\$(rbenv init -)\""
	"#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!"
	"export SDKMAN_DIR=\"\$HOME/.sdkman\""
	"[[ -s \"\$HOME/.sdkman/bin/sdkman-init.sh\" ]] && source \"\$HOME/.sdkman/bin/sdkman-init.sh\""
	"export NVM_DIR=\"\$HOME/.nvm\""
	"[ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\"  # This loads nvm"
	"[ -s \"\$NVM_DIR/bash_completion\" ] && \. \"\$NVM_DIR/bash_completion\"  # This loads nvm bash_completion"
)
for l in "${zsh_lines[@]}"; do
	# The -F switch of grep inteprets the input pattern as a fixed string
	grep -Fnq "$l" ~/.zshrc || echo "$l" >> ~/.zshrc
done

echo --------------------------------------------------------
echo Checking for NVM
echo --------------------------------------------------------
if [ ! -d $HOME/.nvm ]; then
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
fi

echo --------------------------------------------------------
echo Checking for SDK man
echo --------------------------------------------------------
if [ ! -d $HOME/.sdkman ]; then
	curl -s "https://get.sdkman.io" | bash
fi

#echo --------------------------------------------------------
#echo Checking for RB Env
#echo --------------------------------------------------------
#if [ ! -d $HOME/.rbenv ]; then
#	curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
#fi

echo --------------------------------------------------------
echo Ensure that Zsh is the default shell.
echo --------------------------------------------------------
[ $SHELL != "/bin/zsh" ] && chsh -s $(which zsh)
exec zsh
