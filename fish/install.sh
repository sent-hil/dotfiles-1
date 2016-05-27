#!/bin/sh
#
# symlink fish.config; this is required since fish uses nested folder
# (~/.config/fish/fish.config) to store its config file

mkdir -p ~/.config/fish
if [ ! -f ~/.config/fish/config.fish ]; then
  ln -s `pwd`/config.fish ~/.config/fish/config.fish
fi

if [ ! -d ~/.config/fish/functions ]; then
  ln -s `pwd`/functions ~/.config/fish/functions
fi
