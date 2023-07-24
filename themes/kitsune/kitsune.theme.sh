#! bash oh-my-bash.module
# This is combination of works from two different people which I combined for my requirement.
# Original PS1 was from reddit user /u/Allevil669 which I found in thread: https://www.reddit.com/r/linux/comments/1z33lj/linux_users_whats_your_favourite_bash_prompt/
# I used that PS1 to the bash-it theme 'morris', and customized it to my liking. All credits to /u/Allevil669 and morris.
#
# prompt theming

_omb_module_require plugin:battery

function _omb_theme_PROMPT_COMMAND() {
  local status=$?

  # added TITLEBAR for updating the tab and window titles with the pwd
  local TITLEBAR
  case $TERM in
  xterm* | screen)
    TITLEBAR=$'\1\e]0;'$USER@${HOSTNAME%%.*}:${PWD/#$HOME/~}$'\e\\\2' ;;
  *)
    TITLEBAR= ;;
  esac

  local SC
  if ((status == 0)); then
    SC="$_omb_prompt_teal-$_omb_prompt_bold_green(${_omb_prompt_green}^_^$_omb_prompt_bold_green)";
  else
    SC="$_omb_prompt_teal-$_omb_prompt_bold_green(${_omb_prompt_brown}T_T$_omb_prompt_bold_green)";
  fi

  local BC=$(battery_percentage)
  [[ $BC == no && $BC == -1 ]] && BC=
  BC=${BC:+${_omb_prompt_teal}-${_omb_prompt_green}($BC%)}

  local python_venv
  _omb_prompt_get_python_venv

  PS1=$TITLEBAR"\n${_omb_prompt_teal}┌─${_omb_prompt_bold_white}[\u@\h]${_omb_prompt_teal}─${_omb_prompt_bold_olive}(\w)$(scm_prompt_info)$python_venv\n${_omb_prompt_teal}└─${_omb_prompt_bold_green}[\A]$SC$BC${_omb_prompt_teal}-${_omb_prompt_bold_teal}[${_omb_prompt_green}${_omb_prompt_bold_green}\$${_omb_prompt_bold_teal}]${_omb_prompt_green} "
}

# scm theming
SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_brown}✗"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓"
SCM_THEME_PROMPT_PREFIX="${_omb_prompt_bold_teal}("
SCM_THEME_PROMPT_SUFFIX="${_omb_prompt_bold_teal})${_omb_prompt_reset_color}"

OMB_PROMPT_SHOW_PYTHON_VENV=${OMB_PROMPT_SHOW_PYTHON_VENV:-false}
OMB_PROMPT_VIRTUALENV_FORMAT="${_omb_prompt_bold_gray}(%s)${_omb_prompt_reset_color}"
OMB_PROMPT_CONDAENV_FORMAT="${_omb_prompt_bold_gray}(%s)${_omb_prompt_reset_color}"

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
