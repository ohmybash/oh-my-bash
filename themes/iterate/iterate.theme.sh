#!/usr/bin/env bash
SCM_GIT_CHAR="± "
SCM_HG_CHAR="☿ "
SCM_SVN_CHAR="⑆ "
SCM_NONE_CHAR=""
SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓"
SCM_THEME_PROMPT_PREFIX="|"
SCM_THEME_PROMPT_SUFFIX="${green}| "
SCM_GIT_AHEAD_CHAR="${green}+"
SCM_GIT_BEHIND_CHAR="${red}-"

GIT_THEME_PROMPT_DIRTY=" ${bold_red}✗"
GIT_THEME_PROMPT_CLEAN=" ${bold_green}✓"
GIT_THEME_PROMPT_PREFIX="${cyan}|"
GIT_THEME_PROMPT_SUFFIX="${cyan}| "

RVM_THEME_PROMPT_PREFIX="|"
RVM_THEME_PROMPT_SUFFIX="| "

VIRTUALENV_THEME_PROMPT_PREFIX="|"
VIRTUALENV_THEME_PROMPT_SUFFIX="| "

RBENV_THEME_PROMPT_PREFIX="|"
RBENV_THEME_PROMPT_SUFFIX="| "

RBFU_THEME_PROMPT_PREFIX="|"
RBFU_THEME_PROMPT_SUFFIX="| "

function git_prompt_info {
  git_prompt_vars
  echo -e "$SCM_PREFIX$SCM_BRANCH$SCM_STATE$SCM_GIT_AHEAD$SCM_GIT_BEHIND$SCM_GIT_STASH$SCM_SUFFIX"
}

LAST_PROMPT=""
function prompt_command() {
    local new_PS1="${bold_cyan}$(scm_char)${yellow}$(_omb_prompt_print_ruby_env)${green}\w $(scm_prompt_info)"
    local new_prompt=$(PS1="$new_PS1" "$BASH" --norc -i </dev/null 2>&1 | sed -n '${s/^\(.*\)exit$/\1/p;}')

    if [ "$LAST_PROMPT" = "$new_prompt" ]; then
        new_PS1=""
    else
        LAST_PROMPT="$new_prompt"
    fi

    local wrap_char=""
    [[ ${#new_PS1} -gt $(($COLUMNS/1)) ]] && wrap_char="\n"
    PS1="${new_PS1}${green}${wrap_char}→${reset_color} "
}

_omb_util_add_prompt_command prompt_command
