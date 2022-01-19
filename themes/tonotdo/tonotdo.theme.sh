#! bash oh-my-bash.module

SCM_THEME_PROMPT_PREFIX=" ${purple}"
SCM_THEME_PROMPT_SUFFIX=" ${normal}"
SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${green}✓"
SCM_GIT_SHOW_DETAILS="false"

function _omb_theme_PROMPT_COMMAND() {
  PS1="${yellow}\u${normal}${cyan}@\h${normal}${purple} ${normal}${green}\w${normal}$(scm_prompt_info)> "
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
