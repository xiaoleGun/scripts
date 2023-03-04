#!/bin/sh
#
# Copyright (C) 2023 xiaoleGun <1592501605@qq.com>
#

checkOS() {
    if [ "$OSTYPE" = "linux-gnu" ]; then
        distro=$(awk -F= '$1 == "ID" {print $2}' /etc/os-release)
        id_like=$(awk -F= '$1 == "ID_LIKE" {print $2}' /etc/os-release)
        if [[ "$distro" == "arch" || "$id_like" == "arch" ]]; then
            export OS=Arch
        else
            export OS=Linux
        fi
    elif [ "$OSTYPE" = darwin* ]; then
        export OS=Darwin
    fi
}

installGit() {
    if [ -n `git &>/dev/null` ]; then
        if [ "$OS" = "Linux" ]; then
            echo "$password" | sudo -S apt-get -y install git
        elif [ "$OS" = "Arch" ]; then
            echo "$password" | sudo -S pacman -Sy git
        elif [ "$OS" = "Darwin" ]; then
            echo "$password" | brew install git
        fi
    fi
}

installZsh() {
    if [ "$OS" = "Linux" ]; then
        echo "$password" | sudo -S apt-get -y install zsh
    elif [ "$OS" = "Arch" ]; then
        echo "$password" | sudo -S pacman -Sy zsh
    elif [ "$OS" = "Darwin" ]; then
        echo "$password" | brew install zsh
    fi
    echo "$password" | chsh -s $(which zsh)
}

installOhMyZsh() {
    if [ "$SHELL" = /bin/zsh ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
}

installPlugins() {
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
    if [ $OS = Darwin ]; then
        sed -i "" 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search)/' ~/.zshrc
    else
        sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search)/' ~/.zshrc
    fi
    source ~/.zshrc
}

installTheme() {
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    if [ $OS = Darwin ]; then
        sed -i "" 's!ZSH_THEME="robbyrussell"!ZSH_THEME="powerlevel10k/powerlevel10k"!' ~/.zshrc
    else
        sed -i 's!ZSH_THEME="robbyrussell"!ZSH_THEME="powerlevel10k/powerlevel10k"!' ~/.zshrc
    fi
    source ~/.zshrc
    echo "Need your install Meslo Nerd Font, visits more https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k"
    if [ "$USER" = xiaolegun ]; then
       echo "Wizard options: nerdfont-complete + powerline, small icons, rainbow, unicode, 24h time, vertical separators, blurred heads, flat tails, 2 lines, disconnected, full frame, lightest-ornaments, sparse, many icons, concise, instant_prompt=off."
    fi
}

setGitEditer() {
    git config --global core.editor nano
}

personal() {
    if [ -n $JAVA_HOME ]; then
        echo "# openjdk11
export JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home
alias java11="export JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home"
alias java17="export JAVA_HOME=/usr/local/Cellar/openjdk@17/17.0.4/libexec/openjdk.jdk/Contents/Home/"" >> ~/.zshrc
   fi
   if [ -n `gpg --help` &>/dev/null ]; then
       echo "export GPG_TTY=$(tty)" >> ~/.zshrc
   fi
   source ~/.zshrc
}

checkOS
read -s -p "Please enter the password of $USER: " password
installGit
installZsh
installOhMyZsh
installPlugins
installTheme
if [ "$USER" = "xiaolegun" ]; then
setGitEditer
personal
fi
