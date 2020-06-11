#! bash oh-my-bash.module

export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWSTASHSTATE=true

export PROMPT_DIRTRIM=${PROMPT_DIRTRIM:-3}

function _omb_theme_PROMPT_COMMAND() {
    if [[ ${EUID} == 0 ]] ; then
        PS1="[$(clock_prompt)]${_omb_prompt_olive}[${_omb_prompt_brown}\u@\h ${_omb_prompt_green}\w${_omb_prompt_olive}]${_omb_prompt_brown}$(__git_ps1 "(%s)")${_omb_prompt_normal}\\$ "
    else
        PS1="[$(clock_prompt)]${_omb_prompt_olive}[${_omb_prompt_teal}\u@\h ${_omb_prompt_green}\w${_omb_prompt_olive}]${_omb_prompt_brown}$(__git_ps1 "(%s)")${_omb_prompt_normal}\\$ "
    fi
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
