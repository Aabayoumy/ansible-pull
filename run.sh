#!/bin/bash
# color codes
RESTORE='\033[0m'
NC='\033[0m'
BLACK='\033[00;30m'
RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
PURPLE='\033[00;35m'
CYAN='\033[00;36m'
SEA="\\033[38;5;49m"
LIGHTGRAY='\033[00;37m'
LBLACK='\033[01;30m'
LRED='\033[01;31m'
LGREEN='\033[01;32m'
LYELLOW='\033[01;33m'
LBLUE='\033[01;34m'
LPURPLE='\033[01;35m'
LCYAN='\033[01;36m'
WHITE='\033[01;37m'
OVERWRITE='\e[1A\e[K'

#emoji codes
CHECK_MARK="${GREEN}\xE2\x9C\x94${NC}"
X_MARK="${RED}\xE2\x9C\x96${NC}"
PIN="${RED}\xF0\x9F\x93\x8C${NC}"
CLOCK="${GREEN}\xE2\x8C\x9B${NC}"
ARROW="${SEA}\xE2\x96\xB6${NC}"
BOOK="${RED}\xF0\x9F\x93\x8B${NC}"
HOT="${ORANGE}\xF0\x9F\x94\xA5${NC}"
WARNING="${RED}\xF0\x9F\x9A\xA8${NC}"
RIGHT_ANGLE="${GREEN}\xE2\x88\x9F${NC}"


DOTFILES_LOG="$HOME/.dotfiles.log"

# export ANSIBLE_LOG_PATH=/tmp/ansible_$(date "+%Y%m%d%H%M").log 
# touch $ANSIBLE_LOG_PATH 

set -e

# Paths
CONFIG_DIR="$HOME/.config/dotfiles"
VAULT_SECRET="$HOME/.ansible-vault/vault.secret"
DOTFILES_DIR="$HOME/.ansible_dotfiles"
SSH_DIR="$HOME/.ssh"
IS_FIRST_RUN="$HOME/.dotfiles_run"

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
  # rm $DOTFILES_LOG
  # exit installation
  exit 1
}

function _clear_task {
  TASK=""
}

function _task_done {
  printf "${OVERWRITE}${LGREEN} [✓]  ${LGREEN}${TASK}\n"
  _clear_task
}

function ubuntu_setup() {
  _cmd "sudo apt-get update"
  if ! dpkg -s ansible >/dev/null 2>&1; then
    __task "Installing Ansible"
    _cmd "sudo apt-get install -y software-properties-common"
    _cmd "sudo apt-add-repository -y ppa:ansible/ansible"
    _cmd "sudo apt-get update"
    _cmd "sudo apt-get install -y ansible"
    _cmd "sudo apt-get install python3-argcomplete"
    _cmd "sudo activate-global-python-argcomplete3"
  fi
  if ! dpkg -s python3 >/dev/null 2>&1; then
    __task "Installing Python3"
    _cmd "sudo apt-get install -y python3 git"
  fi
  if ! dpkg -s python3-pip >/dev/null 2>&1; then
    __task "Installing Python3 Pip"
    _cmd "sudo apt-get install -y python3-pip"
  fi
  if ! pip3 list | grep watchdog >/dev/null 2>&1; then
    __task "Installing Python3 Watchdog"
    _cmd "sudo apt-get install -y python3-watchdog"
  fi
  if ! dpkg -s virt-what >/dev/null 2>&1; then
    sudo apt install -y virt-what
  fi
}

function arch_setup() {
  if ! [ -x "$(command -v ansible)" ]; then
    __task "Installing Ansible"
    _cmd "sudo pacman -Sy --noconfirm"
    _cmd "sudo pacman -S --noconfirm ansible-core git"
    _cmd "sudo pacman -S --noconfirm python-argcomplete"
    # _cmd "sudo activate-global-python-argcomplete3"
  fi
  if ! pacman -Q python3 >/dev/null 2>&1; then
    __task "Installing Python3"
    _cmd "sudo pacman -S --noconfirm python3 git"
  fi
  if ! pacman -Q python-pip >/dev/null 2>&1; then
    __task "Installing Python3 Pip"
    _cmd "sudo pacman -S --noconfirm python-pip"
  fi
  if ! pip3 list | grep watchdog >/dev/null 2>&1; then
    __task "Installing Python3 Watchdog"
    _cmd "sudo pacman -S --noconfirm python-watchdog"
  fi

  if ! pacman -Q openssh >/dev/null 2>&1; then
    __task "Installing OpenSSH"
    _cmd "sudo pacman -S --noconfirm openssh"
  fi

  __task "Setting Locale"
  _cmd "sudo localectl set-locale LANG=en_US.UTF-8"
}

function rocky_setup() {
  if ! [ -x "$(command -v ansible)" ]; then
    __task "Installing Ansible"
    _cmd "sudo dnf install epel-release -y"
    _cmd "sudo dnf update -y"
    _cmd "sudo dnf install ansible-core git -y"
    _cmd "sudo dnf install python-argcomplete -y"
    # _cmd "sudo activate-global-python-argcomplete3"
  fi
  if ! [ -x "$(command -v python3)" ]; then
    __task "Installing Python3"
    _cmd "sudo dnf install  python3 git -y"
  fi
  if ! [ -x "$(command -v pip)" ]; then
    __task "Installing Python3 Pip"
    _cmd "sudo dnf install python-pip -y"
  fi
  if ! pip3 list | grep watchdog >/dev/null 2>&1; then
    __task "Installing Python3 Watchdog"
    _cmd "pip install watchdog"
  fi
  _cmd "sudo dnf install  virt-what -y"

  if sudo /usr/sbin/virt-what | grep -q 'kvm'; then
    _cmd "sudo dnf install qemu-guest-agent -y"
    _cmd "sudo systemctl enable --now qemu-guest-agent"
  fi

  __task "Setting Locale"
  _cmd "sudo localectl set-locale LANG=en_US.UTF-8"
}

  __task "Updating Ansible Galaxy"
  _cmd "ansible-galaxy collection install community.general ansible.posix --ignore-errors"
  _task_done

# Determine the operating system
if command -v apt &>/dev/null; then
  ID=ubuntu
elif command -v dnf &>/dev/null; then
  ID=rocky
elif command -v pacman &>/dev/null; then
  ID=arch
elif command -v zypper &>/dev/null; then
  ID=suse
else
  ID=unknown
fi

# Execute setup based on the detected OS
case $ID in
  ubuntu) ubuntu_setup ;;
  arch) arch_setup ;;
  rocky) rocky_setup ;;
  *) 
    __task "Unsupported OS"
    _cmd "echo 'Unsupported OS'"
    ;;
esac



# if ! [[ -d "$DOTFILES_DIR" ]]; then
#   __task "Cloning repository"
#   _cmd "git clone -b Pull-Test --quiet https://github.com/Aabayoumy/ansible-pull.git $DOTFILES_DIR"
# else
#   __task "Updating repository"
#   _cmd "git -C $DOTFILES_DIR pull --quiet"
# fi


# ansible-galaxy install -r requirements.yml

# if ! id "abayoumy" >/dev/null 2>&1; then
#   __task "Running playbook"; 
#   ansible-playbook "$DOTFILES_DIR/local.yml" "$@"
#   _task_done
# else
  # __task "Running playbook";
  # ansible-playbook "$DOTFILES_DIR/main.yml" "$@"
  # _task_done
# fi

if [ -d ~/.ansible ]; then
  __task "Clear old folder"; 
  rm -rf ~/.ansible
  _task_done
fi



__task "Running playbook ($USER)"; 
ansible-pull --force -U "https://github.com/Aabayoumy/ansible-pull.git" "$@"
_task_done

# Rename the log file with date and time
LOG_FILE="/tmp/ansible-pull_$(date "+%Y%m%d%H%M").log"
__task "log: $LOG_FILE"
_cmd "mv /tmp/ansible-pull.log $LOG_FILE"
_cmd "/usr/bin/ls /tmp/ansible-pull_*.log -tr | head -n -5 | xargs --no-run-if-empty rm"
_task_done

__task "IP $(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -1)"
_task_done


if [ $USER == "root" ]; then
  __task "Reboot"; 
  _task_done
  reboot
fi
# popd 2>&1 > /dev/null
