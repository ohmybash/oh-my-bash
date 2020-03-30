#!/usr/bin/env bash
#
# One line prompt showing the following configurable information
# for git:
# (virtual_env) username pwd git_char|git_branch git_dirty_status|→
#
# The → arrow shows the exit status of the last command:
# - bold green: 0 exit status
# - bold red: non-zero exit status
#
# Example outside git repo:
# 07:45:05 user@host ~ →
#
# Example inside clean git repo:
# 07:45:05 user@host ~/.oh-my-bash ±|master|→
#
# Example inside dirty git repo:
# 07:45:05 user@host ~/.oh-my-bash ±|master ✗|→
#
# Example with virtual environment:
# 07:45:05 (venv) user@host ~ →
#

export SCM_NONE_CHAR=''
export SCM_THEME_PROMPT_DIRTY=" ${red}✗"
export SCM_THEME_PROMPT_CLEAN=""
export SCM_THEME_PROMPT_PREFIX="${green}|"
export SCM_THEME_PROMPT_SUFFIX="${green}|"
export SCM_GIT_SHOW_MINIMAL_INFO=true

export VIRTUALENV_THEME_PROMPT_PREFIX='('
export VIRTUALENV_THEME_PROMPT_SUFFIX=') '

function prompt_command() {
    # This needs to be first to save last command return code
    local RC="$?"

    hostname="${bold_black}\u"
    virtualenv="${white}$(virtualenv_prompt)"

    # Set return status color
    if [[ ${RC} == 0 ]]; then
        ret_status="${bold_green}"
    else
        ret_status="${bold_red}"
    fi

    # Append new history lines to history file
    history -a

    PS1="${virtualenv}${hostname} ${bold_cyan}\w $(scm_prompt_char_info)${ret_status}→ ${normal}"
}

safe_append_prompt_command prompt_command
