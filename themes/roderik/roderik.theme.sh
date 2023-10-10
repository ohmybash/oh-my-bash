#! bash oh-my-bash.module

GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWSTASHSTATE=true

export PROMPT_DIRTRIM=${PROMPT_DIRTRIM:-3}

function _omb_theme_PROMPT_COMMAND {
  local color=$_omb_prompt_teal
  if ((EUID == 0)); then
    color=$_omb_prompt_brown
  fi

  PS1="[$(clock_prompt)]"
  PS1+="${_omb_prompt_olive}[${color}\u@\h ${_omb_prompt_green}\w${_omb_prompt_olive}]"
  PS1+="${_omb_prompt_brown}$(__git_ps1 "(%s)")${_omb_prompt_normal}\\$ "
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
