#!/usr/bin/env bash
# Created by Jacob Hrbek github.com in 2019

# A local temporary variable
declare _omb_tmp_sudo

# Switch for the use of "sudo"
_omb_tmp_sudo=
if [[ ${OMB_ALIAS_PACKAGE_MANAGER_SUDO+set} ]]; then
  _omb_tmp_sudo=${OMB_ALIAS_PACKAGE_MANAGER_SUDO:+$OMB_ALIAS_PACKAGE_MANAGER_SUDO }
elif [[ ${OMB_USE_SUDO-true} == true ]]; then
  if ((EUID != 0)) && _omb_util_binary_exists sudo; then
    _omb_tmp_sudo='sudo '
  fi
fi

# Portage - Enoch Merge
if _omb_util_binary_exists emerge; then
  alias em="${_omb_tmp_sudo}emerge" # Enoch Merge
  alias es="${_omb_tmp_sudo}emerge --search" # Enoch Search
  alias esync="${_omb_tmp_sudo}emerge --sync" # Enoch SYNC
  alias eb="${_omb_tmp_sudo}ebuild" # Enoch Build
  alias er="${_omb_tmp_sudo}emerge -c" # Enoch Remove
  alias emfu="${_omb_tmp_sudo}emerge --sync && ${_omb_tmp_sudo}emerge -uDN @world" # Enoch Upgrade System
  # Deprecated, retained for backward compatibility. Use `er` instead.
  alias ers="${_omb_tmp_sudo}emerge -c"
fi
if _omb_util_binary_exists eclean; then
  alias ecd="${_omb_tmp_sudo}eclean-dist -d" # Enoch Clean Repository Source Files
  alias ecp="${_omb_tmp_sudo}eclean-pkg -d" # Enoch Clean Binary Packages
fi
if _omb_util_binary_exists eix; then
  alias elip="${_omb_tmp_sudo}eix-installed -a" # Enoch List Installed Packages
fi

# Paludis - Cave
if _omb_util_binary_exists cave; then
  alias cave="${_omb_tmp_sudo}cave"
  alias cr="${_omb_tmp_sudo}cave resolve" # Cave Resolve
  alias cui="${_omb_tmp_sudo}cave uninstall" # Cave UnInstall
  alias cs="${_omb_tmp_sudo}cave show" # Cave Show
  alias cli="${_omb_tmp_sudo}cave print-ids --matching '*/*::/'" # Cave List Installed
fi

# Advanced Packaging Tool - APT
if _omb_util_binary_exists apt; then
  alias apt="${_omb_tmp_sudo}apt" # Advanced Packaging Tool
  alias aptfu="${_omb_tmp_sudo}apt update -y && ${_omb_tmp_sudo}apt upgrade -y && ${_omb_tmp_sudo}apt dist-upgrade -y && ${_omb_tmp_sudo}apt autoremove -y"
  alias apti="${_omb_tmp_sudo}apt install -y" # Apt install
  alias apts="${_omb_tmp_sudo}apt-cache search" # Apt search
  alias aptr="${_omb_tmp_sudo}apt remove -y" # Apt remove
  alias aptar="${_omb_tmp_sudo}apt autoremove -y" # Apt Auto Remove
  alias aptli="${_omb_tmp_sudo}apt list --installed"
fi

# Debian PacKaGe - DPKG
if _omb_util_binary_exists dpkg; then
  alias dpkg="${_omb_tmp_sudo}dpkg"
fi

# Volian - Nala
if _omb_util_binary_exists nala; then
  alias nala="${_omb_tmp_sudo}nala" # A faster, prettier front-end for libapt->
  alias nalaf="${_omb_tmp_sudo}nala fetch" # Nala Fastest Mirror
  alias nalau="${_omb_tmp_sudo}nala update" # Nala Update
  alias nalafu="${_omb_tmp_sudo}nala upgrade -y" # Nala Update & Full-Upgrade >
  alias nalai="${_omb_tmp_sudo}nala install -y" # Nala Install
  alias nalar="${_omb_tmp_sudo}nala remove -y" # Nala Remove
  alias nalaa="${_omb_tmp_sudo}nala autoremove -y" # Nala Auto Remove
  alias nalah="${_omb_tmp_sudo}nala history" # Nala History
  alias nalal="${_omb_tmp_sudo}nala list" # Nala List
  alias nalas="${_omb_tmp_sudo}nala search" # Nala Search
  alias nalav="${_omb_tmp_sudo}nala show" # Nala View Package Info
fi

# # Zypper = Zen Yast Package Program (ZYPP?)
# if _omb_util_binary_exists zypper; then
#   # Yast = Yet Another Silly/Setup Thing/Thing
#   alias lcp="${_omb_tmp_sudo}zypper"
#   alias lcpi="${_omb_tmp_sudo}zypper install"
#   alias lcps="${_omb_tmp_sudo}zypper search"
#   alias lcpsi="${_omb_tmp_sudo}zypper source-install"
#   alias lcpr="${_omb_tmp_sudo}zypper remove"
#   if grep -q 'openSUSE Tumbleweed' /etc/os-release; then
#     # Zypper update kills the system - LCP
#     alias lcpfu="${_omb_tmp_sudo}zypper dup"
#     # Because Geeko uses sublime3 to call sublime_text instead of something that makes sence like 'subl'..
#     alias subl="${_omb_tmp_sudo}sublime3"
#   fi
# fi

# Fedora Package - dnf
if _omb_util_binary_exists dnf; then
  alias dnf="${_omb_tmp_sudo}dnf" # DNF Packaging Tool
  alias dnfl="${_omb_tmp_sudo}dnf list" # List
  alias dnfli="${_omb_tmp_sudo}dnf list installed" # List Installed
  alias dnfgl="${_omb_tmp_sudo}dnf grouplist" # Group List
  alias dnfmc="${_omb_tmp_sudo}dnf makecache" # Make Cache
  alias dnfp="${_omb_tmp_sudo}dnf info" # Show Package Info
  alias dnfs="${_omb_tmp_sudo}dnf search" # Search

  alias dnfu="${_omb_tmp_sudo}dnf upgrade" # Update
  alias dnfi="${_omb_tmp_sudo}dnf install" # Install
  alias dnfgi="${_omb_tmp_sudo}dnf group install" # Group Install
  alias dnfr="${_omb_tmp_sudo}dnf remove" # Remove
  alias dnfgr="${_omb_tmp_sudo}dnf groupremove" # Group Remove
  alias dnfc="${_omb_tmp_sudo}dnf clean all" # Clean All
fi

unset -v _omb_tmp_sudo
