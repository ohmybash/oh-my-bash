#!/usr/bin/env bash

SCM_THEME_PROMPT_PREFIX="${cyan}(${green}"
SCM_THEME_PROMPT_SUFFIX="${cyan})"
SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${green}✓"

prompt() {
  PS1="$(scm_prompt_info)${reset_color} ${cyan}\W${reset_color} "
}

_omb_util_add_prompt_command prompt
