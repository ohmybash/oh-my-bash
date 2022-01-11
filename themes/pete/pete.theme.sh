#! bash oh-my-bash.module

_omb_theme_PROMPT_COMMAND() {
  # Save history
  history -a
  history -c
  history -r
  PS1="($(clock_prompt)) $(scm_char) [$blue\u$reset_color@$green\H$reset_color] $yellow\w${reset_color}$(scm_prompt_info)$(_omb_prompt_print_ruby_env) $reset_color "
  PS2='> '
  PS4='+ '
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND

SCM_THEME_PROMPT_DIRTY=" ✗"
SCM_THEME_PROMPT_CLEAN=" ✓"
SCM_THEME_PROMPT_PREFIX=" ("
SCM_THEME_PROMPT_SUFFIX=")"
RVM_THEME_PROMPT_PREFIX=" ("
RVM_THEME_PROMPT_SUFFIX=")"
