# dotshell

## Quickstart
```bash
git clone git@github.com:quynguyen/dotshell.git $HOME/.shell
cd $HOME/.shell
./setup.sh
```

## Purpose
Quy's peronsal shell environment portable across computers.
Checking this repo out into $HOME/.shell and running setup.sh, will fetch and update git submodules this repo depends on, and creates all the symlinks off $HOME to configure the shell, tools, and applications.

## Requirements 

### Espected to be already installed
* git (Duh)

### Contains plugins and tools for (thus they should be already installed)
* bash
* zsh
* vim (with +gtk or +gnome)
* tmux

### Fonts

Powerline -- a category of fonts that vastly improve the ZSH Terminal by adding informative glyths and symbols to the prompt.  There are different implementations that fall into the "Powerline" category, and unfortunately there is no single, end-all, be-all definitive implementation.
But the following 2 make it up:
* Install Source Code Pro: https://github.com/adobe-fonts/source-code-pro
** It is a tailor-made monospace font for Terminals and Coding.
** It contains most of the glyphs needed for Powerline, but not all.
* Install Awesome Terminal fonts: https://github.com/gabrielelana/awesome-terminal-fonts/wiki/OS-X
** It contains the rest of the glyphs.
** However it does require forcibly disabling OS X's strict font controls, every time there is an OS X update.
** There is a submodule for it here:
*** ./submodules/awesome-terminal-fonts
*** Run the install script there

### Other requirements
* JDK (typically an openjdk)
* Ruby (Mostly for Vim's plugin manager, Pathogen)

### Nice to Haves
* [Tmuxinator](https://github.com/tmuxinator/tmuxinator) 
* xclip (for transfering text between clipboards)

## Note
It's not intended to be portable across people, but certainly there are patterns that could be useful for everyone.  One day, I may extract the patterns out into their own project.  Until then, YAGNI.
