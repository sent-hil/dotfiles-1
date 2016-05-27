#!/bin/sh
#
# symlink fish.config; this is required since fish uses nested folder
# (~/.config/fish/fish.config) to store its config file

mkdir -p ~/.config/fish
ln -s `pwd`/fish.config ~/.config/fish/fish.config
