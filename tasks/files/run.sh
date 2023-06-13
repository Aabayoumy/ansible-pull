#!/bin/bash
sudo apt update
sudo apt install ansible -y
sudo ansible-pull -U https://github.com/Aabayoumy/ansible-pull.git
