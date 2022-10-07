#!/usr/bin/env bash
# Short aliases for most used debian specific commands.

alias apup='sudo apt update'
alias apug='sudo apt upgrade'
alias apuu='sudo apt update && sudo apt upgrade'
alias apfu='sudo apt full-upgrade'

alias apin='sudo apt install'
alias apri='sudo apt install --reinstall'

alias aprm='sudo apt remove'
alias apur='sudo apt purge'
alias apar='sudo apt autoremove'
alias apcl='sudo apt-get autoclean'

alias apse='apt search'
alias apsh='apt show'
alias apsc='apt-get source'
alias apesr='sudo apt edit-sources'
alias apdl='apt-get download'

alias apbd='sudo apt build-deb'
alias aphst='cat /var/log/apt/history.log | less'

alias drcf='sudo dpkg-reconfigure'

alias upgrb='sudo update-grub'
alias uirfs='sudo update-initramfs -u'
