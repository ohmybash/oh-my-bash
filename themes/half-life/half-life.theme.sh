#!/usr/bin/env bash

OSH_THEME_GIT_PROMPT_DIRTY="✗"
OSH_THEME_GIT_PROMPT_CLEAN="✓"

# Nicely formatted terminal prompt
_omb_theme_half_way_prompt_scm() {
  local CHAR=$(scm_char)
  if [[ $CHAR != "$SCM_NONE_CHAR" ]]; then
    printf '%s' " on ${blue}$(git_current_branch)$(parse_git_dirty)${normal} "
  fi
}

prompt_command() {
  local ps_username="${purple}\u${normal}"
  local ps_path="${green}\w${normal}"
  local ps_user_mark="${orange}λ${normal}"

  PS1="$ps_username in $ps_path$(_omb_theme_half_way_prompt_scm) $ps_user_mark "
}

_omb_util_add_prompt_command prompt_command
