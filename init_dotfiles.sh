#!/bin/bash
guozhi_ipads_ip="192.168.25.3"
localhost_ip="127.0.0.1"
clash_port="7890"
vpn_server=""

hostname=$(uname -n)

vpn_selected=false
git_selected=false
vim_selected=false
zsh_selected=false
tmux_selected=false
no_selected=true
all_params=$@

if [ ! "$HOME" == "$PWD" ]; then
    printf "Incorrect usage, you should call me in home directory"
    exit
fi

if [ ! -d "dotfiles" ]; then
    printf "Incorrect usage, dotfiles should be kept in home directory"    exit
fi

cd dotfiles


if [[ "$all_params" == *"vpn"* ]]; then
    vpn_selected=true
    no_selected=false
fi
if [[ "$all_params" == *"git"* ]]; then
    git_selected=true
    no_selected=false
fi
if [[ "$all_params" == *"vim"* ]]; then
    vim_selected=true
    no_selected=false
fi
if [[ "$all_params" == *"zsh"* ]]; then
    zsh_selected=true
    no_selected=false
fi
if [[ "$all_params" == *"tmux"* ]]; then
    tmux_selected=true
    no_selected=false
fi
if [[ "$all_params" == *"all"* ]]; then
    vpn_selected=true
    git_selected=true
    vim_selected=true
    zsh_selected=true
    tmux_selected=true
    no_selected=false
fi

if [[ $no_selected == true ]]; then
    printf "Incorrect usage:\nInput vpn, git, vim, zsh, tmux for updating corresponding dotfiles.\nIpnut all for all selections\n"
    exit
fi

# vpn
if [[ $vpn_selected == true ]]; then
    arch=$(uname -i)
    printf "init vpn on $hostname\n"
    if [[ $arch == x86_64* ]]; then
        printf "X64 Architecture\n"

        cd clash
        ./clash -d . &> /dev/null &

        # run clash process after current shell exits
        disown

        vpn_server=${localhost_ip}:${clash_port}

        cd ..
    elif [[ $arch == arm* ]] || [[ $arch = aarch64 ]]; then
        printf "ARM Architecutre\n"
        vpn_server=${guozhi_ipads_ip}:${clash_port}
    fi

    # bootstrap proxy
    export https_proxy=http://${vpn_server} http_proxy=http://${vpn_server} all_proxy=socks5://${vpn_server}
    # bootstrap proxy
fi
#vpn

# git
if [[ $git_selected == true ]]; then
    printf "init git config on $hostname\n"
    cd git

    # first we should set git config correctly, because git proxy can help us downlaod git project much more quickly
    printf "backup origin gitconfig...\n"
    if [ -f "$HOME/.gitconfig" ]; then
        mv ~/.gitconfig ./backup/gitconfig.`date +%F-%T`
    fi

    ln -s ~/dotfiles/git/gitconfig ~/.gitconfig

    cd ..
fi
# git

# vim
if [[ $vim_selected == true ]]; then
    printf "init vim on $hostname\n"
    cd vim

    printf "backup origin vimrc...\n"
    if [ -f "$HOME/.vimrc" ]; then
        mv ~/.vimrc ./backup/vimrc.`date +%F-%T`
    fi

    printf "create new vimrc...\n"
    ln -s ~/dotfiles/vim/vimrc ~/.vimrc

    git submodule init
    git submodule update

    rm -rf ~/.vim
    ln -s ~/dotfiles/vim ~/.vim

    printf "Install vim plugins...\n"
    bash ./init_vim.sh

    cd ..
fi
# vim

# tmux
if [[ $tmux_selected == true ]]; then
    cd tmux

    printf "backup origin tmux.conf...\n"
    if [ -f "$HOME/.tmux.conf" ]; then
        mv ~/.tmux.conf ./backup/tmux.conf.`date +%F-%T`
    fi

    printf "create new tmux.conf...\n"
    ln -s ~/dotfiles/tmux/tmux.conf ~/.tmux.conf

    cd ..

    printf " Install tmux plugin framework: tpm\n"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

    tmux source ~/.tmux.conf

    # auto install tmux plugin
    printf "Install tmux plugins\n"
    bash ~/.tmux/plugins/tpm/scripts/install_plugins.sh
    bash ~/.tmux/plugins/tpm/scripts/update_plugin.sh
fi
# tmux

# zsh
if [[ $zsh_selected == true ]]; then
    cd zsh

    printf "Backup origin zshrc...\n"
    if [ -f "$HOME/.zshrc" ]; then
        mv ~/.zshrc ./backup/zshrc.`date +%F-%T`
    fi

    printf "Create new zshrc...\n"
    ln -s ~/dotfiles/zsh/zshrc ~/.zshrc

    # oh-my-zsh
    # bash -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    # Install oh-my-zsh by above command in scripts will lead scripts exit because of changing shell to zsh, ref to https://github.com/ohmyzsh/ohmyzsh/issues/5873
    printf "clone oh-my-zsh\n"
    if [ ! -d "~/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    printf "Install zsh plugins...\n"
    bash ./init_zsh.sh

    chsh -s $(which zsh)
    cd ..
fi
# zsh
