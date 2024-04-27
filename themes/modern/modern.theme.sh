#! bash oh-my-bash.module
SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""

SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_bold_brown}✗${_omb_prompt_normal}"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓${_omb_prompt_normal}"
SCM_GIT_CHAR="${_omb_prompt_bold_green}±${_omb_prompt_normal}"
SCM_SVN_CHAR="${_omb_prompt_bold_teal}⑆${_omb_prompt_normal}"
SCM_HG_CHAR="${_omb_prompt_bold_brown}☿${_omb_prompt_normal}"

case $TERM in
xterm*)
  TITLEBAR="\[\033]0;\w\007\]"
  ;;
*)
  TITLEBAR=""
  ;;
esac

PS3=">> "

function is_vim_shell {
  if [[ $VIMRUNTIME ]]; then
    echo "[${_omb_prompt_teal}vim shell${_omb_prompt_normal}]"
  fi
}

function modern_scm_prompt {
  local CHAR=$(scm_char)
  if [[ $CHAR == "$SCM_NONE_CHAR" ]]; then
    return
  else
    echo "[$(scm_char)][$(scm_prompt_info)]"
  fi
}

function _omb_theme_PROMPT_COMMAND {
  if (($? != 0)); then
    PS1="${TITLEBAR}${_omb_prompt_bold_brown}┌─${_omb_prompt_reset_color}$(modern_scm_prompt)[${_omb_prompt_teal}\W${_omb_prompt_normal}][$(battery_charge)]$(is_vim_shell)"
    PS1=$PS1$'\n'"${_omb_prompt_bold_brown}└─▪${_omb_prompt_normal} "
  else
    PS1="${TITLEBAR}┌─$(modern_scm_prompt)[${_omb_prompt_teal}\W${_omb_prompt_normal}][$(battery_charge)]$(is_vim_shell)"
    PS1=$PS1$'\n'"└─▪ "
  fi
}

PS2="└─▪ "

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
