#!/bin/bash

cd ~/dotfiles

# vim
printf "Backup origin vimrc...\n"
mv ~/.vimrc ~/dotfiles/backup/vimrc.`date +%F-%T`
printf "Create new vimrc...\n"
ln -s ~/dotfiles/vimrc ~/.vimrc

# tmux
printf "Backup origin tmux.conf...\n"
mv ~/.tmux.conf ~/dotfiles/backup/tmux.conf.`date +%F-%T`
printf "Create new tmux.conf...\n"
ln -s ./dotfiles/tmux.conf ~/.tmux.conf
tmux source ~/.tmux.conf
