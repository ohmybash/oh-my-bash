#!/usr/bin/env bash

source "$OSH/themes/doubletime/doubletime.theme.sh"

function prompt_setter() {
  # Save history
  history -a
  history -c
  history -r
  PS1="
$(clock_prompt) $(scm_char) [$THEME_PROMPT_HOST_COLOR\u@${THEME_PROMPT_HOST}$reset_color] $(_omb_prompt_print_python_venv)$(_omb_prompt_print_ruby_env)
\w
$(doubletime_scm_prompt)$reset_color $ "
  PS2='> '
  PS4='+ '
}

_omb_util_add_prompt_command prompt_setter
