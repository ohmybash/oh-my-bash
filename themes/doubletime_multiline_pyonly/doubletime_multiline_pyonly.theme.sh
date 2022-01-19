#! bash oh-my-bash.module

source "$OSH/themes/doubletime/doubletime.theme.sh"

function _omb_theme_PROMPT_COMMAND() {
  # Save history
  history -a
  history -c
  history -r
  PS1="
$(clock_prompt) $(scm_char) [$THEME_PROMPT_HOST_COLOR\u@${THEME_PROMPT_HOST}$_omb_prompt_reset_color] $(_omb_prompt_print_python_venv)
\w
$(doubletime_scm_prompt)$_omb_prompt_reset_color $ "
  PS2='> '
  PS4='+ '
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
