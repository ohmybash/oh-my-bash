#!/usr/bin/env bash
# vim: ft=bash ts=2 sw=2 sts=2
#
# absimple theme: a fork of the agnoster theme
#
# Tested on Termux in Android 2022-02-15
#
# The aim of this theme is to only show you relevant information: The
# git information will only be shown in a git working directory.
# Similarly, everything will be displayed automatically when
# appropriate, including the current user and the hostname, whether
# the last call exited with an error, and whether background jobs are
# running in this shell.


# Note: a most part of this theme is the same as "agnoster", so let us source
# the original theme "agnoster" and just override its functions.  In this way,
# the maintenance becomes easier.
source "$OSH/themes/agnoster/agnoster.theme.sh"

######################################################################
### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts


# prints history followed by HH:MM, useful for remembering what
# we did previously
function prompt_histdt {
    prompt_segment black default "\!" # \A"
}

# Dir: current working directory
function prompt_dir {
    prompt_segment blue black '\W'
}

######################################################################

# quick right prompt I grabbed to test things.
function __command_rprompt {
    local times= n=$COLUMNS tz
    for tz in ZRH:Europe/Zurich PIT:US/Eastern \
              MTV:US/Pacific TOK:Asia/Tokyo; do
        [ $n -gt 40 ] || break
        times="$times ${tz%%:*}\e[30;1m:\e[0;36;1m"
        times="$times$(TZ=${tz#*:} date +%H:%M:%S)\e[0m"
        n=$(( $n - 10 ))
    done
    [ -z "$times" ] || printf "%${n}s$times\\r" ''
}

######################################################################
## Main prompt

function build_prompt {
    [[ ! -z ${AG_EMACS_DIR+x} ]] && prompt_emacsdir
    prompt_status
    [[ -z ${AG_NO_HIST+x} ]] && prompt_histdt
    #[[ -z ${AG_NO_CONTEXT+x} ]] && prompt_context
    if [[ ${OMB_PROMPT_SHOW_PYTHON_VENV-} ]]; then
      prompt_virtualenv
      prompt_condaenv
    fi
    prompt_dir
    prompt_git
    prompt_end
}

# from orig...
# export PS1='$(ansi_single $(text_effect reset)) $(build_prompt) '
# this doesn't work... new model: create a prompt via a PR variable and
# use that.

function _omb_theme_PROMPT_COMMAND {
    local RETVAL=$?
    local PRIGHT=""
    local CURRENT_BG=NONE
    local PR="$(ansi_single $(text_effect reset))"
    build_prompt

    PS1=""
    # date randomly or once per hour
    if (( $(shuf -i 1-20 -n 1 --random-source=/dev/urandom) == 1 )) ; then #TK || (($PSDATE != $(date +%H))) ; then
        PS1+="\$(date +%a) $(date +%Y-%m-%d) "
    fi
    PSDATE=$(date +%H)
    # ... and time
    PS1+="$(date +%H:%M:%S) "

    # uncomment below to use right prompt
    #     PS1='\[$(tput sc; printf "%*s" $COLUMNS "$PRIGHT"; tput rc)\]'$PR
    PS1+=$PR
}
_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
