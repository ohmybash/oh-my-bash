#!/usr/bin/env bash
# Created by Jacob Hrbek github.com in 2019
#  ---------------------------------------------------------------------------

# Logic for root usage
if [ -n "$EUID" ] && [ -x $(command -v sudo) ]; then
	[ -z "$OMB_USE_ROOT" ] && export OMB_ROOT='true'
fi

# Portage - Enoch Merge
if [[ -x "$(command -v emerge)" ]]; then
	alias em="${OMB_ROOT:+sudo }emerge" # Enoch Merge
	alias es="${OMB_ROOT:+sudo }emerge --search" # Enoch Search
	alias esync="${OMB_ROOT:+sudo }emerge --sync" # Enoch SYNC
	alias eb="${OMB_ROOT:+sudo }ebuild" # Enoch Build
	alias er="${OMB_ROOT:+sudo }emerge -c" # Enoch Remove
	alias ers="${OMB_ROOT:+sudo }emerge -c" # Enoch Remove Systempackage
	alias emfu="${OMB_ROOT:+sudo }emerge --sync && ${OMB_ROOT:+sudo }emerge -uDUj @world"
	alias elip="${OMB_ROOT:+sudo }eix-installed -a" # Enoch List Installed Packages
fi

# Paludis - Cave
if [[ -x "$(command -v cave)" ]]; then
  alias cave="${OMB_ROOT:+sudo }cave"
  alias cr="${OMB_ROOT:+sudo }cave resolve" # Cave Resolve
  alias cui="${OMB_ROOT:+sudo }cave uninstall" # Cave UnInstall
  alias cs="${OMB_ROOT:+sudo }cave show" # Cave Show
  alias cli="${OMB_ROOT:+sudo }cave print-ids --matching '*/*::/'" # Cave List Installed
fi

# Advanced Packaging Tool - APT
if [[ -x "$(command -v apt)" ]]; then
	alias apt="${OMB_ROOT:+sudo }apt" # Advanced Packaging Tool
	alias aptfu="${OMB_ROOT:+sudo }apt update -y && ${OMB_ROOT:+sudo }apt upgrade -y && ${OMB_ROOT:+sudo }apt dist-upgrade -y && ${OMB_ROOT:+sudo }apt autoremove -y"
	alias apti="${OMB_ROOT:+sudo }apt install -y" # Apt install
	alias apts="${OMB_ROOT:+sudo }apt-cache search" # Apt search
	alias aptr="${OMB_ROOT:+sudo }apt remove -y" # Apt remove
	alias aptar="${OMB_ROOT:+sudo }apt autoremove -y" # Apt Auto Remove
	alias aptli="${OMB_ROOT:+sudo }apt list --installed"
fi

# Debian PacKaGe - DPKG
if [[ -x "$(command -v dpkg)" ]]; then
	alias dpkg="${OMB_ROOT:+sudo }dpkg"
fi

# # Zypper = Zen Yast Package Program (ZYPP?)
# if [[ -x "$(command -v zypper)" ]]; then
#
# 	# Yast = Yet Another Silly/Setup Thing/Thing
# 	alias lcp="${OMB_ROOT:+sudo }zypper"
# 	alias lcpi="${OMB_ROOT:+sudo }zypper install"
# 	alias lcps="${OMB_ROOT:+sudo }zypper search"
# 	alias lcpsi="${OMB_ROOT:+sudo }zypper source-install"
# 	alias lcpr="${OMB_ROOT:+sudo }zypper remove"
# 	if [[ $(cat /etc/os-release | grep -m 1 -o 'openSUSE Tumbleweed') == "openSUSE Tumbleweed"  ]]; then
# 		# Zypper update kills the system - LCP
# 		alias lcpfu="${OMB_ROOT:+sudo }zypper dup"
# 		# Because Geeko uses sublime3 to call sublime_text instead of something that makes sence like 'subl'..
# 		alias subl="${OMB_ROOT:+sudo }sublime3"
# 	fi
# fi
