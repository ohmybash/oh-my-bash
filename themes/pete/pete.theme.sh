#! bash oh-my-bash.module

function _omb_theme_PROMPT_COMMAND {
  # Save history
  history -a
  history -c
  history -r
  PS1="($(clock_prompt)) $(scm_char) [$_omb_prompt_navy\u$_omb_prompt_reset_color@$_omb_prompt_green\H$_omb_prompt_reset_color] $_omb_prompt_olive\w${_omb_prompt_reset_color}$(scm_prompt_info)$(_omb_prompt_print_ruby_env) $_omb_prompt_reset_color "
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
