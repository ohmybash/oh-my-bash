#!/usr/bin/env bash
# Created by Jacob Hrbek github.com in 2019
#  ---------------------------------------------------------------------------

# TODO: Needs improvement

# Root integration
if ! ((EUID)); then
	## Enoch Merge
	if [[ -x "$(command -v emerge)" ]]; then
		alias em="emerge" # Enoch Merge
		alias es="emerge --search" # Enoch Search
		alias esync="emerge --sync" # Enoch SYNC
		alias eb="ebuild" # Enoch Build
		alias er="emerge -c" # Enoch Remove
		alias ers="emerge -c" # Enoch Remove Systempackage
		alias emfu="emerge --sync && emerge -uDUj @world"
		alias elip="eix-installed -a" # Enoch List Installed Packages
	fi

  if [[ -x "$(command -v cave)" ]]; then
	alias cave="cave"
	alias cr="cave resolve" # Cave Resolve
	alias cui="cave uninstall" # Cave UnInstall
	alias cs="cave show" # Cave Show
	alias cli="cave print-ids --matching '*/*::/'" # Cave List Installed
  fi

	if [[ -x "$(command -v gparted)" ]]; then
		alias gparted="gparted"
	fi

	if [[ -x "$(command -v apt)" ]]; then
		alias apt="apt" # Advanced Packaging Tool
		alias aptfu="apt update -y && apt upgrade -y && apt dist-upgrade -y && apt autoremove -y"
		alias apti="apt install -y" # Apt install
		alias apts="apt-cache search" # Apt search
		alias aptr="apt remove -y" # Apt remove
		alias aptar="apt autoremove -y" # Apt Auto Remove
		alias aptli="apt list --installed"
	fi

	if [[ -x "$(command -v dpkg)" ]]; then
		alias dpkg="dpkg"
	fi

	if [[ -x "$(command -v zypper)" ]]; then
		# Zypper = Zen Yast Package Program (ZYPP?)
		# Yast = Yet Another Silly/Setup Thing/Thing
		alias lcp="zypper"
		alias lcpi="zypper install"
		alias lcps="zypper search"
		alias lcpsi="zypper source-install"
		alias lcpr="zypper remove"
		if [[ $(cat /etc/os-release | grep -m 1 -o 'openSUSE Tumbleweed') == "openSUSE Tumbleweed"  ]]; then
			# Zypper update kills the system - LCP
			alias lcpfu="zypper dup"
			# Because Geeko uses sublime3 to call sublime_text instead of something that makes sence like 'subl'..
			alias subl="sublime3"
		fi
	fi
fi

# SUDO integration
if [[ -x "$(command -v sudo)" ]]; then
	## Enoch Merge
	if [[ -x "$(command -v emerge)" ]]; then
		alias em="sudo emerge" # Enoch Merge
		alias es="sudo emerge --search" # Enoch Search
		alias esync="sudo emerge --sync" # Enoch SYNC
		alias eb="sudo ebuild" # Enoch Build
		alias er="sudo emerge -c" # Enoch Remove
		alias ers="sudo emerge -c" # Enoch Remove Systempackage
		alias emfu="sudo emerge --sync && sudo emerge -uDUj @world"
		alias elip="eix-installed -a" # Enoch List Installed Packages
	fi

  if [[ -x "$(command -v cave)" ]]; then
	alias cave="sudo cave"
	alias cr="sudo cave resolve" # Cave Resolve
	alias cui="sudo cave uninstall" # Cave UnInstall
	alias cs="sudo cave show" # Cave Show
	alias cli="sudo cave print-ids --matching '*/*::/'" # Cave List Installed
  fi

	if [[ -x "$(command -v gparted)" ]]; then
		alias gparted="sudo gparted"
	fi

	if [[ -x "$(command -v apt)" ]]; then
		alias apt="sudo apt" # Advanced Packaging Tool
		alias aptfu="sudo apt update -y && sudo apt upgrade -y && sudo apt dist-upgrade -y && sudo apt autoremove -y"
		alias apti="sudo apt install -y" # Apt install
		alias apts="sudo apt-cache search" # Apt search
		alias aptr="sudo apt remove -y" # Apt remove
		alias aptar="sudo apt autoremove -y" # Apt Auto Remove
		alias aptli="sudo apt list --installed"
	fi

	if [[ -x "$(command -v dpkg)" ]]; then
		alias dpkg="sudo dpkg"
	fi

	if [[ -x "$(command -v zypper)" ]]; then
		# Zypper = Zen Yast Package Program (ZYPP?)
		# Yast = Yet Another Silly/Setup Thing/Thing
		alias lcp="sudo zypper"
		alias lcpi="sudo zypper install"
		alias lcps="sudo zypper search"
		alias lcpsi="sudo zypper source-install"
		alias lcpr="sudo zypper remove"
		if [[ $(cat /etc/os-release | grep -m 1 -o 'openSUSE Tumbleweed') == "openSUSE Tumbleweed"  ]]; then
			# Zypper update kills the system - LCP
			alias lcpfu="sudo zypper dup"
			# Because Geeko uses sublime3 to call sublime_text instead of something that makes sence like 'subl'..
			alias subl="sudo sublime3"
		fi
	fi
fi
