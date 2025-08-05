#!/usr/bin/env bash
# oh-my-bash.module: wake-on-lan wrapper + autocompletion
# wake.plugin.sh
# Author: hoek from 0ut3r.space
# Based on oh-my-zsh wake plugin @ commit 1d9eacb34f59f3bf82a9de0d7b474cb4c501e3fd

function wake() {
  local cfgdir="$HOME/.wakeonlan"
  local cfgfile="$cfgdir/$1"

  if [[ -z "$1" || ! -f "$cfgfile" ]]; then
    _omb_util_print "Usage: wake <device>"
    if [[ -d "$cfgdir" ]]; then
      _omb_util_print "Available devices: $(_omb_util_list "$cfgdir")"
    else
      _omb_util_print "No devices configured. Create $cfgdir directory first."
    fi
    return 1
  fi
  
  if ! _omb_util_command_exists wakeonlan; then
    _omb_util_print "ERROR: 'wakeonlan' not found. Install it (https://github.com/jpoliv/wakeonlan)." >&2
    return 1
  fi

  local IFS=$' \t\n'
  local mac bcast
  read -r mac bcast < "$cfgfile"

  if [[ -z "$mac" || -z "$bcast" ]]; then
    _omb_util_print "ERROR: Invalid config format in '$cfgfile'. Expected: <MAC> <broadcast-IP>" >&2
    return 1
  fi

  wakeonlan -i "$bcast" "$mac"
}

_wake_completion() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local cfgdir="$HOME/.wakeonlan"
  [[ -d "$cfgdir" ]] || return 0
  COMPREPLY=( $(compgen -W "$(ls "$cfgdir")" -- "$cur") )
}
complete -F _wake_completion wake
