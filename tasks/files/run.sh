#!/bin/bash

if ! [ -x "$(command -v ansible-pull)" ]; then 
    packagesNeeded='ansible git'
    if [ -x "$(command -v apt)" ]; then sudo apt update && sudo apt upgrade -y && sudo apt install $packagesNeeded -y
    elif [ -x "$(command -v dnf)" ]; then sudo dnf update -y && sudo dnf install -y epel-release && sudo dnf install $packagesNeeded -y
    elif [ -x "$(command -v zypper)" ];  then sudo zypper install $packagesNeeded
    else echo "FAILED TO INSTALL PACKAGE: Package manager not found. You must manually install: $packagesNeeded">&2; 
    fi
fi

ansible-pull -U https://github.com/Aabayoumy/ansible-pull.git

