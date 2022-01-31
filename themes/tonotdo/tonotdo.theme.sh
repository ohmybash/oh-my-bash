#! bash oh-my-bash.module

SCM_THEME_PROMPT_PREFIX=" ${_omb_prompt_purple}"
SCM_THEME_PROMPT_SUFFIX=" ${_omb_prompt_normal}"
SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_brown}✗"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_green}✓"
SCM_GIT_SHOW_DETAILS="false"

function _omb_theme_PROMPT_COMMAND() {
  PS1="${_omb_prompt_olive}\u${_omb_prompt_normal}${_omb_prompt_teal}@\h${_omb_prompt_normal}${_omb_prompt_purple} ${_omb_prompt_normal}${_omb_prompt_green}\w${_omb_prompt_normal}$(scm_prompt_info)> "
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
