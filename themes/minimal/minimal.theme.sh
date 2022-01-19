#! bash oh-my-bash.module

SCM_THEME_PROMPT_PREFIX="${_omb_prompt_cyan}(${green}"
SCM_THEME_PROMPT_SUFFIX="${_omb_prompt_cyan})"
SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${green}✓"

_omb_theme_PROMPT_COMMAND() {
  PS1="$(scm_prompt_info)${_omb_prompt_reset_color} ${_omb_prompt_cyan}\W${_omb_prompt_reset_color} "
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
