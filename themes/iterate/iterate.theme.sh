#! bash oh-my-bash.module
SCM_GIT_CHAR="± "
SCM_HG_CHAR="☿ "
SCM_SVN_CHAR="⑆ "
SCM_NONE_CHAR=""
SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_brown}✗"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓"
SCM_THEME_PROMPT_PREFIX="|"
SCM_THEME_PROMPT_SUFFIX="${_omb_prompt_green}| "
SCM_GIT_AHEAD_CHAR="${_omb_prompt_green}+"
SCM_GIT_BEHIND_CHAR="${_omb_prompt_brown}-"

GIT_THEME_PROMPT_DIRTY=" ${_omb_prompt_bold_brown}✗"
GIT_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓"
GIT_THEME_PROMPT_PREFIX="${_omb_prompt_teal}|"
GIT_THEME_PROMPT_SUFFIX="${_omb_prompt_teal}| "

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
function _omb_theme_PROMPT_COMMAND() {
    local new_PS1="${_omb_prompt_bold_teal}$(scm_char)${_omb_prompt_olive}$(_omb_prompt_print_ruby_env)${_omb_prompt_green}\w $(scm_prompt_info)"
    local new_prompt=$(PS1="$new_PS1" "$BASH" --norc -i </dev/null 2>&1 | sed -n '${s/^\(.*\)exit$/\1/p;}')

    if [ "$LAST_PROMPT" = "$new_prompt" ]; then
        new_PS1=""
    else
        LAST_PROMPT="$new_prompt"
    fi

    local wrap_char=""
    [[ ${#new_PS1} -gt $(($COLUMNS/1)) ]] && wrap_char="\n"
    PS1="${new_PS1}${_omb_prompt_green}${wrap_char}→${_omb_prompt_reset_color} "
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
