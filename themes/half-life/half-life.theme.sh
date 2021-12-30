#!/usr/bin/env bash

OSH_THEME_GIT_PROMPT_DIRTY="✗"
OSH_THEME_GIT_PROMPT_CLEAN="✓"

# Nicely formatted terminal prompt
ps_scm_prompt() {
  local CHAR=$(scm_char)
  if [ "$CHAR" = "$SCM_NONE_CHAR" ]
    then
      return
    else
      echo " on ${blue}$(git_current_branch)$(parse_git_dirty)${normal} "
  fi
}

prompt_command() {
  local ps_username="${purple}\u${normal}"
  local ps_path="${green}\w${normal}"
  local ps_user_mark="${orange}λ${normal}"

  PS1="$ps_username in $ps_path$(ps_scm_prompt) $ps_user_mark "
}


safe_append_prompt_command prompt_command
