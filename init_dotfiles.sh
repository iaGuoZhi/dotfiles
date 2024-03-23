#!/bin/bash

cd "$(dirname "$0")"

# vim
printf "Backup origin vimrc...\n"
if [ -f ~/.vimrc ]; then
  mv ~/.vimrc ./backup/vimrc.`date +%F-%T`
fi
printf "Create new vimrc...\n"
ln -s ./vimrc ~/.vimrc

# tmux
printf "Backup origin tmux.conf...\n"
if [ -f ~/.tmux.conf ]; then
  mv ~/.tmux.conf ./backup/tmux.conf.`date +%F-%T`
fi

printf "Create new tmux.conf...\n"
ln -s ./tmux.conf ~/.tmux.conf
tmux source ~/.tmux.conf
