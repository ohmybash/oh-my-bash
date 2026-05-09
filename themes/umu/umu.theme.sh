#!/usr/bin/env bash

# Base on pzq
source "$OSH/themes/pzq/pzq.theme.sh"

function _omb_theme_PROMPT_COMMAND {
  local LAST_COMMAND_FAILED=$(mitsuhikos_lastcommandfailed)
  local SAVE_CURSOR='\[\e7'
  local RESTORE_CURSOR='\e8\]'
  local MOVE_CURSOR_RIGHTMOST='\e['${COLUMNS:-9999}'C'
  local MOVE_CURSOR_5_LEFT='\e[5D'
  local THEME_CLOCK_FORMAT="%Y-%m-%dT%H:%M:%S.%N%:::z"
  # Replace $HOME with ~ if possible
  local RELATIVE_PWD=${PWD/#$HOME/\~}

  local python_venv
  _omb_prompt_get_python_venv

  PS1=${TITLEBAR}$python_venv$'\n'
  if [[ $OSTYPE == linux-gnu ]]; then
    PS1+="${SAVE_CURSOR}${MOVE_CURSOR_RIGHTMOST}${MOVE_CURSOR_5_LEFT}"
    PS1+="$(safe_battery_charge)${RESTORE_CURSOR}"
    PS1+="${D_NUMBER_COLOR}# ${D_USER_COLOR}\u ${D_DEFAULT_COLOR}"
  else
    PS1+="${D_NUMBER_COLOR}# ${D_USER_COLOR}\u ${D_DEFAULT_COLOR}"
  fi
  PS1+="@ ${D_MACHINE_COLOR}\h ${D_DEFAULT_COLOR}"
  PS1+="${D_DIR_COLOR}${RELATIVE_PWD} ${D_INTERMEDIATE_COLOR}"
  PS1+=$(prompt_git)
  PS1+=${D_TIME_COLOR}[$(clock_prompt)]
  PS1+=${LAST_COMMAND_FAILED}
  PS1+=$(demula_vcprompt)
  PS1+=$(is_vim_shell)
  if [[ $OSTYPE != linux-gnu ]]; then
    PS1+=$(safe_battery_charge)
  fi
  PS1+=$'\n'"${D_DOLLOR_COLOR}$ ${D_DEFAULT_COLOR}"

  PS2="${D_INTERMEDIATE_COLOR}$ ${D_DEFAULT_COLOR}"
}
