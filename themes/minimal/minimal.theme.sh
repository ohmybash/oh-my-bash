#! bash oh-my-bash.module

SCM_THEME_PROMPT_PREFIX="${_omb_prompt_teal}(${_omb_prompt_green}"
SCM_THEME_PROMPT_SUFFIX="${_omb_prompt_teal})"
SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_brown}✗"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_green}✓"

function _omb_theme_PROMPT_COMMAND {
  PS1="$(scm_prompt_info)${_omb_prompt_reset_color} ${_omb_prompt_teal}\W${_omb_prompt_reset_color} "
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
