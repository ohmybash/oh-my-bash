#! bash oh-my-bash.module

# Two line prompt showing the following information:
# (time) SCM [username@hostname] pwd (SCM branch SCM status)
# →
#
# Example:
# (14:00:26) ± [foo@bar] ~/.oh-my-bash (master ✓)
# →
#
# The arrow on the second line is showing the exit status of the last command:
# * Green: 0 exit status
# * Red: non-zero exit status
#
# The exit code functionality currently doesn't work if you are using the 'fasd' plugin,
# since 'fasd' is messing with the $PROMPT_COMMAND


PROMPT_END_CLEAN="${_omb_prompt_green}→${_omb_prompt_reset_color}"
PROMPT_END_DIRTY="${_omb_prompt_brown}→${_omb_prompt_reset_color}"

function prompt_end() {
  echo -e "$PROMPT_END"
}

function _omb_theme_PROMPT_COMMAND {
  local exit_status=$?
  if [[ $exit_status -eq 0 ]]; then PROMPT_END=$PROMPT_END_CLEAN
    else PROMPT_END=$PROMPT_END_DIRTY
  fi
  # Save history
  #history -a
  #history -c
  #history -r
  PS1="($(clock_prompt)) $(scm_char) [${_omb_prompt_navy}\u${_omb_prompt_reset_color}@${_omb_prompt_green}\H${_omb_prompt_reset_color}] ${_omb_prompt_olive}\w${_omb_prompt_reset_color}$(scm_prompt_info) ${_omb_prompt_reset_color}\n$(prompt_end) "
  PS2='> '
  PS4='+ '
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND

SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_bold_brown}✗${_omb_prompt_normal}"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓${_omb_prompt_normal}"
SCM_THEME_PROMPT_PREFIX=" ("
SCM_THEME_PROMPT_SUFFIX=")"
RVM_THEME_PROMPT_PREFIX=" ("
RVM_THEME_PROMPT_SUFFIX=")"
