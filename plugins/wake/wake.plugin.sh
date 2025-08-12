#!/usr/bin/env bash
# oh-my-bash.module: wake-on-lan wrapper + autocompletion
# wake.plugin.sh
# Author: hoek from 0ut3r.space
# Based on oh-my-zsh wakeonlan plugin @ commit 1d9eacb34f59f3bf82a9de0d7b474cb4c501e3fd
#
# Usage: wake [options] <device>
# Options:
#   -l, --list       list configured devices
#   -n, --dry-run    show what would be executed (no packet sent)
#   -p, --port <N>   UDP port (default 9)
#   -h, --help       usage
#
# Config dir: $HOME/.wakeonlan
# Device file format (either):
#   "<MAC> [broadcast-IP] [port]"          
# first non-empty, non-# line
# or key=value lines:
#   MAC=aa:bb:cc:dd:ee:ff
#   BCAST=192.168.1.255
#   PORT=9

_wake_cfgdir="$HOME/.wakeonlan"

_wake_usage() {
  _omb_util_print 'Usage: wake [ -l | --list ] [ -n | --dry-run ] [ -p|--port N ] <device>' >&2
}
Hyprland
_wake_collect_devices() {
  local -n _out=$1
  _out=()
  local f
  shopt -s nullglob
  for f in "$_wake_cfgdir"/*; do
    [[ -f $f ]] && _out+=( "$(basename -- "$f")" )
  done
  shopt -u nullglob
}

_wake_read_config() {
  local device=$1 cfgfile="$_wake_cfgdir/$device"
  local -n _mac=$2 _bcast=$3 _port=$4
  _mac="" _bcast="" _port=""

  local line key val
  while IFS= read -r line; do
    [[ -z $line || $line =~ ^[[:space:]]*# ]] && continue
    if [[ $line == *"="* ]]; then
      key=${line%%=*}; val=${line#*=}
      key=${key//[[:space:]]/}; val=${val##[[:space:]]}
      case "${key^^}" in
        MAC)                 _mac="$val" ;;
        BCAST|BROADCAST)     _bcast="$val" ;;
        PORT)                _port="$val" ;;
      esac
    else
      read -r _mac _bcast _port <<<"$line"
    fi
  done <"$cfgfile"

  [[ -n $_mac ]] || return 1
  [[ -n $_bcast ]] || _bcast=255.255.255.255
  [[ -n $_port  ]] || _port=9
  return 0
}

function wake {
  local opt_list=0 opt_dry=0 opt_port=""
  local device

  while (($#)); do
    case "$1" in
      -l|--list) opt_list=1 ;;
      -n|--dry-run) opt_dry=1 ;;
      -p|--port) shift; opt_port="${1-}" ;;
      -h|--help) _wake_usage; return 0 ;;
      --) shift; break ;;
      -*) _wake_usage; return 2 ;;
      *)  device="$1"; break ;;
    esac
    shift
  done

  if (( opt_list )); then
    local -a devs; _wake_collect_devices devs
    ((${#devs[@]})) && printf '%s\n' "${devs[@]}" || _omb_util_print "No devices configured in $_wake_cfgdir" >&2
    return 0
  fi

  local cfgfile="$_wake_cfgdir/${device-}"
  if [[ -z ${device-} || ! -f $cfgfile ]]; then
    _wake_usage
    local -a devs; _wake_collect_devices devs
    ((${#devs[@]})) && _omb_util_print "Available devices: ${devs[*]}" >&2 \
                     || _omb_util_print "No devices configured. Create $_wake_cfgdir first." >&2
    return 1
  fi

  if ! _omb_util_command_exists wakeonlan; then
    _omb_util_print "ERROR: 'wakeonlan' not found. Install it from https://github.com/jpoliv/wakeonlan." >&2
    return 1
  fi

  local mac bcast port
  if ! _wake_read_config "$device" mac bcast port; then
    _omb_util_print "ERROR: Invalid config in '$cfgfile'. Expected '<MAC> [BCAST] [PORT]' or key=value form." >&2
    return 1
  fi
  [[ -n $opt_port ]] && port="$opt_port"

  if (( opt_dry )); then
    _omb_util_print "DRY-RUN: wakeonlan -p $port -i $bcast $mac" >&2
    return 0
  fi

  wakeonlan -p "$port" -i "$bcast" "$mac"
}

function _omb_plugin_wake_completion {
  local cur=${COMP_WORDS[COMP_CWORD]}
  local -a flags choices
  flags=( -l --list -n --dry-run -p --port -h --help )
  [[ -d $_wake_cfgdir ]] && _wake_collect_devices choices || choices=()
  local IFS=$'\n'
  COMPREPLY=( $(compgen -W "$(printf '%s\n' "${flags[@]}" "${choices[@]}")" -- "$cur") )
}
complete -F _omb_plugin_wake_completion wake
