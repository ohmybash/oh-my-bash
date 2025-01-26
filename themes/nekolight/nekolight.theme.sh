#! bash oh-my-bash.module

_omb_theme_nekolight_version='1.0.0'

_omb_theme_nekolight_symbol=""

function _omb_theme_nekolight_git_info() {
  if _omb_prompt_git rev-parse --is-inside-work-tree &>/dev/null; then
    local _omb_prompt_nekolight_branch=$(_omb_prompt_git branch --show-current 2>/dev/null)

    if _omb_prompt_git diff --quiet 2>/dev/null && _omb_prompt_git diff --cached --quiet 2>/dev/null; then
      _omb_util_print "on ${_omb_prompt_bold_green}${_omb_prompt_nekolight_branch} ${_omb_theme_nekolight_symbol}${_omb_prompt_normal}"
    else
      _omb_util_print "on ${_omb_prompt_bold_red}${_omb_prompt_nekolight_branch} ${_omb_theme_nekolight_symbol}${_omb_prompt_normal}"
    fi
  fi
}

function _omb_theme_PROMPT_COMMAND() {
  local _omb_prompt_nekolight_dir="${_omb_prompt_bold_blue}\w${_omb_prompt_normal}"
  local _omb_prompt_nekolight_git_status=$(_omb_theme_nekolight_git_info)

  PS1="${_omb_prompt_nekolight_dir} ${_omb_prompt_nekolight_git_status}\n❯ "

}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
