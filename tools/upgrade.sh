#!/usr/bin/env bash

function _omb_upgrade {
  # Use colors, but only if connected to a terminal, and that terminal
  # supports them.
  if type -P tput &>/dev/null; then
    local ncolors=$(tput colors)
  fi

  if [[ -t 1 && $ncolors && $ncolors -ge 8 ]]; then
    local RED=$(tput setaf 1)
    local GREEN=$(tput setaf 2)
    local YELLOW=$(tput setaf 3)
    local BLUE=$(tput setaf 4)
    local BOLD=$(tput bold)
    local NORMAL=$(tput sgr0)
  else
    local RED=""
    local GREEN=""
    local YELLOW=""
    local BLUE=""
    local BOLD=""
    local NORMAL=""
  fi

  printf "${BLUE}%s${NORMAL}\n" "Updating Oh My Bash"

  if ! command git -C "$OSH" pull --rebase --stat origin master; then
    # In case it enters the rebasing mode
    printf '%s\n' "oh-my-bash: running 'git rebase --abort'..."
    command git -C "$OSH" rebase --abort
    printf "${RED}%s${NORMAL}\n" \
           'There was an error updating.' \
           "If you have uncommited changes in '$BOLD$OSH$NORMAL$RED', please commit, stash or discard them and retry updating." \
           "If you have your own local commits in '$BOLD$OSH$NORMAL$RED' that conflict with the upstream changes, please resolve conflicts and merge the upstream manually."
    return 1
  fi

  printf '%s' "$GREEN"
  printf '%s\n' '         __                          __               __  '
  printf '%s\n' '  ____  / /_     ____ ___  __  __   / /_  ____ ______/ /_ '
  printf '%s\n' ' / __ \/ __ \   / __ `__ \/ / / /  / __ \/ __ `/ ___/ __ \'
  printf '%s\n' '/ /_/ / / / /  / / / / / / /_/ /  / /_/ / /_/ (__  ) / / /'
  printf '%s\n' '\____/_/ /_/  /_/ /_/ /_/\__, /  /_.___/\__,_/____/_/ /_/ '
  printf '%s\n' '                        /____/                            '
  printf "${BLUE}%s\n" "Hooray! Oh My Bash has been updated and/or is at the current version."
  printf "${BLUE}${BOLD}%s${NORMAL}\n" "To keep up on the latest news and updates, follow us on GitHub: https://github.com/ohmybash/oh-my-bash"
  if [[ $- == *i* ]]; then
    declare -f _omb_util_unload &>/dev/null && _omb_util_unload
    source ~/.bashrc
  fi
}
_omb_upgrade
