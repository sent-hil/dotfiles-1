#!/bin/sh
#
# setup play, others gopaths

mkdir -p ~/play/gopath/bin
mkdir -p ~/others/gopath/bin

ln -s `pwd`/envrcs/play.envrc ~/play/.envrc
ln -s `pwd`/envrcs/others.envrc ~/others/.envrc
