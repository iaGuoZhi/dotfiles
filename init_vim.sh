#!/bin/sh

printf "   Install vim configurations...\n"
vim +PlugInstall +PlugUpdate +qall
