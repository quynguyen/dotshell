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

### Other requirements
* Ruby (Mostly for Vim's plugin manager, Pathogen)

### Nice to Haves
* [Tmuxinator](https://github.com/tmuxinator/tmuxinator) 

## Note
It's not intended to be portable across people, but certainly there are patterns that could be useful for everyone.  One day, I may extract the patterns out into their own project.  Until then, YAGNI.
