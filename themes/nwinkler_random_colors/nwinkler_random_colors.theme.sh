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

RANDOM_COLOR_FILE=$HOME/.nwinkler_random_colors

function randomize_nwinkler {
  declare -a AVAILABLE_COLORS

  AVAILABLE_COLORS=(
    "$_omb_prompt_black"
    "$_omb_prompt_brown"
    "$_omb_prompt_green"
    "$_omb_prompt_olive"
    "$_omb_prompt_navy"
    "$_omb_prompt_purple"
    "$_omb_prompt_teal"
    "$_omb_prompt_white"
    "$_omb_prompt_red"
    "$_omb_prompt_bold_black"
    "$_omb_prompt_bold_brown"
    "$_omb_prompt_bold_green"
    "$_omb_prompt_bold_olive"
    "$_omb_prompt_bold_navy"
    "$_omb_prompt_bold_purple"
    "$_omb_prompt_bold_teal"
    "$_omb_prompt_bold_white"
    "$_omb_prompt_bold_red"

    # # Uncomment these to allow underlines:
    # "$_omb_prompt_underline_black"
    # "$_omb_prompt_underline_brown"
    # "$_omb_prompt_underline_green"
    # "$_omb_prompt_underline_olive"
    # "$_omb_prompt_underline_navy"
    # "$_omb_prompt_underline_purple"
    # "$_omb_prompt_underline_teal"
    # "$_omb_prompt_underline_white"
    # "$_omb_prompt_underline_red"
  )

  USERNAME_COLOR=${AVAILABLE_COLORS[$RANDOM % ${#AVAILABLE_COLORS[@]} ]}
  HOSTNAME_COLOR=${AVAILABLE_COLORS[$RANDOM % ${#AVAILABLE_COLORS[@]} ]}
  TIME_COLOR=${AVAILABLE_COLORS[$RANDOM % ${#AVAILABLE_COLORS[@]} ]}
  THEME_CLOCK_COLOR=$TIME_COLOR
  PATH_COLOR=${AVAILABLE_COLORS[$RANDOM % ${#AVAILABLE_COLORS[@]} ]}

  echo "$USERNAME_COLOR,$HOSTNAME_COLOR,$TIME_COLOR,$PATH_COLOR," > $RANDOM_COLOR_FILE
}

if [ -f $RANDOM_COLOR_FILE ];
then
  # read the colors already stored in the file
  IFS=',' read -ra COLORS < $RANDOM_COLOR_FILE
  USERNAME_COLOR=${COLORS[0]}
  HOSTNAME_COLOR=${COLORS[1]}
  TIME_COLOR=${COLORS[2]}
  THEME_CLOCK_COLOR=$TIME_COLOR
  PATH_COLOR=${COLORS[3]}
else
  # No colors stored yet. Generate them!
  randomize_nwinkler

  echo
  echo "Looks like you are using the nwinkler_random_color bashit theme for the first time."
  echo "Random colors have been generated to be used in your prompt."
  echo "If you don't like them, run the command:"
  echo "  randomize_nwinkler"
  echo "until you get a combination that you like."
  echo
fi

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
  history -a
  history -c
  history -r
  PS1="($(clock_prompt)${_omb_prompt_reset_color}) $(scm_char) [${USERNAME_COLOR}\u${_omb_prompt_reset_color}@${HOSTNAME_COLOR}\H${_omb_prompt_reset_color}] ${PATH_COLOR}\w${_omb_prompt_reset_color}$(scm_prompt_info) ${_omb_prompt_reset_color}\n$(prompt_end) "
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
