#! bash oh-my-bash.module

OSH_THEME_GIT_PROMPT_DIRTY="✗"
OSH_THEME_GIT_PROMPT_CLEAN="✓"

# Nicely formatted terminal prompt
function _omb_theme_half_way_prompt_scm {
  local CHAR=$(scm_char)
  if [[ $CHAR != "$SCM_NONE_CHAR" ]]; then
    printf '%s' " on ${_omb_prompt_navy}$(git_current_branch)$(parse_git_dirty)${_omb_prompt_normal} "
  fi
}

function _omb_theme_PROMPT_COMMAND {
  local ps_username="${_omb_prompt_purple}\u${_omb_prompt_normal}"
  local ps_path="${_omb_prompt_green}\w${_omb_prompt_normal}"
  local ps_user_mark="${_omb_prompt_red}λ${_omb_prompt_normal}"

  local python_venv
  _omb_prompt_get_python_venv

  PS1="$ps_username in $python_venv$ps_path$(_omb_theme_half_way_prompt_scm) $ps_user_mark "
}

OMB_PROMPT_SHOW_PYTHON_VENV=${OMB_PROMPT_SHOW_PYTHON_VENV:-false}
OMB_PROMPT_VIRTUALENV_FORMAT="${_omb_prompt_olive}(%s)${_omb_prompt_reset_color} "

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
