#!/bin/sh

printf "Install vim configurations...\n"
vim +PlugInstall +PlugUpdate +qall
printf "Install coc plugins...\n"
vim +CocInstall coc-json coc-tsserver coc-pyright coc-clangd coc-snippets +qall
printf "Eanble copilot...\n"
vim +Copilot setup +Copilot enable +qall
