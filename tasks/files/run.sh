#!/bin/bash

DOTFILES_DIR="$HOME/.ansible_dotfiles"

if ! [ -x "$(command -v ansible)" ]; then 
    packagesNeeded='ansible python3 python-pip git'
    if [ -x "$(command -v apt)" ]; then sudo apt update && sudo apt upgrade -y && sudo apt install $packagesNeeded -y
    elif [ -x "$(command -v dnf)" ]; then sudo dnf update -y && sudo dnf install -y epel-release && sudo dnf install $packagesNeeded -y
    elif [ -x "$(command -v zypper)" ];  then sudo zypper install $packagesNeeded
    elif [ -x "$(command -v pacman)" ];  then sudo pacman -Sy $packagesNeeded  --noconfirm
    else echo "FAILED TO INSTALL PACKAGE: Package manager not found. You must manually install: $packagesNeeded">&2; 
    fi
fi

# ansible-galaxy collection install ansible.posix
# ansible-galaxy collection install community.general
# ansible-pull -U https://github.com/Aabayoumy/ansible-pull.git

if ! [[ -d "$DOTFILES_DIR" ]]; then
  __task "Cloning repository"
  _cmd "git clone --quiet https://github.com/Aabayoumy/ansible-pull.git $DOTFILES_DIR"
else
  __task "Updating repository"
  _cmd "git -C $DOTFILES_DIR pull --quiet"
fi

bash -c $DOTFILES_DIR/run.sh