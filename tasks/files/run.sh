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
function __task {
  # if _task is called while a task was set, complete the previous
  if [[ $TASK != "" ]]; then
    printf "${OVERWRITE}${LGREEN} [✓]  ${LGREEN}${TASK}\n"
  fi
  # set new task title and print
  TASK=$1
  printf "${LBLACK} [ ]  ${TASK} \n${LRED}"
}

# _cmd performs commands with error checking
function _cmd {
  #create log if it doesn't exist
  if ! [[ -f $DOTFILES_LOG ]]; then
    touch $DOTFILES_LOG
  fi
  # empty conduro.log
  > $DOTFILES_LOG
  # hide stdout, on error we print and exit
  if eval "$1" 1> /dev/null 2> $DOTFILES_LOG; then
    return 0 # success
  fi
  # read error from log and add spacing
  printf "${OVERWRITE}${LRED} [X]  ${TASK}${LRED}\n"
  while read line; do
    printf "      ${line}\n"
  done < $DOTFILES_LOG
  printf "\n"
  # remove log file
  rm $DOTFILES_LOG
  # exit installation
  exit 1
}

if ! [[ -d "$DOTFILES_DIR" ]]; then
  __task "Cloning repository"
  _cmd "git clone --quiet https://github.com/Aabayoumy/ansible-pull.git $DOTFILES_DIR"
else
  __task "Updating repository"
  _cmd "git -C $DOTFILES_DIR pull --quiet"
fi

bash -c $DOTFILES_DIR/run.sh