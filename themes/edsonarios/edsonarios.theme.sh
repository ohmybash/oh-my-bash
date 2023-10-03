#! bash oh-my-bash.module

# If you want the same background color that the screenshot, modify the
# background option in your terminal with the code: #333333

# For unstaged(*) and staged(+) values next to branch name in __git_ps1
GIT_PS1_SHOWDIRTYSTATE="enabled"
OMB_PROMPT_VIRTUALENV_FORMAT=' [%s]'
OMB_PROMPT_CONDAENV_FORMAT=' [%s]'

OMB_THEME_EDSONARIOS_STATUS_BAD="${_omb_prompt_bold_brown}❯_${_omb_prompt_normal} "
OMB_THEME_EDSONARIOS_STATUS_OK="${_omb_prompt_bold_green}❯_${_omb_prompt_normal} "

function _omb_theme_PROMPT_COMMAND {
  if (($? == 0)); then
    local ret_status=${OMB_THEME_EDSONARIOS_STATUS_OK-}
  else
    local ret_status=${OMB_THEME_EDSONARIOS_STATUS_BAD-}
  fi

  # If the current directory is the same as HOME, will just show "~/".  If not,
  # show the complete route unlike \w.
  if [[ $PWD == "$HOME" ]]; then
    local directory='\W/'
  else
    local directory="$PWD/"
  fi

  local python_venv
  _omb_prompt_get_python_venv

  PS1="\n⚡ \t $_omb_prompt_bold_teal${directory}$_omb_prompt_bold_purple$python_venv$_omb_prompt_bold_green$(__git_ps1 " (%s)") \n${ret_status}"
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
