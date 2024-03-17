#!/bin/bash

required_packages=(git vim zsh tmux node pip curl)
all_dotfiles=("vpn" "git" "vim" "tmux" "zsh")
selected_dotfiles=()
use_vpn=false
vpn_server=""
is_company_machine=false
hostname=$(uname -n)
localhost_ip="127.0.0.1"
clang_port="7890"

RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NONE='\033[0m'

cd "$(dirname "$0")"

# check if the required packages are installed
echo -e "Please make sure the following packages are installed:"
echo -e "${BOLD}${required_packages[@]}${NONE}"
for package in ${required_packages[@]}; do
  if ! command -v $package &> /dev/null; then
    printf "${RED}$package${NONE} is not installed, please install it first\n"
    exit
  fi
done

# Collect user input
echo -e "Please input the dotfiles you want to update: vpn, git, vim, tmux, zsh, all"
read all_params

if [[ $all_params == "all" ]]; then
  selected_dotfiles=("${all_dotfiles[@]}")
else
  for param in $all_params; do
    # check param in all_dotfiles
    if [[ " ${all_dotfiles[@]} " =~ " ${param} " ]]; then
      selected_dotfiles+=($param)
    fi
  done
fi

if [[ $no_selected == true ]]; then
  printf "No dotfiles selected, exit\n"
  exit
fi

echo -e "${BLUE}Selected dotfiles: ${selected_dotfiles[@]}${NONE}"

echo -e "Please input the vpn server ip and port, eg: 127.0.0.1:7890, if not use vpn, just press enter"
read vpn_server
# check vpn_server works or not
export https_proxy=http://${vpn_server} http_proxy=http://${vpn_server} all_proxy=socks5://${vpn_server}
if ! curl -sSf https://www.google.com > /dev/null; then
  printf "${RED}Vpn server $vpn_server$ is not working, please check it${NONE}\n"
  exit
fi
echo -e "${BLUE}Vpn server $vpn_server is working${NONE}"

echo -e "Is this a company machine? (y/n)"
read is_company_machine
echo -e "${BLUE}$hostname is a company machine: $is_company_machine${NONE}"

# vpn
if [[ " ${selected_dotfiles[@]} " =~ "vpn" ]]; then
  arch=$(uname -i)
  printf "Init ${BOLD}vpn${NONE} on $hostname\n"
  if [[ $arch == x86_64* ]]; then
    printf "  X64 Architecture\n"
    ./clash/clash -d . &> /dev/null &
    echo -e "  clash process is running on $clash_port"
    # run clash process after current shell exits
    disown
    vpn_server=${localhost_ip}:${clash_port}
  elif [[ $arch == arm* ]] || [[ $arch = aarch64 ]]; then
    printf "  ARM Architecutre not supported yet\n"
  fi
fi
# vpn

# git
cd "$(dirname "$0")"
if [[ " ${selected_dotfiles[@]} " =~ "git" ]]; then
  printf "${BOLD}Init git config on $hostname${NONE}\n"
  # we'd better set git config firstly, because git proxy can help us downlaod git project much more quickly
  printf "backup origin gitconfig...\n"
  if [ -f ~/.gitconfig]; then
    mv ~/.gitconfig ./git/backup/gitconfig.`date +%F-%T`
  fi

  ln -s ./git/gitconfig ~/.gitconfig
fi
# git

# vim
cd "$(dirname "$0")"
if [[ " ${selected_dotfiles[@]} " =~ "vim" ]]; then
  printf "${BOLD}Init vim on $hostname${NONE}\n"
  cd vim

  printf "  Backup origin vimrc...\n"
  if [ -f ~/.vimrc ]; then
    mv ~/.vimrc ./backup/vimrc.`date +%F-%T`
  fi

  printf "  Create new vimrc...\n"
  ln -s ./vimrc ~/.vimrc

  if [[ $is_company_machine == true ]]; then
    # remove wakatime plugin
    sed -i '/wakatime/d' ./vimrc
  fi

  git submodule init
  git submodule update

  rm -rf ~/.vim
  ln -s ./vim ~/.vim

  printf "  Install vim plugins...\n"
  bash ./init_vim.sh
fi
# vim

# tmux
cd "$(dirname "$0")"
if [[ " ${selected_dotfiles[@]} " =~ "tmux" ]]; then
  printf "${BOLD}Init tmux on $hostname${NONE}\n"
  cd tmux

  printf "  Backup origin tmux.conf...\n"
  if [ -f ~/.tmux.conf ]; then
    mv ~/.tmux.conf ./backup/tmux.conf.`date +%F-%T`
  fi

  printf "  Create new tmux.conf...\n"
  ln -s ./tmux/tmux.conf ~/.tmux.conf
  tmux source ~/.tmux.conf

  printf "  Install tmux plugin framework: tpm\n"
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

  # auto install tmux plugin
  printf "  Install tmux plugins\n"
  bash ~/.tmux/plugins/tpm/scripts/install_plugins.sh
  bash ~/.tmux/plugins/tpm/scripts/update_plugin.sh
fi
# tmux

# zsh
cd "$(dirname "$0")"
if [[ " ${selected_dotfiles[@]} " =~ "zsh" ]]; then
  printf "${BOLD}Init zsh on $hostname${NONE}\n"
  cd zsh

  printf "  Backup origin zshrc...\n"
  if [ -f ~/.zshrc ]; then
    mv ~/.zshrc ./backup/zshrc.`date +%F-%T`
  fi

  printf "  Install oh-my-zsh...\n"
  # bash -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  # Install oh-my-zsh by above command in scripts will lead scripts exit because of changing shell to zsh, ref to https://github.com/ohmyzsh/ohmyzsh/issues/5873
  rm -rf ~/.oh-my-zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  printf "  Create new zshrc...\n"
  rm -rf ~/.zshrc
  ln -s ./zsh/zshrc ~/.zshrc

  printf "  Install zsh plugins...\n"
  bash ./init_zsh.sh

  chsh -s $(which zsh)
fi
# zsh

cd "$(dirname "$0")"
printf "${BLUE}Init dotfiles done!${NONE}\n"
