#! bash oh-my-bash.module

export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWSTASHSTATE=true

export PROMPT_DIRTRIM=3

function _omb_theme_PROMPT_COMMAND() {
    if [[ ${EUID} == 0 ]] ; then
        PS1="[$(clock_prompt)]${yellow}[${red}\u@\h ${green}\w${yellow}]${red}$(__git_ps1 "(%s)")${_omb_prompt_normal}\\$ "
    else
        PS1="[$(clock_prompt)]${yellow}[${_omb_prompt_cyan}\u@\h ${green}\w${yellow}]${red}$(__git_ps1 "(%s)")${_omb_prompt_normal}\\$ "
    fi
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
