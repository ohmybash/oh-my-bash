#!/usr/bin/env bash
# Created by Jacob Hrbek github.com in 2019
#  ---------------------------------------------------------------------------

if ! ((EUID)); then OSH_ROOT=true; fi

## Enoch Merge
if [[ -x "$(command -v emerge)" ]]; then
	alias em="${OSH_ROOT:+sudo }emerge" # Enoch Merge
	alias es="${OSH_ROOT:+sudo }emerge --search" # Enoch Search
	alias esync="${OSH_ROOT:+sudo }emerge --sync" # Enoch SYNC
	alias eb="${OSH_ROOT:+sudo }ebuild" # Enoch Build
	alias er="${OSH_ROOT:+sudo }emerge -c" # Enoch Remove
	alias ers="${OSH_ROOT:+sudo }emerge -c" # Enoch Remove Systempackage
	alias emfu="${OSH_ROOT:+sudo }emerge --sync && emerge -uDUj @world"
	alias elip="${OSH_ROOT:+sudo }eix-installed -a" # Enoch List Installed Packages
fi

if [[ -x "$(command -v cave)" ]]; then
  alias cave="${OSH_ROOT:+sudo }cave"
  alias cr="${OSH_ROOT:+sudo }cave resolve" # Cave Resolve
  alias cui="${OSH_ROOT:+sudo }cave uninstall" # Cave UnInstall
  alias cs="${OSH_ROOT:+sudo }cave show" # Cave Show
  alias cli="${OSH_ROOT:+sudo }cave print-ids --matching '*/*::/'" # Cave List Installed
fi

if [[ -x "$(command -v gparted)" ]]; then
	alias gparted="${OSH_ROOT:+sudo }gparted"
fi

if [[ -x "$(command -v apt)" ]]; then
	alias apt="${OSH_ROOT:+sudo }apt" # Advanced Packaging Tool
	alias aptfu="${OSH_ROOT:+sudo }apt update -y && apt upgrade -y && apt dist-upgrade -y && apt autoremove -y"
	alias apti="${OSH_ROOT:+sudo }apt install -y" # Apt install
	alias apts="${OSH_ROOT:+sudo }apt-cache search" # Apt search
	alias aptr="${OSH_ROOT:+sudo }apt remove -y" # Apt remove
	alias aptar="${OSH_ROOT:+sudo }apt autoremove -y" # Apt Auto Remove
	alias aptli="${OSH_ROOT:+sudo }apt list --installed"
fi

if [[ -x "$(command -v dpkg)" ]]; then
	alias dpkg="${OSH_ROOT:+sudo }dpkg"
fi

if [[ -x "$(command -v zypper)" ]]; then
	# Zypper = Zen Yast Package Program (ZYPP?)
	# Yast = Yet Another Silly/Setup Thing/Thing
	alias lcp="${OSH_ROOT:+sudo }zypper"
	alias lcpi="${OSH_ROOT:+sudo }zypper install"
	alias lcps="${OSH_ROOT:+sudo }zypper search"
	alias lcpsi="${OSH_ROOT:+sudo }zypper source-install"
	alias lcpr="${OSH_ROOT:+sudo }zypper remove"
	if [[ $(cat /etc/os-release | grep -m 1 -o 'openSUSE Tumbleweed') == "openSUSE Tumbleweed"  ]]; then
		# Zypper update kills the system - LCP
		alias lcpfu="${OSH_ROOT:+sudo }zypper dup"
		# Because Geeko uses sublime3 to call sublime_text instead of something that makes sence like 'subl'..
		alias subl="${OSH_ROOT:+sudo }sublime3"
	fi
fi
