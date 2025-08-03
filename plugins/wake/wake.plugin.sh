#!/usr/bin/env bash
# oh-my-bash.module: wake-on-lan wrapper + autocompletion
# wake.plugin.sh
# Author: hoek from 0ut3r.space
# Based on oh-my-zsh wake plugin

function wake() {
  local cfgdir="$HOME/.wakeonlan"
  local cfgfile="$cfgdir/$1"

  if [[ -z "$1" || ! -f "$cfgfile" ]]; then
    echo "Usage: wake <device>"
   if [[ -d "$cfgdir" ]]; then
     echo "Available devices: $(ls "$cfgdir" | tr '\n' ' ')"
   else
     echo "No devices configured. Create $cfgdir directory first."
   fi
    return 1
  fi

  if ! command -v wakeonlan >/dev/null; then
    echo "ERROR: 'wakeonlan' not found. Install it (https://github.com/jpoliv/wakeonlan)." >&2
    return 1
  fi

  # Read the two fields: MAC and broadcast-IP
  local mac bcast
  read -r mac bcast < "$cfgfile"
 if [[ -z "$mac" || -z "$bcast" ]]; then
   echo "ERROR: Invalid config format in '$cfgfile'. Expected: <MAC> <broadcast-IP>" >&2
   return 1
 fi

  # Send magic-packet to the given broadcast address
  wakeonlan -i "$bcast" "$mac"
}

# autocomplete device names from ~/.wakeonlan
_wake_completion() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local cfgdir="$HOME/.wakeonlan"
  [[ -d "$cfgdir" ]] || return 0
  COMPREPLY=( $(compgen -W "$(ls "$cfgdir")" -- "$cur") )
}
complete -F _wake_completion wake
