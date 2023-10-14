#!/usr/bin/env bash

# Theme inspired by:
#  - ys theme - https://github.com/ohmyzsh/ohmyzsh/blob/master/themes/ys.zsh-theme
#  - rana theme - https://github.com/ohmybash/oh-my-bash/blob/master/themes/rana/rana.theme.sh
#
# by Ziqiang Pei<ziqiangpei@foxmail.com>

OMB_PROMPT_CONDAENV_FORMAT='(%s)'
OMB_PROMPT_VIRTUALENV_FORMAT='(%s)'
OMB_PROMPT_SHOW_PYTHON_VENV=${OMB_PROMPT_SHOW_PYTHON_VENV:=true}

# ----------------------------------------------------------------- COLOR CONF
D_DEFAULT_COLOR="$_omb_prompt_white"
D_INTERMEDIATE_COLOR="$_omb_prompt_bold_white"
D_NUMBER_COLOR="$_omb_prompt_bold_navy"
D_USER_COLOR="$_omb_prompt_teal"
D_SUPERUSER_COLOR="$_omb_prompt_brown"
D_MACHINE_COLOR="$_omb_prompt_green"
D_DIR_COLOR="$_omb_prompt_bold_olive"
D_GIT_DEFAULT_COLOR="$_omb_prompt_white"
D_GIT_BRANCH_COLOR="$_omb_prompt_teal"
D_GIT_PROMPT_COLOR="$_omb_prompt_brown"
D_SCM_COLOR="$_omb_prompt_bold_olive"
D_BRANCH_COLOR="$_omb_prompt_teal"
D_CHANGES_COLOR="$_omb_prompt_white"
D_TIME_COLOR="$_omb_prompt_white"
D_DOLLOR_COLOR="$_omb_prompt_bold_brown"
D_CMDFAIL_COLOR="$_omb_prompt_brown"
D_VIMSHELL_COLOR="$_omb_prompt_teal"

# ------------------------------------------------------------------ FUNCTIONS
case $TERM in
  xterm*)
    TITLEBAR='\[\e]0;\w\e\\\]'
    ;;
  *)
    TITLEBAR=""
    ;;
esac

function is_vim_shell {
  if [[ ${VIMRUNTIME-} ]]; then
    echo "${D_INTERMEDIATE_COLOR}on ${D_VIMSHELL_COLOR}vim shell${D_DEFAULT_COLOR} "
  fi
}

function mitsuhikos_lastcommandfailed {
  local status=$?
  if ((status != 0)); then
    echo " ${D_DEFAULT_COLOR}C:${D_CMDFAIL_COLOR}$code ${D_DEFAULT_COLOR}"
  fi
}

# vcprompt for scm instead of oh-my-bash default
function demula_vcprompt {
  if [[ ${VCPROMPT_EXECUTABLE-} ]]; then
    local D_VCPROMPT_FORMAT="on ${D_SCM_COLOR}%s${D_INTERMEDIATE_COLOR}:${D_BRANCH_COLOR}%b %r ${D_CHANGES_COLOR}%m%u ${D_DEFAULT_COLOR}"
    $VCPROMPT_EXECUTABLE -f "$D_VCPROMPT_FORMAT"
  fi
}

# checks if the plugin is installed before calling battery_charge
function safe_battery_charge {
  if _omb_util_function_exists battery_charge; then
    battery_charge
  fi
}

function prompt_git {
  local branchName=''

  # Check if the current directory is in a Git repository.
  if _omb_prompt_git rev-parse --is-inside-work-tree &>/dev/null; then
    # Get the short symbolic ref.
    # If HEAD isn’t a symbolic ref, get the short SHA for the latest commit
    # Otherwise, just give up.
    branchName=$(
      _omb_prompt_git symbolic-ref --quiet --short HEAD 2> /dev/null ||
        _omb_prompt_git rev-parse --short HEAD 2> /dev/null ||
        echo '(unknown)');

    echo "${D_GIT_DEFAULT_COLOR}on ${D_GIT_BRANCH_COLOR}${branchName} "
  else
    return
  fi
}

function limited_pwd {
  # Max length of PWD to display
  local MAX_PWD_LENGTH=20

  # Replace $HOME with ~ if possible
  local RELATIVE_PWD=${PWD/#$HOME/\~}

  local offset=$((${#RELATIVE_PWD}-MAX_PWD_LENGTH))

  if ((offset > 0)); then
    local truncated_symbol='...'
    local TRUNCATED_PWD=${RELATIVE_PWD:offset:MAX_PWD_LENGTH}
    echo -n "${truncated_symbol}/${TRUNCATED_PWD#*/}"
  else
    echo -n "${RELATIVE_PWD}"
  fi
}

# -------------------------------------------------------------- PROMPT OUTPUT
function _omb_theme_PROMPT_COMMAND {
  local LAST_COMMAND_FAILED=$(mitsuhikos_lastcommandfailed)
  local SAVE_CURSOR='\[\e7'
  local RESTORE_CURSOR='\e8\]'
  local MOVE_CURSOR_RIGHTMOST='\e['${COLUMNS:-9999}'C'
  local MOVE_CURSOR_5_LEFT='\e[5D'
  local THEME_CLOCK_FORMAT="%H:%M:%S %y-%m-%d"
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
  PS1+="in ${D_DIR_COLOR}${RELATIVE_PWD} ${D_INTERMEDIATE_COLOR}"
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

# Runs prompt (this bypasses oh-my-bash $PROMPT setting)
_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
