#! bash oh-my-bash.module

# Harrison's Theme (ht)

# Description:
# Simple prompt that shows basic working directory and exit code info
# Works with 8 color terminals

# Example prompt:
# ● [harrison@ubN2] in src ± |dev ✗|

# OMB SCM Prompt overrides
SCM_GIT_SHOW_MINIMAL_INFO="true"
SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_red}✗${_omb_prompt_normal}"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_green}✓${_omb_prompt_normal}"
SCM_NONE_CHAR=""

function _omb_theme_ht_exit_color {
  case $1 in
  0)
    _omb_util_print "$_omb_prompt_green"
    ;;
  1)
    _omb_util_print "$_omb_prompt_red"
    ;;
  2)
    _omb_util_print "$_omb_prompt_gray"
    ;;
  126)
    _omb_util_print "$_omb_prompt_cyan"
    ;;
  127)
    _omb_util_print "$_omb_prompt_magenta"
    ;;
  130)
    _omb_util_print "$_omb_prompt_black"
    ;;
  148)
    _omb_util_print "$_omb_prompt_yellow"
    ;;
  *)
    _omb_util_print "$_omb_prompt_blue"
    ;;
  esac
}

# Displays the current prompt
function _omb_theme_PROMPT_COMMAND {
  # Capture exit code
  # NOTE: DO NOT MOVE
  local EXIT_CODE=$?

  # Start prompt blank
  PS1=""

  # Exit code indicator
  PS1+="$(_omb_theme_ht_exit_color "$EXIT_CODE")●$_omb_prompt_reset_color"

  # Environment info
  local rbenv virtualenv
  _omb_prompt_get_rbenv &&
    PS1+=$_omb_prompt_red$rbenv$_omb_prompt_reset_color
  _omb_prompt_get_virtualenv &&
    PS1+=$_omb_prompt_green$virtualenv$_omb_prompt_reset_color

  # User and host
  local user_host_prefix=" $_omb_prompt_reset_color["
  local user_host_suffix="$_omb_prompt_reset_color]"
  local user="$_omb_prompt_blue\u"
  local host="$_omb_prompt_cyan\H"
  local at="$_omb_prompt_reset_color@"
  PS1+="$user_host_prefix$user$at$host$user_host_suffix"

  # Working directory
  PS1+=" in $_omb_prompt_magenta\W$_omb_prompt_reset_color"

  # SCM
  PS1+=" $(scm_prompt_char_info)"

  # End prompt
  PS1+="\n${_omb_prompt_green}➜ $_omb_prompt_normal"
}

# Runs prompt (this bypasses oh-my-bash $PROMPT setting)
_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
