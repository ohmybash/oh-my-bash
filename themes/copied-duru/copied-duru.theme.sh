#! bash oh-my-bash.module
# "Copied-Duru" Prompt, inspired by "Sexy" and obviously "Duru"

source "$OSH/themes/sexy/sexy.theme.sh"

if [[ $COLORTERM == gnome-* && $TERM == xterm ]] && infocmp gnome-256color &>/dev/null; then
  export TERM=gnome-256color
elif [[ $TERM != dumb ]] && infocmp xterm-256color &>/dev/null; then
  export TERM=xterm-256color
fi

function _omb_theme_PROMPT_COMMAND {
  local current_time='\D{%H:%M:%S}'
  local python_venv=
  local just_a_format=' '$MAGENTA'(%s)'

  if [[ $VIRTUAL_ENV ]]; then
    printf -v python_venv "$just_a_format" "${VIRTUAL_ENV##*/}"
  elif [[ $CONDA_DEFAULT_ENV ]]; then
    printf -v python_venv "$just_a_format" "${CONDA_DEFAULT_ENV##*/}"
  fi

  local git_prefix=
  [[ $(_omb_prompt_git branch 2> /dev/null) ]] && git_prefix=' on '
  
  PS1=$GREEN'#'$python_venv' '$PURPLE'\u@'$WHITE'\h'$GREEN
  PS1+=' '$current_time'>'$RESET
  PS1+=' '$PURPLE'<\w'$WHITE$git_prefix$MAGENTA$(parse_git_branch)
  PS1+=$PURPLE'>'$RESET'\n'$GREEN'$ '$RESET
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
