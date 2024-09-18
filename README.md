# Ansible Pull Playbook to initial config Linux Host:

![Ansible Logo](https://www.learnlinux.tv/wp-content/uploads/2020/12/ansible-e1607524003363.png)

based on :
 - ansible Pull Tutorial : https://github.com/LearnLinuxTV/ansible_pull_tutorial

 - Automating your Dotfiles with Ansible: A Showcase : https://www.youtube.com/watch?v=hPPIScBt4Gw0

 - Brad's Bootstrapping & dotfiles Manager: https://github.com/bradleyfrank/ansible

- Usage: 

```bash
curl -sO https://raw.githubusercontent.com/Aabayoumy/ansible-pull/main/run.sh
bash run.sh
```

```bash 

curl -L https://raw.githubusercontent.com/Aabayoumy/ansible-pull/main/run.sh | bash
```
Or Short Link:
```bash

curl -L https://tinyurl.com/ansible-pull | bash
```
With specific role 

```bash

curl -L https://tinyurl.com/ansible-pull | bash -s -- --tags comma,seperated,tags
```