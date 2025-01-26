#! bash oh-my-bash.module

#! bash oh-my-bash.module

_omb_theme_nekolight_version='1.0.0'
_omb_theme_nekolight_symbol=""

function _omb_theme_nekolight_git_info() {
  if _omb_prompt_git rev-parse --is-inside-work-tree &>/dev/null; then
    local branch=$(_omb_prompt_git symbolic-ref --short HEAD 2>/dev/null || _omb_prompt_git rev-parse --short HEAD 2>/dev/null)

    if _omb_prompt_git diff --quiet 2>/dev/null && _omb_prompt_git diff --cached --quiet 2>/dev/null; then
      echo "${_omb_prompt_bold_green}${branch} ${_omb_theme_nekolight_symbol}${_omb_prompt_normal}"
    else
      echo "${_omb_prompt_bold_red}${branch} ${_omb_theme_nekolight_symbol}${_omb_prompt_normal}"
    fi
  else
    echo ""
  fi
}

function _omb_theme_PROMPT_COMMAND() {
  local display_dir="${_omb_prompt_bold_blue}\w${_omb_prompt_normal}"
  local git_status=$(_omb_theme_nekolight_git_info)

  PS1="${display_dir} ${git_status}\n❯ "
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND

