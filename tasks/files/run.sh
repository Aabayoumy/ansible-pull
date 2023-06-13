#!/bin/bash
sudo apt update
sudo apt install ansible git -y
sudo ansible-pull -U https://github.com/Aabayoumy/ansible-pull.git
